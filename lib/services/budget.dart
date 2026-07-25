import "dart:isolate";

import "package:flow/data/budget_progress.dart";
import "package:flow/data/budget_spec.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/data/string_multi_filter.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/budget.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";

final Logger _log = Logger("BudgetService");

class BudgetService {
  static BudgetService? _instance;

  factory BudgetService() => _instance ??= BudgetService._internal();

  BudgetService._internal();

  QueryBuilder<Budget> allQb() =>
      ObjectBox().box<Budget>().query().order(Budget_.createdDate);

  /// Ceiling on how many periods [currentPeriod] will page through before
  /// giving up. Only a pathologically fine-grained anchor left untouched for
  /// years could approach it; the loop is pure date math, so the cap exists to
  /// make "never spins forever" a guarantee rather than a hope.
  static const int _maxPagingSteps = 10000;

  /// The period [budget] is tracking at [asOf] (defaults to now).
  ///
  /// [Budget.range] is an **anchor**, not a moving window: it records one
  /// period of the series and is never rewritten. For a renewing budget on a
  /// [PageableRange], the live period is derived by paging the anchor forward
  /// (or backward, for an anchor set in the future) until it contains [asOf].
  ///
  /// This is what makes budget history free — every past period is just
  /// `currentPeriod(budget, asOf: someEarlierMoment)`, and the transactions
  /// behind it were never touched. Nothing is destroyed when a period rolls
  /// over, because nothing is written.
  ///
  /// A budget that opted out of renewal, or one on a non-pageable (custom)
  /// range, stays on its anchor forever — that's a deliberate one-off budget.
  TimeRange currentPeriod(Budget budget, {DateTime? asOf}) {
    final TimeRange anchor = budget.timeRange;

    if (!budget.renewAutomatically) return anchor;
    if (anchor is! PageableRange) return anchor;

    final DateTime moment = asOf ?? DateTime.now();

    if (anchor.contains(moment)) return anchor;

    // A budget anchored to a future period has not started yet, so the live
    // period is still the anchor — paging backward here would silently start
    // tracking it early. Historical lookups pass an explicit [asOf] and do
    // want to page back, which is what makes the history strip work.
    if (asOf == null && moment.isBefore(anchor.from)) return anchor;

    TimeRange range = anchor;
    int steps = 0;

    if (moment.isAfter(anchor.to)) {
      while (range is PageableRange &&
          range.to.isBefore(moment) &&
          steps++ < _maxPagingSteps) {
        range = range.next;
      }
    } else {
      while (range is PageableRange &&
          range.from.isAfter(moment) &&
          steps++ < _maxPagingSteps) {
        range = range.last;
      }
    }

    if (steps >= _maxPagingSteps) {
      _log.warning(
        "Gave up paging budget '${budget.name}' to $moment after $steps steps; "
        "anchor ${budget.range} is too fine-grained for its age",
      );
    }

    return range;
  }

  /// Expense transactions that count towards [budget] during [range]
  /// (defaults to the budget's current period).
  ///
  /// A budget with no categories counts every expense.
  QueryBuilder<Transaction> transactionsQb(Budget budget, {TimeRange? range}) {
    final List<String> categoriesUuids = budget.categories
        .map((category) => category.uuid)
        .toList();

    return TransactionFilter(
      range: TransactionFilterTimeRange.fromTimeRange(
        range ?? currentPeriod(budget),
      ),
      categories: categoriesUuids.isEmpty
          ? null
          : StringMultiFilter.whitelist(categoriesUuids),
      types: const [TransactionType.expense],
    ).queryBuilder();
  }

  /// Sums [transactions] into [budget]'s currency. Pending transactions
  /// don't count towards the budget.
  ///
  /// [SingleCurrencyFlow.hasMissingData] is set when a foreign-currency
  /// transaction couldn't be converted due to missing [rates].
  SingleCurrencyFlow computeSpent(
    Budget budget,
    Iterable<Transaction> transactions,
    ExchangeRates? rates,
  ) {
    return transactions.nonPending.flow.merge(budget.currency, rates);
  }

  /// A computed [BudgetProgress] for [budget] over [range], defaulting to its
  /// current period.
  ///
  /// Pass an explicit [range] to measure a past period — `currentPeriod` with
  /// an earlier `asOf` gives you one, and the result is as accurate as it was
  /// at the time, since the transactions behind it never moved.
  ///
  /// Pass [transactions] to avoid a query (e.g. when a caller already streams
  /// the budget's transactions); otherwise the budget's own transactions are
  /// fetched synchronously. [rates] converts foreign-currency spend into the
  /// budget's currency; without it, foreign spend is flagged as missing data.
  BudgetProgress computeProgress(
    Budget budget, {
    ExchangeRates? rates,
    Iterable<Transaction>? transactions,
    TimeRange? range,
    DateTime? asOf,
  }) {
    final DateTime now = asOf ?? DateTime.now();
    final TimeRange period = range ?? currentPeriod(budget, asOf: now);

    final Iterable<Transaction> txns;
    if (transactions != null) {
      txns = transactions;
    } else {
      final Query<Transaction> query = transactionsQb(
        budget,
        range: period,
      ).build();
      txns = query.find();
      query.close();
    }

    final SingleCurrencyFlow spentFlow = computeSpent(budget, txns, rates);

    return BudgetProgress(
      budget: budget,
      range: period,
      spent: Money(spentFlow.totalExpense.amount.abs(), budget.currency),
      limit: Money(budget.amount, budget.currency),
      asOf: now,
      hasMissingData: spentFlow.hasMissingData,
    );
  }

  /// [computeProgress] for every budget, sorted most-urgent first (see
  /// [BudgetProgress.severity]).
  List<BudgetProgress> computeAllProgress({
    ExchangeRates? rates,
    DateTime? asOf,
  }) {
    final DateTime now = asOf ?? DateTime.now();

    final List<BudgetProgress> progresses = [];
    for (final Budget budget in ObjectBox().box<Budget>().getAll()) {
      try {
        progresses.add(computeProgress(budget, rates: rates, asOf: now));
      } catch (e, stackTrace) {
        // One malformed budget must not sink the whole overview/bento. A
        // hand-edited or cross-version backup can carry an unparseable range
        // ([Budget.timeRange] throws) or an invalid currency ([Money] throws);
        // skip it and keep computing the rest.
        _log.warning(
          "Skipped budget '${budget.name}' while computing progress",
          e,
          stackTrace,
        );
      }
    }

    progresses.sort((a, b) => b.severity.compareTo(a.severity));

    return progresses;
  }

  /// [computeAllProgress], with the transaction scan moved to a background
  /// isolate.
  ///
  /// The cost of a budget is materializing every matching transaction and
  /// merging currencies; on a large database that is enough to drop frames,
  /// and it runs at startup and on every (debounced) transaction change. Only
  /// the scan moves: budgets are read and [BudgetProgress]es are assembled
  /// here, so the entity graph — and anything that would touch `Intl`, prefs,
  /// or a `BuildContext` — never leaves the main isolate.
  ///
  /// Falls back to the synchronous path if the isolate can't run, so a platform
  /// quirk degrades to jank rather than an empty screen.
  Future<List<BudgetProgress>> computeAllProgressAsync({
    ExchangeRates? rates,
    DateTime? asOf,
  }) async {
    final DateTime now = asOf ?? DateTime.now();

    final List<Budget> budgets = await ObjectBox().box<Budget>().getAllAsync();

    final List<BudgetSpec> specs = [];
    final Map<int, Budget> byId = {};

    for (final Budget budget in budgets) {
      try {
        // Same resilience as computeAllProgress: an unparseable range or an
        // invalid currency from a hand-edited backup skips one budget, it
        // doesn't sink the screen.
        final TimeRange period = currentPeriod(budget, asOf: now);

        specs.add(
          BudgetSpec(
            correlationId: budget.id,
            currency: budget.currency,
            categoryUuids: budget.categories
                .map((category) => category.uuid)
                .toList(),
            from: period.from,
            to: period.to,
          ),
        );
        byId[budget.id] = budget;
      } catch (e, stackTrace) {
        _log.warning(
          "Skipped budget '${budget.name}' while preparing progress",
          e,
          stackTrace,
        );
      }
    }

    if (specs.isEmpty) return [];

    final List<BudgetSpend> spends;
    try {
      final BudgetSpendRequest request = BudgetSpendRequest(
        storeReference: ObjectBox().store.reference,
        specs: specs,
        rates: rates,
      );

      spends = await runBudgetSpendsInIsolate(request);
    } catch (e, stackTrace) {
      _log.warning(
        "Background budget computation failed; falling back to the main "
        "isolate",
        e,
        stackTrace,
      );
      return computeAllProgress(rates: rates, asOf: now);
    }

    final List<BudgetProgress> progresses = [];

    for (final BudgetSpend spend in spends) {
      final Budget? budget = byId[spend.correlationId];
      if (budget == null) continue;

      try {
        progresses.add(
          BudgetProgress(
            budget: budget,
            range: currentPeriod(budget, asOf: now),
            spent: Money(spend.spent, budget.currency),
            limit: Money(budget.amount, budget.currency),
            asOf: now,
            hasMissingData: spend.hasMissingData,
          ),
        );
      } catch (e, stackTrace) {
        _log.warning(
          "Skipped budget '${budget.name}' while assembling progress",
          e,
          stackTrace,
        );
      }
    }

    for (final Budget budget in byId.values) {
      if (progresses.any((progress) => progress.budget.id == budget.id)) {
        continue;
      }
      _log.warning(
        "Budget '${budget.name}' produced no spend in the background isolate; "
        "it is missing from this overview",
      );
    }

    progresses.sort((a, b) => b.severity.compareTo(a.severity));

    return progresses;
  }

  /// Rolls [progresses] up into a status summary: counts of over / nearing
  /// budgets plus the single worst offender.
  ///
  /// No currency conversion happens here — this is a count/status view, not a
  /// money total. Summing independent, possibly-overlapping budgets (or ones on
  /// different periods) would double-count, so [BudgetsSummary] intentionally
  /// omits a combined total. Pass already-current progresses; order doesn't
  /// matter (the worst is picked by [BudgetProgress.severity]).
  BudgetsSummary computeSummary(List<BudgetProgress> progresses) {
    int over = 0;
    int warning = 0;
    bool missing = false;
    BudgetProgress? worst;

    for (final BudgetProgress p in progresses) {
      switch (p.status) {
        case BudgetStatus.over:
          over++;
        case BudgetStatus.warning:
          warning++;
        case BudgetStatus.healthy:
          break;
      }

      if (p.hasMissingData) missing = true;

      if (worst == null || p.severity > worst.severity) worst = p;
    }

    return BudgetsSummary(
      budgetCount: progresses.length,
      overCount: over,
      warningCount: warning,
      worst: worst,
      hasMissingData: missing,
    );
  }

  /// [computeProgress] for [budget] over each of the [count] periods ending
  /// with the one containing [asOf], oldest first.
  ///
  /// Only meaningful for a renewing budget on a [PageableRange]; anything else
  /// has exactly one period, so the result is a single entry.
  List<BudgetProgress> computeHistory(
    Budget budget, {
    int count = 6,
    ExchangeRates? rates,
    DateTime? asOf,
  }) {
    final DateTime now = asOf ?? DateTime.now();

    return historyPeriods(budget, count: count, asOf: now)
        .map(
          (range) =>
              computeProgress(budget, rates: rates, range: range, asOf: now),
        )
        .toList();
  }

  /// [computeHistory], with all its period scans done in a single background
  /// isolate pass.
  ///
  /// History is N transaction scans rather than one, so it is exactly the
  /// screen-blocking work the isolate exists for. All periods go over in one
  /// request — spawning an isolate per period would cost more than it saves.
  Future<List<BudgetProgress>> computeHistoryAsync(
    Budget budget, {
    int count = 6,
    ExchangeRates? rates,
    DateTime? asOf,
  }) async {
    final DateTime now = asOf ?? DateTime.now();

    final List<TimeRange> periods = historyPeriods(
      budget,
      count: count,
      asOf: now,
    );

    final List<BudgetSpend> spends;
    try {
      final BudgetSpendRequest request = BudgetSpendRequest(
        storeReference: ObjectBox().store.reference,
        specs: [
          for (int i = 0; i < periods.length; i++)
            BudgetSpec(
              correlationId: i,
              currency: budget.currency,
              categoryUuids: budget.categories
                  .map((category) => category.uuid)
                  .toList(),
              from: periods[i].from,
              to: periods[i].to,
            ),
        ],
        rates: rates,
      );

      final List<BudgetSpend> result = await runBudgetSpendsInIsolate(request);

      // The isolate catches per-spec failures individually, so "every spec
      // threw" arrives here as a successful empty list rather than an error.
      // Without this the method would return no history at all and nothing
      // would fall back — the same shape as the bug where a silent fallback
      // hid that the isolate never ran.
      if (result.isEmpty && periods.isNotEmpty) {
        throw StateError(
          "Budget history isolate returned no spends for "
          "${periods.length} period(s)",
        );
      }

      spends = result;
    } catch (e, stackTrace) {
      _log.warning(
        "Background budget history failed; falling back to the main isolate",
        e,
        stackTrace,
      );
      return computeHistory(budget, count: count, rates: rates, asOf: now);
    }

    final Map<int, BudgetSpend> byIndex = {
      for (final BudgetSpend spend in spends) spend.correlationId: spend,
    };

    final List<BudgetProgress> history = [];

    for (int i = 0; i < periods.length; i++) {
      final BudgetSpend? spend = byIndex[i];
      if (spend == null) {
        _log.warning(
          "No spend came back for period ${periods[i]} of budget "
          "'${budget.name}'; it is missing from the history strip",
        );
        continue;
      }

      history.add(
        BudgetProgress(
          budget: budget,
          range: periods[i],
          spent: Money(spend.spent, budget.currency),
          limit: Money(budget.amount, budget.currency),
          asOf: now,
          hasMissingData: spend.hasMissingData,
        ),
      );
    }

    return history;
  }

  /// The [count] periods ending with the one containing [asOf], oldest first.
  ///
  /// A one-off budget has no series to page back through — its anchor may still
  /// be pageable, but earlier periods were never part of the budget — so it
  /// yields exactly one period.
  List<TimeRange> historyPeriods(
    Budget budget, {
    int count = 6,
    DateTime? asOf,
  }) {
    TimeRange period = currentPeriod(budget, asOf: asOf ?? DateTime.now());

    final List<TimeRange> periods = [period];

    while (budget.renewAutomatically &&
        periods.length < count &&
        period is PageableRange) {
      final TimeRange previous = period.last;

      // Stop at the budget's creation. Spend in the categories it watches
      // exists long before the budget did, and rendering it as that budget's
      // own past performance invents a history the user never set.
      if (previous.to.isBefore(budget.createdDate)) break;

      period = previous;
      periods.insert(0, period);
    }

    return periods;
  }
}

/// Spawns the isolate that runs [computeBudgetSpends].
///
/// **This must stay a top-level function taking only [request].** A closure
/// passed to [Isolate.run] captures its entire enclosing lexical context, not
/// merely the variables it mentions. Inlining this call into
/// [BudgetService.computeAllProgressAsync] captures that method's locals —
/// including the `List<Budget>` whose `ToMany` is bound to the store — and the
/// send fails with "object is unsendable".
///
/// That failure is invisible in normal use: [BudgetService] catches it and
/// degrades to the synchronous path, which returns identical numbers. The
/// isolate simply stops running, forever, and nothing says so. Keeping the
/// spawn in a function with a one-variable context is what prevents it.
Future<List<BudgetSpend>> runBudgetSpendsInIsolate(
  BudgetSpendRequest request,
) => Isolate.run(() => computeBudgetSpends(request));

/// Runs on a background isolate. Entry point for
/// [BudgetService.computeAllProgressAsync].
///
/// **Everything reachable from here must be isolate-safe.** Statics are
/// per-isolate, so any singleton this touches starts uninitialized. The current
/// chain is safe on purpose:
///
/// * `ObjectBox()` — bound explicitly via [ObjectBox.attachIsolate].
/// * `CategoriesService` / `AccountsService` (reached through
///   `TransactionFilter.queryBuilder`) — empty constructors that only read
///   through `ObjectBox()`.
/// * `CurrencyRegistryService` — self-initializes from const data.
/// * `UserPreferencesService` — never reached, because [BudgetSpec.currency] is
///   always explicit. `SingleCurrencyFlow` only falls back to the primary
///   currency when passed none.
/// * `Intl` / `Money.formatted` — never called; formatting is the caller's job.
///
/// Adding a call here that violates any of the above will not fail at compile
/// time. It will throw at runtime, inside the isolate, and surface as the
/// fallback path silently taking over.
List<BudgetSpend> computeBudgetSpends(BudgetSpendRequest request) {
  ObjectBox.attachIsolate(request.storeReference);

  try {
    final List<BudgetSpend> spends = [];

    for (final BudgetSpec spec in request.specs) {
      try {
        spends.add(_spendFor(spec, request.rates));
      } catch (_) {
        // No logger appenders exist in a spawned isolate, so there is nothing
        // useful to say here. The caller notices the missing correlationId and logs
        // it with a name attached.
      }
    }

    return spends;
  } finally {
    ObjectBox.detachIsolate();
  }
}

BudgetSpend _spendFor(BudgetSpec spec, ExchangeRates? rates) {
  final Query<Transaction> query = TransactionFilter(
    range: TransactionFilterTimeRange.fromTimeRange(
      CustomTimeRange(spec.from, spec.to),
    ),
    categories: spec.categoryUuids.isEmpty
        ? null
        : StringMultiFilter.whitelist(spec.categoryUuids),
    types: const [TransactionType.expense],
  ).queryBuilder().build();

  final List<Transaction> transactions = query.find();
  query.close();

  final SingleCurrencyFlow spentFlow = transactions.nonPending.flow.merge(
    spec.currency,
    rates,
  );

  return BudgetSpend(
    correlationId: spec.correlationId,
    spent: spentFlow.totalExpense.amount.abs(),
    hasMissingData: spentFlow.hasMissingData,
  );
}

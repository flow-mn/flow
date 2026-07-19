import "package:flow/data/budget_progress.dart";
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

  /// Expense transactions that count towards [budget] during [range]
  /// (defaults to the budget's own period).
  ///
  /// A budget with no categories counts every expense.
  QueryBuilder<Transaction> transactionsQb(Budget budget, {TimeRange? range}) {
    final List<String> categoriesUuids = budget.categories
        .map((category) => category.uuid)
        .toList();

    return TransactionFilter(
      range: TransactionFilterTimeRange.fromTimeRange(
        range ?? budget.timeRange,
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

  /// A computed [BudgetProgress] for [budget] against its current period.
  ///
  /// Pass [transactions] to avoid a query (e.g. when a caller already streams
  /// the budget's transactions); otherwise the budget's own transactions are
  /// fetched synchronously. [rates] converts foreign-currency spend into the
  /// budget's currency; without it, foreign spend is flagged as missing data.
  BudgetProgress computeProgress(
    Budget budget, {
    ExchangeRates? rates,
    Iterable<Transaction>? transactions,
    DateTime? asOf,
  }) {
    final Iterable<Transaction> txns;
    if (transactions != null) {
      txns = transactions;
    } else {
      final Query<Transaction> query = transactionsQb(budget).build();
      txns = query.find();
      query.close();
    }

    final SingleCurrencyFlow spentFlow = computeSpent(budget, txns, rates);

    return BudgetProgress(
      budget: budget,
      spent: Money(spentFlow.totalExpense.amount.abs(), budget.currency),
      limit: Money(budget.amount, budget.currency),
      asOf: asOf ?? DateTime.now(),
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

  /// Advances every auto-renewing budget whose period has ended to the
  /// period containing the current moment. No-op for budgets on a
  /// non-pageable (custom) range.
  ///
  /// Idempotent; safe to call at startup and before rendering budgets.
  ///
  /// Returns the number of budgets that were advanced.
  Future<int> renewDueBudgets() async {
    final DateTime now = DateTime.now();
    final List<Budget> budgets = await ObjectBox().box<Budget>().getAllAsync();
    final List<Budget> renewed = [];

    for (final Budget budget in budgets) {
      if (!budget.renewAutomatically) continue;

      TimeRange range = budget.timeRange;
      if (range is! PageableRange) continue;

      if (!range.to.isBefore(now)) continue;

      while (range.to.isBefore(now)) {
        range = (range as PageableRange).next;
      }

      budget.timeRange = range;
      renewed.add(budget);
    }

    if (renewed.isNotEmpty) {
      await ObjectBox().box<Budget>().putManyAsync(renewed);
      _log.fine("Renewed ${renewed.length} budget(s) to their current period");
    }

    return renewed.length;
  }
}

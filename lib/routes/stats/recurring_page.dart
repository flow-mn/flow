import "package:flow/data/money.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/services/categories.dart";
import "package:flow/services/recurring_transactions.dart";
import "package:flow/services/transactions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/utils/extensions/recurring_transaction.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/stats/missing_rates_notice.dart";
import "package:flow/widgets/stats/recurring/recurring_summary_header.dart";
import "package:flow/widgets/stats/stats_app_bar.dart";
import "package:flow/widgets/stats/stats_empty_state.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flow/widgets/transaction_list_tile.dart";
import "package:flow/widgets/transactions_date_header.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:moment_dart/moment_dart.dart";

/// Subscriptions & recurring radar.
///
/// Projects every active [RecurringTransaction] forward across the selected
/// [range] using its [Recurrence] rules, then lists the occurrences — incomes
/// and expenses alike — through the universal transaction list, and sums the
/// expected inflow/outflow.
class RecurringPage extends StatefulWidget {
  const RecurringPage({super.key});

  @override
  State<RecurringPage> createState() => _RecurringPageState();
}

class _RecurringPageState extends State<RecurringPage>
    with PrimaryCurrencyDependentState<RecurringPage> {
  /// Caps how many rows are drawn; occurrences are sorted by date, so the
  /// soonest survive. Totals are computed over every occurrence regardless.
  static const int _maxRows = 60;

  TimeRange range = TimeRange.thisMonth();

  bool busy = false;
  bool missingRates = false;

  /// All projected occurrences in [range], sorted by date ascending.
  List<Transaction> occurrences = [];
  int activeCount = 0;
  double totalIncome = 0.0;
  double totalExpense = 0.0;

  /// Maps an already-logged occurrence's list key to its real transaction id.
  /// Occurrences absent here are still upcoming previews — badged with an eye
  /// and non-openable.
  Map<String, int> _loggedIdByKey = {};

  @override
  Widget build(BuildContext context) {
    final List<Transaction> displayed = occurrences.take(_maxRows).toList();
    final int hidden = occurrences.length - displayed.length;
    final Map<TimeRange, List<Transaction>> grouped = displayed.groupByDate();

    return Scaffold(
      appBar: StatsAppBar(title: "tabs.stats.analytics.recurring".t(context)),
      body: SafeArea(
        child: busy && occurrences.isEmpty
            ? const Spinner.center()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    const SizedBox(height: 16.0),
                    Frame(
                      child: TimeRangeSelector(
                        initialValue: range,
                        onChanged: _updateRange,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ListHeader(
                      "tabs.stats.analytics.recurring.projectedTitle".t(
                        context,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    RecurringSummaryHeader(
                      income: Money(totalIncome, primaryCurrency),
                      expense: Money(totalExpense, primaryCurrency),
                      count: occurrences.length,
                    ),
                    const SizedBox(height: 16.0),
                    switch ((activeCount, occurrences.isEmpty)) {
                      (0, _) => StatsEmptyState(
                        message: "tabs.stats.analytics.recurring.none".t(
                          context,
                        ),
                      ),
                      (_, true) => StatsEmptyState(
                        message:
                            "tabs.stats.analytics.recurring.nothingUpcoming".t(
                              context,
                            ),
                      ),
                      (_, false) => Column(
                        crossAxisAlignment: .start,
                        children: _buildGroups(context, grouped),
                      ),
                    },
                    if (hidden > 0) ...[
                      const SizedBox(height: 8.0),
                      Frame(
                        child: Text(
                          "tabs.stats.analytics.recurring.moreNotShown".t(
                            context,
                            {"count": hidden},
                          ),
                          style: context.textTheme.bodySmall?.semi(context),
                        ),
                      ),
                    ],
                    if (missingRates) ...[
                      const SizedBox(height: 8.0),
                      MissingRatesNotice(
                        message: "tabs.stats.analytics.missingRatesAmounts".t(
                          context,
                        ),
                      ),
                    ],
                    const SizedBox(height: 96.0),
                  ],
                ),
              ),
      ),
    );
  }

  List<Widget> _buildGroups(
    BuildContext context,
    Map<TimeRange, List<Transaction>> grouped,
  ) {
    final List<Widget> rows = [];

    for (final MapEntry<TimeRange, List<Transaction>> entry
        in grouped.entries) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: TransactionListDateHeader(
            transactions: entry.value,
            range: entry.key,
          ),
        ),
      );

      for (final Transaction transaction in entry.value) {
        // Projections aren't real rows. [IgnorePointer] suppresses the tile's
        // own tap (which opens a transaction by id a projection lacks) and its
        // swipe (which acts on a real entity); the outer [GestureDetector] adds
        // back a tap-only affordance that opens the logged entry, or toasts if
        // this occurrence is still just a projection.
        rows.add(
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openOccurrence(context, transaction),
            child: IgnorePointer(
              child: TransactionListTile(
                key: ValueKey(_occurrenceKey(transaction)),
                transaction: transaction,
                recoverFromTrashFn: null,
                moveToTrashFn: null,
                combineTransfers: false,
                preview: !_loggedIdByKey.containsKey(
                  _occurrenceKey(transaction),
                ),
              ),
            ),
          ),
        );
      }
    }

    return rows;
  }

  void _updateRange(TimeRange value) {
    if (value == range) return;
    range = value;
    fetch();
  }

  /// Stable per-occurrence key (rule template uuid + date), shared by the row's
  /// [ValueKey] and the [_loggedIdByKey] lookup.
  String _occurrenceKey(Transaction occurrence) =>
      "${occurrence.uuid}-"
      "${occurrence.transactionDate.microsecondsSinceEpoch}";

  /// Opens the real transaction behind a tapped occurrence when it's already
  /// been logged; otherwise explains it's still an upcoming projection.
  void _openOccurrence(BuildContext context, Transaction occurrence) {
    final int? loggedId = _loggedIdByKey[_occurrenceKey(occurrence)];

    if (loggedId == null) {
      context.showToast(
        text: "tabs.stats.analytics.recurring.notLoggedYet".t(context),
        type: .info,
      );
      return;
    }

    context.push("/transaction/$loggedId");
  }

  /// The real transaction a rule logged on [date], if any (matched by day).
  Transaction? _matchLogged(List<Transaction> logged, DateTime date) {
    for (final Transaction transaction in logged) {
      final DateTime d = transaction.transactionDate;
      if (d.year == date.year && d.month == date.month && d.day == date.day) {
        return transaction;
      }
    }
    return null;
  }

  @override
  Future<void> fetch() async {
    if (!mounted) return;
    setState(() {
      busy = true;
    });

    bool missing = false;

    try {
      final query = RecurringTransactionsService().activeRecurringsQb().build();
      final List<RecurringTransaction> recurrings = query.find();
      query.close();

      final List<Transaction> result = [];
      final Map<String, int> loggedIds = {};
      double income = 0.0;
      double expense = 0.0;
      int active = 0;

      for (final RecurringTransaction recurring in recurrings) {
        // Validate the template once; a stale currency code throws on `money`.
        if (_decodeTemplate(recurring) == null) continue;

        active++;

        // Real transactions this rule has already generated; occurrences that
        // match one (by day) are actual entries, not previews.
        final List<Transaction> logged = TransactionsService().findManySync(
          TransactionFilter(extraTag: recurring.extensionIdentifierTag),
        );

        final String? categoryUuid = recurring.template.categoryUuid;
        final Category? category = categoryUuid == null
            ? null
            : CategoriesService().findOneSync(categoryUuid);

        final List<DateTime> dates = recurring.recurrence.occurrences(
          subrange: range,
        );

        for (final DateTime date in dates) {
          // `template` decodes a fresh instance each access, so each occurrence
          // gets its own object to carry a distinct date.
          final Transaction occurrence = recurring.template
            ..transactionDate = date
            ..isPending = true
            ..setCategory(category);

          result.add(occurrence);

          final Transaction? loggedMatch = _matchLogged(logged, date);
          if (loggedMatch != null) {
            loggedIds[_occurrenceKey(occurrence)] = loggedMatch.id;
          }

          final double? converted = occurrence.money.tryConvertAmount(
            primaryCurrency,
            rates,
          );
          if (converted == null) {
            missing = true;
            continue;
          }

          switch (occurrence.type) {
            case TransactionType.income:
              income += converted.abs();
            case TransactionType.expense:
              expense += converted.abs();
            case TransactionType.transfer:
              break;
          }
        }
      }

      result.sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

      occurrences = result;
      _loggedIdByKey = loggedIds;
      activeCount = active;
      totalIncome = income;
      totalExpense = expense;
      missingRates = missing;
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }

  Transaction? _decodeTemplate(RecurringTransaction recurring) {
    try {
      final Transaction template = recurring.template;
      // A malformed template or unknown currency shouldn't take down the page.
      template.money;
      return template;
    } catch (_) {
      return null;
    }
  }
}

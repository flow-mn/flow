import "dart:async";

import "package:flow/data/budget_progress.dart";
import "package:flow/entity/budget.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/error_page.dart";
import "package:flow/services/budget.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/budget_change_aware_state.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/analytics/bullet_chart.dart";
import "package:flow/widgets/budgets/budget_category_chips.dart";
import "package:flow/widgets/budgets/budget_history_strip.dart";
import "package:flow/widgets/budgets/budget_insight_row.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flow/widgets/grouped_transactions_list_view.dart";
import "package:flow/widgets/no_result.dart";
import "package:flow/widgets/rates_missing_error_box.dart";
import "package:flow/widgets/transactions_date_header.dart";
import "package:flow/widgets/transactions_selection_controller.dart";
import "package:flow/widgets/transactions_selection_scope.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// A budget at a glance: how the live period is tracking, what the rules make
/// of it, how the last few periods went, and every transaction behind the
/// number.
///
/// Read-only on purpose. Editing lives one tap away at `/budgets/:id/edit`;
/// opening a budget to check on it should not put a Delete button under your
/// thumb.
class BudgetDetailPage extends StatefulWidget {
  final int budgetId;

  const BudgetDetailPage({super.key, required this.budgetId});

  @override
  State<BudgetDetailPage> createState() => _BudgetDetailPageState();
}

class _BudgetDetailPageState extends State<BudgetDetailPage>
    with
        PrimaryCurrencyDependentState<BudgetDetailPage>,
        BudgetChangeAwareState<BudgetDetailPage> {
  static const int _historyPeriodCount = 6;

  Budget? budget;
  BudgetProgress? progress;
  List<BudgetProgress> history = [];

  bool busy = true;

  late final TransactionsSelectionController _selection;

  @override
  void initState() {
    budget = ObjectBox().box<Budget>().get(widget.budgetId);
    _selection = TransactionsSelectionController();
    _selection.addListener(_onSelectionChanged);

    super.initState();
  }

  @override
  void dispose() {
    _selection.removeListener(_onSelectionChanged);
    _selection.dispose();
    super.dispose();
  }

  void _onSelectionChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Budget? budget = this.budget;

    if (budget == null) return const ErrorPage();

    final TimeRange period = BudgetService().currentPeriod(budget);

    return Scaffold(
      appBar: AppBar(
        title: Text(budget.name),
        actions: [
          IconButton(
            icon: const Icon(Symbols.edit_rounded),
            onPressed: _edit,
            tooltip: "general.edit".t(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: BudgetService()
            .transactionsQb(budget, range: period)
            .watch(triggerImmediately: true)
            .map((event) => event.find()),
        builder: (context, snapshot) {
          final List<Transaction> transactions = snapshot.data ?? const [];

          final Widget header = _buildHeader(context, budget, period);

          return TransactionsSelectionScope(
            controller: _selection,
            visibleTransactions: transactions,
            child: SafeArea(
              child: transactions.isEmpty
                  ? Column(
                      children: [
                        header,
                        const Expanded(child: NoResult()),
                      ],
                    )
                  : GroupedTransactionsListView(
                      selectionController: _selection,
                      mainHeader: header,
                      mainHeaderPadding: EdgeInsets.zero,
                      transactions: transactions.nonPending.groupByDate(),
                      headerBuilder: (pendingGroup, range, transactions) =>
                          TransactionListDateHeader(
                            transactions: transactions,
                            range: range,
                          ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Budget budget, TimeRange period) {
    final BudgetProgress? progress = this.progress;

    final bool showMissingExchangeRatesWarning =
        rates == null &&
        TransitiveLocalPreferences().usesNonPrimaryCurrency.get();

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        const SizedBox(height: 8.0),
        Surface(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          builder: (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            // `progress` is null while the first compute is in flight, and also
            // when it failed — `fetch()` swallows its errors so the rest of the
            // page still renders. Both cases have to degrade here; asserting
            // non-null would turn a budget with unparseable data into a red
            // screen on the one page meant to explain it.
            child: progress == null
                ? SizedBox(
                    height: 96.0,
                    child: busy
                        ? const Spinner.center()
                        : Center(
                            child: Text(
                              "budget.detail.unavailable".t(context),
                              textAlign: .center,
                              style: context.textTheme.bodyMedium?.semi(context),
                            ),
                          ),
                  )
                : _buildProgressCard(context, budget, period, progress),
          ),
        ),
        if (progress != null)
          BudgetInsightRow(progress: progress, omitName: true),
        if (showMissingExchangeRatesWarning) ...[
          const SizedBox(height: 8.0),
          const RatesMissingErrorBox(),
        ],
        if (history.length > 1) ...[
          const SizedBox(height: 16.0),
          ListHeader("budget.detail.history".t(context)),
          const SizedBox(height: 8.0),
          Frame(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BudgetHistoryStrip(history: history),
          ),
        ],
        const SizedBox(height: 20.0),
        ListHeader("budget.detail.transactions".t(context)),
      ],
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    Budget budget,
    TimeRange period,
    BudgetProgress progress,
  ) {
    final Color tint = BudgetInsightRow.tintFor(context, progress.status);

    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        Row(
          crossAxisAlignment: .end,
          children: [
            Expanded(
              child: Wrap(
                crossAxisAlignment: .center,
                children: [
                  MoneyText(
                    progress.spent,
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: tint,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    " / ",
                    style: context.textTheme.titleMedium?.semi(context),
                  ),
                  MoneyText(
                    progress.limit,
                    style: context.textTheme.titleMedium?.semi(context),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              "${progress.percent}%",
              style: context.textTheme.titleLarge?.copyWith(
                color: tint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        BulletChart(
          value: progress.spent.amount,
          target: progress.limit.amount,
          height: 14.0,
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            Expanded(
              child: Text(
                _periodLabel(period),
                style: context.textTheme.bodySmall?.semi(context),
              ),
            ),
            Text(
              // Floor at 1: `daysLeft` truncates, so the whole of a period's
              // last day reads "0 days left" while it is still running.
              // BudgetInsightRow clamps the same way.
              progress.isCurrent
                  ? "budget.detail.daysLeft".t(
                      context,
                      progress.daysLeft < 1 ? 1 : progress.daysLeft,
                    )
                  : "budget.detail.periodEnded".t(context),
              style: context.textTheme.bodySmall?.semi(context),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        BudgetCategoryChips(
          categories: budget.categories.toList(),
          allSpendingLabel: "budget.categories.allShort".t(context),
        ),
      ],
    );
  }

  String _periodLabel(TimeRange range) => switch (range) {
    MonthTimeRange month => month.from.format(
      payload: month.from.isAtSameYearAs(DateTime.now()) ? "MMMM" : "MMMM YYYY",
    ),
    YearTimeRange year => year.year.toString(),
    _ => "${range.from.toMoment().ll} -> ${range.to.toMoment().ll}",
  };

  Future<void> _edit() async {
    await context.push("/budgets/${widget.budgetId}/edit");

    // The budget may have been deleted from the editor, in which case there is
    // nothing left to show.
    final Budget? updated = ObjectBox().box<Budget>().get(widget.budgetId);

    if (!mounted) return;

    if (updated == null) {
      context.pop();
      return;
    }

    // No refetch here: a save writes to the Budget box, and
    // BudgetChangeAwareState is already listening for exactly that. If the user
    // changed nothing, no write happened and there is nothing to refetch.
    setState(() => budget = updated);
  }

  @override
  Future<void> fetch() async {
    final Budget? budget = ObjectBox().box<Budget>().get(widget.budgetId);

    if (budget == null) {
      if (mounted) setState(() => busy = false);
      return;
    }

    if (mounted) setState(() => busy = true);

    try {
      final List<BudgetProgress> periods = await BudgetService()
          .computeHistoryAsync(
            budget,
            count: _historyPeriodCount,
            rates: rates,
          );

      history = periods;
      progress = periods.isEmpty ? null : periods.last;
      this.budget = budget;
    } catch (error, stackTrace) {
      debugPrint("Failed to compute budget detail: $error\n$stackTrace");
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }
}

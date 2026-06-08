import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/flow_standard_report.dart";
import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/analytics/sankey_diagram.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/home/stats/info_card_with_delta.dart";
import "package:flow/widgets/stats/cash_flow/cash_flow_legend.dart";
import "package:flow/widgets/stats/cash_flow/cash_flow_summary.dart";
import "package:flow/widgets/stats/missing_rates_notice.dart";
import "package:flow/widgets/stats/stats_app_bar.dart";
import "package:flow/widgets/stats/stats_empty_state.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

/// Cash-flow Sankey.
///
/// Income categories flow through a single total hub into spending categories
/// (plus a balancing "Saved" / "From reserves" node) for the current month.
class CashFlowPage extends StatefulWidget {
  const CashFlowPage({super.key});

  @override
  State<CashFlowPage> createState() => _CashFlowPageState();
}

class _CashFlowPageState extends State<CashFlowPage>
    with PrimaryCurrencyDependentState<CashFlowPage> {
  static const int _maxIncomeNodes = 4;
  static const int _maxExpenseNodes = 6;

  TimeRange range = TimeRange.thisMonth();

  bool busy = false;
  bool missingRates = false;
  bool failed = false;

  List<SankeyDatum> sources = [];
  List<SankeyDatum> targets = [];
  double totalIncome = 0.0;
  double totalExpense = 0.0;

  /// Drives the forecast headline and the daily-average cards. Fetched
  /// alongside the Sankey aggregation but kept independent, so the averages
  /// still render if the per-category pass fails.
  FlowStandardReport? report;

  final AutoSizeGroup _averagesGroup = AutoSizeGroup();

  @override
  Widget build(BuildContext context) {
    final bool hasData = sources.isNotEmpty && targets.isNotEmpty;
    final double net = totalIncome - totalExpense;

    final FlowStandardReport? stats = report;

    // The forecast only means something when the range still has days left to
    // run and there's movement to project; for a closed range the projection
    // equals the actual total, so it's folded into the summary only here.
    Money? forecast;
    if (stats != null &&
        range.contains(DateTime.now()) &&
        (stats.incomeSum.amount != 0 || stats.expenseSum.amount != 0)) {
      forecast = stats.currentExpenseSumForecast ?? stats.expenseSum;
    }

    return Scaffold(
      appBar: StatsAppBar(title: "tabs.stats.analytics.cashFlow".t(context)),
      body: SafeArea(
        child: busy && sources.isEmpty
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
                    CashFlowSummary(
                      income: Money(totalIncome, primaryCurrency),
                      expense: Money(totalExpense, primaryCurrency),
                      net: Money(net, primaryCurrency),
                      forecast: forecast,
                      forecastComparison: stats?.previousExpenseSum,
                      forecastLabel: "tabs.stats.intervalReport.forecast".t(
                        context,
                        range.format(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    if (failed)
                      StatsEmptyState(
                        message: "tabs.stats.analytics.cashFlow.loadFailed".t(
                          context,
                        ),
                      )
                    else if (hasData) ...[
                      Frame(
                        child: SankeyDiagram(
                          sources: sources,
                          targets: targets,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      ListHeader("tabs.stats.analytics.income".t(context)),
                      const SizedBox(height: 8.0),
                      CashFlowLegend(data: sources, currency: primaryCurrency),
                      const SizedBox(height: 16.0),
                      ListHeader("tabs.stats.analytics.spending".t(context)),
                      const SizedBox(height: 8.0),
                      CashFlowLegend(data: targets, currency: primaryCurrency),
                    ] else
                      StatsEmptyState(
                        message: "tabs.stats.analytics.cashFlow.empty".t(
                          context,
                        ),
                      ),
                    if (stats != null &&
                        (stats.incomeSum.amount != 0 ||
                            stats.expenseSum.amount != 0)) ...[
                      const SizedBox(height: 24.0),
                      _buildAverages(context, stats),
                    ],
                    if (missingRates) ...[
                      const SizedBox(height: 12.0),
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

  void _updateRange(TimeRange value) {
    if (value == range) return;
    range = value;
    fetch();
  }

  /// Per-day averages for expense, income, and flow, each with a delta against
  /// the previous comparable period when one exists.
  Widget _buildAverages(BuildContext context, FlowStandardReport stats) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        ListHeader("tabs.stats.intervalReport.averages@day".t(context)),
        const SizedBox(height: 8.0),
        Frame(
          child: Column(
            spacing: 16.0,
            children: [
              Row(
                spacing: 16.0,
                children: [
                  Expanded(
                    child: InfoCardWithDelta(
                      title: "tabs.stats.intervalReport.averages.expense".t(
                        context,
                      ),
                      autoSizeGroup: _averagesGroup,
                      money: stats.dailyAvgExpenditure,
                      previousMoney: stats.previousDailyAvgExpenditure,
                      invertDelta: true,
                    ),
                  ),
                  Expanded(
                    child: InfoCardWithDelta(
                      title: "tabs.stats.intervalReport.averages.income".t(
                        context,
                      ),
                      autoSizeGroup: _averagesGroup,
                      money: stats.dailyAvgIncome,
                      previousMoney: stats.previousDailyAvgIncome,
                    ),
                  ),
                ],
              ),
              InfoCardWithDelta(
                title: "tabs.stats.intervalReport.averages.flow".t(context),
                autoSizeGroup: _averagesGroup,
                money: stats.dailyAvgFlow,
                previousMoney: stats.previousDailyAvgFlow,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Future<void> fetch() async {
    if (!mounted) return;
    setState(() {
      busy = true;
    });

    // Powers the forecast + averages; isolated from the Sankey aggregation so a
    // failure on either side doesn't blank out the other.
    try {
      report = await FlowStandardReport.generate(range, rates);
    } catch (_) {
      report = null;
    }

    bool missing = false;
    bool error = false;

    try {
      final analytics = await ObjectBox().flowByCategories(range: range);

      // The initial fetch runs from initState (via the mixin), where reading
      // inherited widgets like Theme isn't allowed yet — so resolve theme
      // colors only after the await, once the element is mounted.
      if (!mounted) return;
      final Color otherColor = context.colorScheme.onSurface.withAlpha(0x66);
      final Color incomeColor = context.flowColors.income;
      final Color expenseColor = context.flowColors.expense;
      final List<Color> palette = context.chartAccents;

      final List<SankeyDatum> incomeNodes = [];
      final List<SankeyDatum> expenseNodes = [];
      double income = 0.0;
      double expense = 0.0;
      int colorIndex = 0;

      for (final entry in analytics.flow.entries) {
        final flow = entry.value;
        final single = flow.merge(primaryCurrency, rates);
        missing = missing || single.hasMissingData;

        final String name =
            flow.associatedData?.name ??
            "tabs.stats.analytics.uncategorized".tr();
        final Color color =
            flow.associatedData?.colorScheme?.primary ??
            palette[colorIndex++ % palette.length];

        final double incomeAmount = single.totalIncome.amount;
        final double expenseAmount = single.totalExpense.amount.abs();

        if (incomeAmount > 0) {
          incomeNodes.add(
            SankeyDatum(label: name, value: incomeAmount, color: color),
          );
          income += incomeAmount;
        }
        if (expenseAmount > 0) {
          expenseNodes.add(
            SankeyDatum(label: name, value: expenseAmount, color: color),
          );
          expense += expenseAmount;
        }
      }

      final List<SankeyDatum> nextSources = _bucket(
        incomeNodes,
        _maxIncomeNodes,
        otherColor,
      );
      final List<SankeyDatum> nextTargets = _bucket(
        expenseNodes,
        _maxExpenseNodes,
        otherColor,
      );

      // Balance the two sides so the hub is fully covered: surplus becomes a
      // "Saved" target, a deficit becomes a "From reserves" source.
      final double net = income - expense;
      final double threshold = (income > expense ? income : expense) * 0.001;
      if (net > threshold) {
        nextTargets.add(
          SankeyDatum(
            label: "tabs.stats.analytics.saved".tr(),
            value: net,
            color: incomeColor,
          ),
        );
      } else if (net < -threshold) {
        nextSources.add(
          SankeyDatum(
            label: "tabs.stats.analytics.cashFlow.fromReserves".tr(),
            value: -net,
            color: expenseColor,
          ),
        );
      }

      sources = nextSources;
      targets = nextTargets;
      totalIncome = income;
      totalExpense = expense;
      missingRates = missing;
    } catch (_) {
      // Aggregation should be resilient to bad data now, but never leave the
      // page silently showing zeros if something unexpected throws.
      error = true;
      sources = [];
      targets = [];
      totalIncome = 0.0;
      totalExpense = 0.0;
    } finally {
      busy = false;
      failed = error;
      if (mounted) setState(() {});
    }
  }

  /// Keeps the top [max] nodes by value and rolls the rest into "Other".
  List<SankeyDatum> _bucket(
    List<SankeyDatum> nodes,
    int max,
    Color otherColor,
  ) {
    final List<SankeyDatum> sorted = [...nodes]
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.length <= max) return sorted;

    final List<SankeyDatum> top = sorted.take(max - 1).toList();
    final double otherSum = sorted
        .skip(max - 1)
        .fold(0.0, (sum, node) => sum + node.value);

    return [
      ...top,
      SankeyDatum(
        label: "tabs.stats.analytics.other".tr(),
        value: otherSum,
        color: otherColor,
      ),
    ];
  }
}

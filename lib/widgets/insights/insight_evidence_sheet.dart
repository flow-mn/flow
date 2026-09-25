import "package:flow/data/insights/insight_engine.dart";
import "package:flow/data/insights/insight_thresholds.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/insights_preferences.dart";
import "package:flow/services/transactions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flow/widgets/insights/insight_actions.dart";
import "package:flow/widgets/insights/insight_driver_tile.dart";
import "package:flow/widgets/insights/insight_formatter.dart";
import "package:flow/widgets/insights/insight_history_chart.dart";
import "package:flow/widgets/insights/insight_summary.dart";
import "package:flow/widgets/stats/emphasized_text.dart";
import "package:flow/widgets/transaction_list_tile.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// The math behind one Worth knowing row: its history against the usual,
/// what moved it, and the rule that fired.
class InsightEvidenceSheet extends StatefulWidget {
  final Insight insight;
  final InsightReport report;
  final InsightFormatter format;

  const InsightEvidenceSheet({
    super.key,
    required this.insight,
    required this.report,
    required this.format,
  });

  @override
  State<InsightEvidenceSheet> createState() => _InsightEvidenceSheetState();
}

class _InsightEvidenceSheetState extends State<InsightEvidenceSheet> {
  static const String _prefix = "tabs.stats.worthKnowing";
  static const int _maxChargeBars = 8;

  late final List<Transaction> transactions;

  Insight get insight => widget.insight;
  InsightFormatter get format => widget.format;

  @override
  void initState() {
    super.initState();

    final List<String> uuids = insight.transactionUuids
        .take(InsightThresholds.maxEvidenceTransactions)
        .toList();
    final Map<String, Transaction> found = {
      for (final Transaction transaction in TransactionsService().findManySync(
        TransactionFilter(uuids: uuids),
      ))
        transaction.uuid: transaction,
    };

    transactions = uuids.map((uuid) => found[uuid]).nonNulls.toList();
  }

  @override
  Widget build(BuildContext context) {
    final InsightSummary summary = InsightSummary.of(
      context,
      insight: insight,
      report: widget.report,
      format: format,
    );
    final String? transactionsPath = InsightActions.transactionsPath(
      context,
      insight,
      widget.report,
    );
    final List<InsightChartBar>? bars = _bars();
    final List<InsightCategoryDelta> drivers = switch (insight) {
      MonthPaceInsight pace => pace.drivers,
      _ => const [],
    };

    return ModalSheet.scrollable(
      trailing: ModalOverflowBar(
        alignment: .end,
        children: [
          TextButton.icon(
            onPressed: _hide,
            icon: const Icon(Symbols.visibility_off_rounded),
            label: Text("$_prefix.hide.${insight.type.name}".t(context)),
          ),
          if (insight case RecurringChargeInsight recurring)
            TextButton.icon(
              onPressed: () => _track(recurring.series),
              icon: const Icon(Symbols.add_rounded),
              label: Text("$_prefix.track".t(context)),
            )
          else if (transactionsPath != null)
            TextButton.icon(
              onPressed: () => context.push(transactionsPath),
              icon: const Icon(Symbols.list_rounded),
              label: Text("$_prefix.seeTransactions".t(context)),
            ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Frame(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Symbols.help_rounded,
                        color: context.colorScheme.primary,
                        size: 18.0,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          "$_prefix.why".t(context).toUpperCase(),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.flowColors.semi,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  DefaultTextStyle.merge(
                    style: context.textTheme.titleSmall?.copyWith(height: 1.35),
                    child: EmphasizedText(
                      template: summary.template,
                      value: summary.value,
                      valueStyle: TextStyle(
                        color: summary.valueColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    summary.detail,
                    style: context.textTheme.labelMedium?.semi(context),
                  ),
                  if (bars != null) ...[
                    const SizedBox(height: 16.0),
                    Surface(
                      builder: (context) => Padding(
                        padding: const EdgeInsets.fromLTRB(
                          14.0,
                          14.0,
                          14.0,
                          10.0,
                        ),
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              _chartCaption(),
                              style: context.textTheme.labelMedium?.semi(
                                context,
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            InsightHistoryChart(
                              bars: bars,
                              reference: _reference(),
                              referenceLabel: _referenceLabel(),
                              formatAmount: format.money,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (drivers.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              Frame(
                child: Text(
                  "$_prefix.whatMovedIt".t(context),
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              for (final InsightCategoryDelta driver in drivers)
                InsightDriverTile(
                  driver: driver,
                  month: widget.report.month,
                  format: format,
                ),
            ],
            if (transactions.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              Frame(
                child: Text(
                  _transactionsTitle(drivers.isNotEmpty),
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              for (final Transaction transaction in transactions)
                TransactionListTile(
                  transaction: transaction,
                  recoverFromTrashFn: null,
                  moveToTrashFn: null,
                  combineTransfers: false,
                  groupRange: .month,
                ),
            ],
            const SizedBox(height: 16.0),
            Frame(
              child: Text(
                [_rule(), "$_prefix.rule.footer".t(context)].join(" "),
                style: context.textTheme.labelMedium?.semi(context),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  List<InsightChartBar> _monthBars(
    List<InsightMonthValue> history,
    double current,
  ) => [
    for (final InsightMonthValue value in history)
      (
        label: value.month.toMoment().format("MMM"),
        amount: value.amount,
        muted: !value.counted,
      ),
    (
      label: widget.report.month.toMoment().format("MMM"),
      amount: current,
      muted: false,
    ),
  ];

  List<InsightChartBar> _chargeBars(RecurringSeries series) => [
    for (final RecurringOccurrence occurrence
        in series.occurrences.reversed.take(_maxChargeBars).toList().reversed)
      (
        label: occurrence.date.toMoment().format("MMM D"),
        amount: occurrence.amount,
        muted: false,
      ),
  ];

  List<InsightChartBar>? _bars() => switch (insight) {
    MonthPaceInsight pace => _monthBars(pace.history, pace.current),
    CategorySpikeInsight spike => _monthBars(spike.history, spike.current),
    CategoryDropInsight drop => _monthBars(drop.history, drop.current),
    NewCategoryInsight() => null,
    RecurringChargeInsight recurring => _chargeBars(recurring.series),
    PriceChangeInsight priceChange => _chargeBars(priceChange.series),
  };

  double _reference() => switch (insight) {
    MonthPaceInsight pace => pace.usual,
    CategorySpikeInsight spike => spike.usual,
    CategoryDropInsight drop => drop.usual,
    NewCategoryInsight() => 0.0,
    RecurringChargeInsight recurring => recurring.series.typicalAmount,
    PriceChangeInsight priceChange => priceChange.previousAmount,
  };

  String _referenceLabel() =>
      "$_prefix.${switch (insight) {
            PriceChangeInsight() => "chartBefore",
            _ => "chartUsual",
          }}"
          .t(context, {"amount": format.money(_reference())});

  int? get _throughDay => switch (insight) {
    MonthPaceInsight pace => pace.throughDay,
    CategoryDropInsight drop => drop.throughDay,
    _ => null,
  };

  String _chartCaption() {
    if (insight is RecurringChargeInsight || insight is PriceChangeInsight) {
      return "$_prefix.chartCharges".t(context);
    }

    return switch (_throughDay) {
      int day => "$_prefix.chartThroughDay".t(
        context,
        InsightSummary.dayValues(day),
      ),
      null => "$_prefix.chartMonthly".t(context),
    };
  }

  String _transactionsTitle(bool hasDrivers) =>
      "$_prefix.${switch (insight) {
            RecurringChargeInsight() || PriceChangeInsight() => "charges",
            _ when hasDrivers => "biggestEntries",
            _ => "whatMovedIt",
          }}"
          .t(context);

  String _rule() {
    final int months = InsightThresholds.baselineMonths;

    return switch (insight) {
      MonthPaceInsight(throughDay: int day) =>
        "$_prefix.rule.monthPace".t(context, {
          "date": DateTime(
            widget.report.month.year,
            widget.report.month.month,
            day,
          ).toMoment().format("MMM D"),
          "months": months,
        }),
      MonthPaceInsight() => "$_prefix.rule.monthPacePast".t(context, {
        "month": widget.report.month.toMoment().format("MMMM"),
        "months": months,
      }),
      CategorySpikeInsight() => "$_prefix.rule.categorySpike".t(context, {
        "ratio": format.ratio(InsightThresholds.categorySpikeRatio),
        "count": InsightThresholds.categorySpikeMinEntries,
        "months": months,
      }),
      CategoryDropInsight() => "$_prefix.rule.categoryDrop".t(context, {
        "percent": format.percent(InsightThresholds.categoryDropRatio),
      }),
      NewCategoryInsight() => "$_prefix.rule.newCategory".t(context, {
        "months": months,
      }),
      RecurringChargeInsight() => "$_prefix.rule.recurringCharge".t(context),
      PriceChangeInsight() => "$_prefix.rule.priceChange".t(context, {
        "percent": format.percent(InsightThresholds.priceChangeMinRatio),
      }),
    };
  }

  Future<void> _hide() async {
    await InsightsLocalPreferences().setHidden(insight.type, true);
    if (!mounted) return;

    context.showToast(text: "$_prefix.hidden".t(context));
    context.pop();
  }

  void _track(RecurringSeries series) {
    context.pop();
    InsightActions.trackAsRecurring(context, series);
  }
}

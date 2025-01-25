import "dart:ui";

import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/data/flow_standard_report.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/action_card.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/home/stats/info_card_with_delta.dart";
import "package:flow/widgets/home/stats/no_data.dart";
import "package:flow/widgets/home/stats/range_daily_chart.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flow/widgets/trend.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with AutomaticKeepAliveClientMixin {
  TimeRange range = TimeRange.thisMonth();
  FlowStandardReport? report;

  final AutoSizeGroup autoSizeGroup = AutoSizeGroup();

  late bool initiallyAbbreviated;

  bool busy = false;

  @override
  void initState() {
    super.initState();

    fetch();

    initiallyAbbreviated = !LocalPreferences().preferFullAmounts.get();
    LocalPreferences()
        .preferFullAmounts
        .addListener(_updateInitiallyAbbreviated);
  }

  @override
  void dispose() {
    LocalPreferences()
        .preferFullAmounts
        .removeListener(_updateInitiallyAbbreviated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (busy && report == null) {
      return Spinner.center();
    }

    final bool hasData = report != null && report!.currentFlowByDay.isNotEmpty;

    final bool showForecast =
        report?.current.contains(DateTime.now()) == true &&
            report!.currentExpenseSumForecast != null;

    return Column(
      children: [
        Frame.standalone(
          child: TimeRangeSelector(
            initialValue: range,
            onChanged: updateRange,
          ),
        ),
        Expanded(
          child: hasData
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      Frame(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              showForecast
                                  ? "tabs.stats.dailyReport.forecastFor"
                                      .t(context, report!.current.format())
                                  : "tabs.stats.dailyReport.totalExpenseFor"
                                      .t(context, report!.current.format()),
                              style:
                                  context.textTheme.titleSmall?.semi(context),
                            ),
                            Row(
                              children: [
                                MoneyText(
                                  showForecast
                                      ? report!.currentExpenseSumForecast
                                      : report!.expenseSum,
                                  style: context.textTheme.displaySmall,
                                  autoSize: true,
                                  tapToToggleAbbreviation: true,
                                  initiallyAbbreviated: initiallyAbbreviated,
                                ),
                                const SizedBox(width: 8.0),
                                Trend.fromMoney(
                                  current: showForecast
                                      ? report!.currentExpenseSumForecast
                                      : report!.expenseSum,
                                  previous: report!.previousExpenseSum,
                                  invertDelta: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ClipRect(
                        child: Stack(
                          children: [
                            RangeDailyChart(report: report!),
                            if (busy)
                              Positioned.fill(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 2.0,
                                    sigmaY: 2.0,
                                  ),
                                  child: Container(),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Frame(
                        child: Row(
                          children: [
                            Expanded(
                              child: InfoCardWithDelta(
                                title: "tabs.stats.dailyReport.dailyAvgExpense"
                                    .t(context),
                                autoSizeGroup: autoSizeGroup,
                                money: report!.dailyAvgExpenditure,
                                previousMoney:
                                    report!.previousDailyAvgExpenditure,
                                invertDelta: true,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: InfoCardWithDelta(
                                title: "tabs.stats.dailyReport.dailyAvgIncome"
                                    .t(context),
                                autoSizeGroup: autoSizeGroup,
                                money: report!.dailyAvgIncome,
                                previousMoney: report!.previousDailyAvgIncome,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Frame(
                        child: ActionCard(
                          icon: FlowIconData.icon(Symbols.category_rounded),
                          title: "tabs.stats.summaryByCategory".t(context),
                          onTap: () => context.push("/stats/category"),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Frame(
                        child: ActionCard(
                          icon: FlowIconData.icon(Symbols.wallet_rounded),
                          title: "tabs.stats.summaryByAccount".t(context),
                          onTap: () => context.push("/stats/account"),
                        ),
                      ),
                      const SizedBox(height: 96.0),
                    ],
                  ),
                )
              : NoData(),
        ),
      ],
    );
  }

  void updateRange(TimeRange value) {
    range = value;
    fetch();

    if (!mounted) return;
    setState(() {});
  }

  Future<void> fetch() async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      report = await FlowStandardReport.generate(range);
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void _updateInitiallyAbbreviated() {
    initiallyAbbreviated = !LocalPreferences().preferFullAmounts.get();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  bool get wantKeepAlive => true;
}

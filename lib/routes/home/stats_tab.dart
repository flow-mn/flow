import "dart:ui";

import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/flow_report.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/home/home/info_card.dart";
import "package:flow/widgets/home/stats/range_daily_chart.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flutter/material.dart";
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

  bool busy = false;

  @override
  void initState() {
    super.initState();

    fetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (busy && report == null) {
      return Spinner.center();
    }

    final bool hasData = report != null && report!.currentFlowByDay.isNotEmpty;

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
                  primary: true,
                  child: Column(
                    children: [
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
                      const SizedBox(height: 96.0),
                      Frame(
                        child: Row(
                          children: [
                            Expanded(
                              child: InfoCard(
                                title: "Avg. daily expense",
                                moneyText: MoneyText(
                                  report!.dailyAvgExpenditure,
                                  tapToToggleAbbreviation: true,
                                  autoSizeGroup: autoSizeGroup,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: InfoCard(
                                title: "Avg. daily income",
                                moneyText: MoneyText(
                                  report!.dailyAvgIncome,
                                  tapToToggleAbbreviation: true,
                                  autoSizeGroup: autoSizeGroup,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Frame(
                        child: Row(
                          children: [
                            Expanded(
                              child: InfoCard(
                                title:
                                    "Forecast for ${report!.current.format()}",
                                moneyText: MoneyText(
                                  report!.currentExpenseSumForecast,
                                  tapToToggleAbbreviation: true,
                                  autoSizeGroup: autoSizeGroup,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: InfoCard(
                                title: "Avg. daily flow",
                                moneyText: MoneyText(
                                  report!.dailyAvgFlow,
                                  tapToToggleAbbreviation: true,
                                  autoSizeGroup: autoSizeGroup,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Text("No data to show"),
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

  @override
  bool get wantKeepAlive => true;
}

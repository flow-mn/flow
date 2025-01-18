import "dart:math" as math;

import "package:fl_chart/fl_chart.dart";
import "package:flow/data/flow_report.dart";
import "package:flow/data/money.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  FlowStandardReport? report;
  LineChartData? dailyExpenditureChartData;

  bool busy = false;

  @override
  void initState() {
    super.initState();

    fetch();
  }

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return const Spinner.center();
    }

    return SingleChildScrollView(
      primary: true,
      child: Column(
        children: [
          if (dailyExpenditureChartData != null)
            Container(
              height: 300.0,
              padding: EdgeInsets.all(16.0),
              child: LineChart(dailyExpenditureChartData!),
            ),
        ],
      ),
    );
  }

  Future<void> fetch() async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      report = await ObjectBox().generateReport();
      dailyExpenditureChartData = prepareDailyExpenseChartData(report);
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  LineChartData? prepareDailyExpenseChartData(FlowStandardReport? report) {
    if (report == null) return null;

    final int maxDays = math.max(report.current.from.endOfMonth().day,
        report.previous?.from.endOfMonth().day ?? 0);
    final bool hasPrevious = report.previousFlowByDay != null;

    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    return LineChartData(
      minX: 1.0,
      maxX: maxDays.toDouble(),
      minY: 0.0,
      maxY: report.dailyMaxExpenditure.amount.abs(),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              final textStyle = TextStyle(
                color: touchedSpot.bar.color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              );
              final amount =
                  Money(touchedSpot.y, primaryCurrency).formattedCompact;
              return LineTooltipItem(amount, textStyle);
            }).toList();
          },
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) => Text(
              (1 + value.toInt()).toString(),
            ),
            interval: 5.0,
            minIncluded: true,
            maxIncluded: false,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) => Text(
              Money(value, primaryCurrency).formattedCompact,
            ),
            reservedSize: 48.0,
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        horizontalInterval: 5.0,
        verticalInterval: report.dailyAvgExpenditure.amount.abs(),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.onSurface.withAlpha(0x40),
            width: 2.0,
          ),
          left: BorderSide(
            color: context.colorScheme.onSurface.withAlpha(0x40),
            width: 2.0,
          ),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          barWidth: 2.0,
          color: context.colorScheme.primary,
          dotData: FlDotData(show: false),
          isStrokeCapRound: true,
          spots: List.generate(
            maxDays,
            (index) {
              return FlSpot(
                index.toDouble(),
                report.dailyExpenditure[index + 1]?.abs() ?? 0.0,
              );
            },
          ),
        ),
        if (hasPrevious)
          LineChartBarData(
            isCurved: true,
            barWidth: 2.0,
            color: context.colorScheme.primary.withAlpha(0x40),
            dotData: FlDotData(show: false),
            isStrokeCapRound: true,
            spots: List.generate(
              maxDays,
              (index) => FlSpot(
                index.toDouble(),
                report.previousDailyExpenditure?[index + 1]?.abs() ?? 0,
              ),
            ),
          ),
      ],
    );
  }
}

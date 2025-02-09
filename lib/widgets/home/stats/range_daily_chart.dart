import "dart:math" as math;

import "package:auto_size_text/auto_size_text.dart";
import "package:fl_chart/fl_chart.dart";
import "package:flow/data/flow_standard_report.dart";
import "package:flow/data/money.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/chart_legend.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:moment_dart/moment_dart.dart";

/// Shows daily expenes for the given [FlowStandardReport].
///
/// Recommended time range is weeks, months. Not tested for anything else.
class RangeDailyChart extends StatefulWidget {
  final FlowStandardReport report;

  final double height;

  final bool showLegend;

  const RangeDailyChart({
    super.key,
    required this.report,
    this.height = 300.0,
    this.showLegend = true,
  });

  @override
  State<RangeDailyChart> createState() => _RangeDailyChartState();
}

class _RangeDailyChartState extends State<RangeDailyChart> {
  final AutoSizeGroup autoSizeGroup = AutoSizeGroup();

  LineChartData? dailyExpenditureChartData;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      dailyExpenditureChartData = prepareDailyExpenseChartData(widget.report);
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(RangeDailyChart oldWidget) {
    if (oldWidget.report != widget.report) {
      dailyExpenditureChartData = prepareDailyExpenseChartData(widget.report);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = Container(
      height: widget.height,
      padding: EdgeInsets.all(16.0),
      child: dailyExpenditureChartData == null
          ? Spinner.center()
          : LineChart(dailyExpenditureChartData!),
    );

    final String? previousLabel = widget.report.previous?.format();

    if (!widget.showLegend || previousLabel == null) {
      return child;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 12.0),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            ChartLegend(
              color: context.colorScheme.primary,
              label: widget.report.current.format(),
            ),
            ChartLegend(
              color: context.colorScheme.primary.withAlpha(0x40),
              label: previousLabel,
            ),
          ],
        ),
      ],
    );
  }

  LineChartData? prepareDailyExpenseChartData(FlowStandardReport? report) {
    if (report == null) return null;

    final int maxDays = calculateMaxDays(report.current);
    final bool hasPrevious = report.previousFlowByDay != null;

    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    final Color currentPeriod = context.colorScheme.primary;
    final Color previousPeriod = context.colorScheme.primary.withAlpha(0x40);

    final Color textColor = context.colorScheme.onPrimary;

    return LineChartData(
      minX: 0.0,
      maxX: maxDays.toDouble(),
      minY: 0.0,
      // maxY: report.dailyMaxExpenditure.amount.abs(),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipColor: (touchedSpot) => textColor,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              final TextStyle textStyle = TextStyle(
                color: touchedSpot.bar.color,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              );
              final String amount =
                  Money(touchedSpot.y, primaryCurrency).formattedCompact;
              return LineTooltipItem(amount, textStyle);
            }).toList();
          },
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles(report),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) => MoneyText(
              Money(value, primaryCurrency),
              initiallyAbbreviated: true,
              tapToToggleAbbreviation: false,
              autoSize: true,
              autoSizeGroup: autoSizeGroup,
              displayAbsoluteAmount: true,
            ),
            reservedSize: 48.0,
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: gridData(report),
      extraLinesData: ExtraLinesData(horizontalLines: [
        HorizontalLine(
          y: report.dailyAvgExpenditure.amount.abs(),
          color: context.colorScheme.primary.withAlpha(0x40),
          label: HorizontalLineLabel(
            style: TextStyle(
              color: context.colorScheme.primary.withAlpha(0xc0),
              fontSize: 12.0,
            ),
            alignment: Alignment.topRight,
            labelResolver: (p0) =>
                Money(p0.y, primaryCurrency).formattedCompact,
            show: true,
          ),
        ),
      ]),
      borderData: borderData,
      lineBarsData: [
        LineChartBarData(
          barWidth: 2.0,
          color: currentPeriod,
          dotData: FlDotData(show: false),
          isStrokeCapRound: true,
          spots: List.generate(
            maxDays,
            (index) {
              return FlSpot(
                index.toDouble(),
                report.dailyExpenditure[index]?.abs() ?? 0.0,
              );
            },
          ),
        ),
        if (hasPrevious)
          LineChartBarData(
            barWidth: 2.0,
            color: previousPeriod,
            dotData: FlDotData(show: false),
            isStrokeCapRound: true,
            spots: List.generate(
              maxDays,
              (index) => FlSpot(
                index.toDouble(),
                report.previousDailyExpenditure?[index]?.abs() ?? 0,
              ),
            ),
          ),
      ],
    );
  }

  FlBorderData get borderData => FlBorderData(
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
          right: BorderSide.none,
          top: BorderSide.none,
        ),
      );

  int calculateMaxDays(TimeRange range) => switch (range) {
        DayTimeRange() => 1,
        MonthTimeRange() => math.max(
            range.from.endOfMonth().day,
            range.last.from.endOfMonth().day,
          ),
        TimeRange other => other.duration.inDays
      };

  FlGridData gridData(FlowStandardReport report) {
    final double verticalInterval = switch (report.current) {
      DayTimeRange() => 1.0,
      MonthTimeRange() => 5.0,
      YearTimeRange() => 30.0,
      _ => math.max((report.current.duration.inDays / 7.0).floorToDouble(), 1),
    };

    // final double horizontalInterval = report.dailyAvgExpenditure.amount.abs();

    return FlGridData(
      show: true,
      // horizontalInterval: horizontalInterval > 0 ? horizontalInterval : null,
      verticalInterval: verticalInterval,
    );
  }

  SideTitles bottomTitles(FlowStandardReport report) {
    return switch (report.current) {
      MonthTimeRange() => SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) =>
              Text((value + 1.0).toStringAsFixed(0)),
          interval: 3,
          minIncluded: true,
          maxIncluded: false,
        ),
      YearTimeRange yearTimeRange => SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final int month = yearTimeRange.from.isLeapYear
                ? [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 303, 333]
                    .indexOf(value.toInt())
                : [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 302, 332]
                    .indexOf(value.toInt());

            if (month < 0) return const SizedBox.shrink();

            return Text(DateTime(1970, month + 1).toMoment().format("MMM"));
          },
          interval: 1,
          minIncluded: true,
          maxIncluded: true,
        ),
      _ => SideTitles(showTitles: false),
    };
  }
}

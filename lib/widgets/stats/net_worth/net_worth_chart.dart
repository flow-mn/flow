import "dart:math" as math;

import "package:fl_chart/fl_chart.dart";
import "package:flow/data/money.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/stats/net_worth/net_worth_sample.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

/// The net worth trend line for a sequence of [NetWorthSample]s spaced by
/// [unit]. Frames itself to the data range so variation is visible, and only
/// draws a zero baseline when the range actually crosses zero.
class NetWorthChart extends StatelessWidget {
  final List<NetWorthSample> samples;
  final DurationUnit unit;
  final String primaryCurrency;

  const NetWorthChart({
    super.key,
    required this.samples,
    required this.unit,
    required this.primaryCurrency,
  });

  /// Bottom-axis label format for the sampling [unit]. Kept short so adjacent
  /// labels never collapse to the same string within the window.
  String get _axisFormat => switch (unit) {
    DurationUnit.microsecond ||
    DurationUnit.millisecond ||
    DurationUnit.second ||
    DurationUnit.minute ||
    DurationUnit.hour => "HH:mm",
    DurationUnit.day || DurationUnit.week => "MMM D",
    DurationUnit.month => "MMM",
    DurationUnit.year => "YYYY",
  };

  /// Tooltip format for the sampling [unit]. Always disambiguates the year so
  /// the tooltip never reads as a bare repeated "2026".
  String get _tooltipFormat => switch (unit) {
    DurationUnit.microsecond ||
    DurationUnit.millisecond ||
    DurationUnit.second ||
    DurationUnit.minute ||
    DurationUnit.hour => "MMM D, HH:mm",
    DurationUnit.day || DurationUnit.week => "MMM D, YYYY",
    DurationUnit.month => "MMM YYYY",
    DurationUnit.year => "YYYY",
  };

  @override
  Widget build(BuildContext context) {
    final Color line = context.colorScheme.primary;

    final double maxY = samples
        .map((s) => s.amount)
        .reduce((a, b) => a > b ? a : b);
    final double minY = samples
        .map((s) => s.amount)
        .reduce((a, b) => a < b ? a : b);

    // Frame the chart to the actual data range (plus a little padding) so a
    // net worth that stays positive still shows its variation instead of
    // being flattened against a 0 baseline. The 0 line is drawn separately
    // only when the range actually crosses zero.
    final double span = (maxY - minY).abs();
    final double pad = span == 0 ? maxY.abs() * 0.1 + 1 : span * 0.12;
    final double resolvedMinY = minY - pad;
    final double resolvedMaxY = maxY + pad;

    return LineChart(
      LineChartData(
        minX: 0.0,
        maxX: (samples.length - 1).toDouble(),
        minY: resolvedMinY,
        maxY: resolvedMaxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) => context.colorScheme.onPrimary,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final NetWorthSample sample = samples[spot.x.toInt()];
                return LineTooltipItem(
                  "${sample.anchor.toMoment().format(_tooltipFormat)}\n"
                  "${Money(sample.amount, primaryCurrency).formattedCompact}",
                  TextStyle(
                    color: line,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                  ),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: _bottomTitles()),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48.0,
              getTitlesWidget: (value, meta) {
                if (value != meta.min && value != meta.max) {
                  return const SizedBox.shrink();
                }
                return MoneyText(
                  Money(value, primaryCurrency),
                  initiallyAbbreviated: true,
                  autoSize: true,
                  style: context.textTheme.labelSmall,
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (resolvedMinY < 0)
              HorizontalLine(
                y: 0.0,
                color: context.colorScheme.onSurface.withAlpha(0x30),
                strokeWidth: 1.0,
              ),
          ],
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
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            barWidth: 2.5,
            color: line,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            spots: samples
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.amount))
                .toList(),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [line.withAlpha(0x40), line.withAlpha(0x00)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SideTitles _bottomTitles() {
    // Aim for ~4 labels regardless of window length.
    final int step = math.max(1, (samples.length / 4).floor());

    return SideTitles(
      showTitles: true,
      interval: 1.0,
      reservedSize: 28.0,
      getTitlesWidget: (value, meta) {
        final int index = value.round();
        if (index < 0 || index >= samples.length) {
          return const SizedBox.shrink();
        }
        if (index % step != 0 && index != samples.length - 1) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            samples[index].anchor.toMoment().format(_axisFormat),
            style: const TextStyle(fontSize: 11.0),
          ),
        );
      },
    );
  }
}

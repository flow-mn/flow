import "dart:math" as math;

import "package:fl_chart/fl_chart.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

/// One bar in an [InsightHistoryChart].
typedef InsightChartBar = ({String label, double amount, bool muted});

/// Bars for past values with the latest one highlighted, and a dashed line
/// at the [reference] value (usually the median).
class InsightHistoryChart extends StatelessWidget {
  /// Oldest first. The last one is highlighted.
  final List<InsightChartBar> bars;

  final double reference;
  final String referenceLabel;

  /// Formats amounts for the tooltip.
  final String Function(double amount) formatAmount;

  final double height;

  const InsightHistoryChart({
    super.key,
    required this.bars,
    required this.reference,
    required this.referenceLabel,
    required this.formatAmount,
    this.height = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    final double maxAmount = bars.fold(
      reference,
      (max, bar) => math.max(max, bar.amount),
    );
    final Color base = context.colorScheme.onSurface.withAlpha(0x33);
    final Color muted = context.colorScheme.onSurface.withAlpha(0x14);

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double barWidth =
              (constraints.maxWidth / math.max(bars.length, 1) * 0.6).clamp(
                4.0,
                28.0,
              );

          return BarChart(
            BarChartData(
              minY: 0.0,
              maxY: maxAmount <= 0.0 ? 1.0 : maxAmount * 1.2,
              alignment: .spaceAround,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipColor: (_) => context.colorScheme.onSurface,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                      BarTooltipItem(
                        formatAmount(rod.toY),
                        TextStyle(
                          color: context.colorScheme.surface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20.0,
                    getTitlesWidget: (value, meta) {
                      final int index = value.toInt();
                      if (index < 0 || index >= bars.length) {
                        return const SizedBox.shrink();
                      }

                      final bool last = index == bars.length - 1;

                      return Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          bars[index].label,
                          maxLines: 1,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: last ? null : context.flowColors.semi,
                            fontWeight: last ? FontWeight.w600 : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: reference,
                    color: context.colorScheme.onSurface.withAlpha(0x8c),
                    strokeWidth: 1.5,
                    dashArray: [4, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(bottom: 2.0),
                      style: context.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      labelResolver: (_) => referenceLabel,
                    ),
                  ),
                ],
              ),
              barGroups: [
                for (final (int index, InsightChartBar bar) in bars.indexed)
                  BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: bar.amount,
                        width: barWidth,
                        color: index == bars.length - 1
                            ? context.colorScheme.primary
                            : bar.muted
                            ? muted
                            : base,
                        borderRadius: const .vertical(
                          top: Radius.circular(5.0),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

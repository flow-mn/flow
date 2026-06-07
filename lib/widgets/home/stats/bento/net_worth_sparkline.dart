import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";

/// A minimal, axis-less net worth trend line for the bento net worth tile.
class NetWorthSparkline extends StatelessWidget {
  final List<double> samples;
  final Color color;

  const NetWorthSparkline({
    super.key,
    required this.samples,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double maxY = samples.reduce((a, b) => a > b ? a : b);
    final double minY = samples.reduce((a, b) => a < b ? a : b);
    final double span = (maxY - minY).abs();
    final double pad = span == 0 ? (maxY.abs() * 0.1 + 1.0) : span * 0.15;

    return LineChart(
      LineChartData(
        minX: 0.0,
        maxX: (samples.length - 1).toDouble(),
        minY: minY - pad,
        maxY: maxY + pad,
        lineTouchData: const LineTouchData(enabled: false),
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            barWidth: 2.5,
            color: color,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            spots: samples
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList(),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withAlpha(0x40), color.withAlpha(0x00)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

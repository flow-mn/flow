import "package:fl_chart/fl_chart.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class FlowSeparateLineChart extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  final List<Transaction> transactions;

  const FlowSeparateLineChart({
    super.key,
    required this.transactions,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<FlowSeparateLineChart> createState() => _FlowSeparateLineChartState();
}

class _FlowSeparateLineChartState extends State<FlowSeparateLineChart> {
  late List<Transaction> transactions;
  late LineChartData data;

  @override
  void initState() {
    super.initState();

    transactions = widget.transactions;
  }

  @override
  void didChangeDependencies() {
    updateData();

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(FlowSeparateLineChart oldWidget) {
    transactions = widget.transactions;

    updateData();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      data,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 250),
    );
  }

  void updateData() {
    final List<FlSpot> incomeSpots = transactions.incomes
        .map(
          (e) => FlSpot(
            e.transactionDate.microsecondsSinceEpoch.toDouble(),
            e.amount,
          ),
        )
        .toList();

    final List<FlSpot> expenseSpots = transactions.expenses
        .map(
          (e) => FlSpot(
            e.transactionDate.microsecondsSinceEpoch.toDouble(),
            e.amount.abs(),
          ),
        )
        .toList();

    data = LineChartData(
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
        bottomTitles: AxisTitles(
          drawBelowEverything: false,
          sideTitles: SideTitles(
            reservedSize: 18.0,
            showTitles: true,
            interval: const Duration(days: 1).inMicroseconds.toDouble(),
            getTitlesWidget: (value, meta) => Text(
              value % const Duration(days: 1).inMicroseconds == 0
                  ? Moment.fromMicrosecondsSinceEpoch(value.toInt()).format("D")
                  : "",
              style: context.textTheme.labelSmall?.semi(context),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      clipData: const FlClipData.none(),
      gridData: FlGridData(
        verticalInterval: const Duration(days: 1).inMicroseconds.toDouble(),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => context.colorScheme.surface,
          tooltipPadding: const EdgeInsets.all(4.0),
          fitInsideHorizontally: true,
          fitInsideVertically: true,
        ),
      ),
      minX: widget.startDate.startOfDay().microsecondsSinceEpoch.toDouble(),
      maxX: widget.endDate.endOfDay().microsecondsSinceEpoch.toDouble() + 1,
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          preventCurveOverShooting: true,
          curveSmoothness: 0.25,
          barWidth: 4.0,
          dotData: const FlDotData(show: false),
          color: context.flowColors.expense,
          spots: expenseSpots,
          isStrokeCapRound: true,
          isStrokeJoinRound: true,
        ),
        LineChartBarData(
          isCurved: true,
          preventCurveOverShooting: true,
          curveSmoothness: 0.25,
          barWidth: 4.0,
          dotData: const FlDotData(show: false),
          color: context.flowColors.income,
          spots: incomeSpots,
          isStrokeCapRound: true,
          isStrokeJoinRound: true,
        ),
      ],
    );
  }
}

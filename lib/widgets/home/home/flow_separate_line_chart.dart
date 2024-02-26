import 'package:fl_chart/fl_chart.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';

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
    );
  }

  void updateData() {
    data = LineChartData(
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      clipData: const FlClipData.all(),
      gridData: FlGridData(
        verticalInterval: const Duration(days: 1).inMicroseconds.toDouble(),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: context.colorScheme.background,
          tooltipPadding: const EdgeInsets.all(4.0),
          fitInsideHorizontally: true,
          fitInsideVertically: true,
        ),
      ),
      minX: widget.startDate.startOfDay().microsecondsSinceEpoch.toDouble(),
      maxX: widget.endDate.endOfDay().microsecondsSinceEpoch.toDouble() + 1,
      lineBarsData: [
        LineChartBarData(
          color: context.flowColors.expense,
          spots: transactions.expenses
              .map(
                (e) => FlSpot(
                  e.transactionDate.microsecondsSinceEpoch.toDouble(),
                  e.amount.abs(),
                ),
              )
              .toList(),
          isStrokeCapRound: true,
          isStrokeJoinRound: true,
        ),
        LineChartBarData(
          color: context.flowColors.income,
          spots: transactions.incomes
              .map(
                (e) => FlSpot(
                  e.transactionDate.microsecondsSinceEpoch.toDouble(),
                  e.amount,
                ),
              )
              .toList(),
          isStrokeCapRound: true,
          isStrokeJoinRound: true,
        ),
      ],
    );
  }
}

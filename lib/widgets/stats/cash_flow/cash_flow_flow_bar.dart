import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

/// Single stacked bar whose income and expense segments are sized by their
/// share of the period's total movement. Degrades gracefully when either side
/// is zero, never dividing by zero.
class CashFlowFlowBar extends StatelessWidget {
  final double income;
  final double expense;

  const CashFlowFlowBar({super.key, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final double total = income + expense;
    final int incomeFlex = total <= 0 ? 1 : (income / total * 1000).round();
    final int expenseFlex = total <= 0 ? 1 : (expense / total * 1000).round();

    final Color incomeColor = context.flowColors.income;
    final Color expenseColor = context.flowColors.expense;

    return ClipRRect(
      borderRadius: .all(Radius.circular(6.0)),
      child: SizedBox(
        height: 12.0,
        child: Row(
          children: [
            Expanded(
              flex: incomeFlex == 0 ? 1 : incomeFlex,
              child: ColoredBox(color: incomeColor),
            ),
            const SizedBox(width: 3.0),
            Expanded(
              flex: expenseFlex == 0 ? 1 : expenseFlex,
              child: ColoredBox(color: expenseColor),
            ),
          ],
        ),
      ),
    );
  }
}

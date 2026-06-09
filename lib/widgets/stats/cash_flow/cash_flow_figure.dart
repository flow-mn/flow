import "package:flow/data/money.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";

/// A colored dot, label, and amount for one side of the cash-flow tile. When
/// [alignEnd] is set the order mirrors so the dot hugs the trailing edge.
class CashFlowFigure extends StatelessWidget {
  final String label;
  final Money money;
  final Color color;
  final bool alignEnd;

  const CashFlowFigure({
    super.key,
    required this.label,
    required this.money,
    required this.color,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget dot = Container(
      width: 8.0,
      height: 8.0,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    final Widget labelText = Text(
      label,
      style: context.textTheme.labelSmall?.semi(context),
    );
    final Widget value = MoneyText(
      money,
      style: context.textTheme.titleSmall?.copyWith(color: color),
      initiallyAbbreviated: true,
    );

    return Row(
      mainAxisSize: .min,
      children: alignEnd
          ? [
              value,
              const SizedBox(width: 8.0),
              labelText,
              const SizedBox(width: 5.0),
              dot,
            ]
          : [
              dot,
              const SizedBox(width: 5.0),
              labelText,
              const SizedBox(width: 8.0),
              value,
            ],
    );
  }
}

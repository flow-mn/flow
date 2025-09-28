import "package:flow/data/money.dart";
import "package:flow/data/prefs/change_visuals.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

/// A widget with little up/down arrow at the end
class Trend extends StatelessWidget {
  final TextStyle? style;

  final double delta;

  final bool expense;

  const Trend({
    super.key,
    required this.delta,
    required this.expense,
    this.style,
  });

  factory Trend.fromMoney({
    Key? key,
    Money? current,
    Money? previous,
    TextStyle? style,
  }) {
    final double hundredPercent = previous?.amount ?? 0;
    final double delta =
        (hundredPercent == 0 ||
            hundredPercent.isNaN ||
            hundredPercent.isInfinite)
        ? 0
        : ((current?.amount ?? 0) - hundredPercent) / hundredPercent.abs();

    return Trend(
      key: key,
      delta: delta,
      expense:
          (current?.amount.isNegative ?? false) ||
          (previous?.amount.isNegative ?? false) ||
          false,
      style: style,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ChangeVisuals changeVisuals = UserPreferencesService().changeVisuals;

    final Color color = switch ((expense, delta.isNegative)) {
      (true, true) =>
        changeVisuals.expenseIncreaseRed
            ? context.flowColors.expense
            : context.flowColors.income,
      (true, false) =>
        changeVisuals.expenseIncreaseRed
            ? context.flowColors.income
            : context.flowColors.expense,
      (false, true) =>
        changeVisuals.incomeIncreaseGreen
            ? context.flowColors.expense
            : context.flowColors.income,
      (false, false) =>
        changeVisuals.incomeIncreaseGreen
            ? context.flowColors.income
            : context.flowColors.expense,
    };

    final String deltaString = "${(delta.abs() * 100).toStringAsFixed(1)}%";

    final TextStyle style = this.style ?? context.textTheme.titleSmall!;

    final bool arrowUp = switch ((expense, delta.isNegative)) {
      (true, true) => changeVisuals.expenseIncreaseUpArrow,
      (true, false) => !changeVisuals.expenseIncreaseUpArrow,
      (false, true) => !changeVisuals.incomeIncreaseUpArrow,
      (false, false) => changeVisuals.incomeIncreaseUpArrow,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4.0,
      children: [
        Icon(
          arrowUp ? Symbols.stat_1_rounded : Symbols.stat_minus_1_rounded,
          size: style.fontSize,
          color: color,
        ),
        Text(deltaString, style: style.copyWith(color: color)),
      ],
    );
  }
}

import "package:flow/data/money.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

/// A widget with little up/down arrow at the end
class Trend extends StatelessWidget {
  final TextStyle? style;

  final double delta;
  final bool invertDelta;

  const Trend({
    super.key,
    required this.delta,
    required this.invertDelta,
    this.style,
  });

  factory Trend.fromMoney({
    Key? key,
    Money? current,
    Money? previous,
    bool invertDelta = false,
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
      invertDelta: invertDelta,
      style: style,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool downtrend = delta.isNegative;

    final Color color =
        downtrend ? context.flowColors.expense : context.flowColors.income;

    final String deltaString = "${(delta.abs() * 100).toStringAsFixed(1)}%";

    final TextStyle style = this.style ?? context.textTheme.titleSmall!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4.0,
      children: [
        Icon(
          (invertDelta ^ downtrend)
              ? Symbols.stat_minus_1_rounded
              : Symbols.stat_1_rounded,
          size: style.fontSize,
          color: color,
        ),
        Text(deltaString, style: style.copyWith(color: color)),
      ],
    );
  }
}

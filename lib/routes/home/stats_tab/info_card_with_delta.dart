import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/money.dart";
import "package:flow/prefs.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/home/home/info_card.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class InfoCardWithDelta extends StatelessWidget {
  final Money money;
  final Money? previousMoney;

  final bool invertDelta;

  final AutoSizeGroup? autoSizeGroup;

  final String title;

  const InfoCardWithDelta({
    super.key,
    required this.money,
    required this.previousMoney,
    required this.autoSizeGroup,
    required this.title,
    this.invertDelta = false,
  });

  @override
  Widget build(BuildContext context) {
    final double hundredPercent = previousMoney?.amount ?? 0;
    final double delta = (hundredPercent == 0 ||
            hundredPercent.isNaN ||
            hundredPercent.isInfinite)
        ? 0
        : (money.amount - hundredPercent) / hundredPercent;

    final String deltaString = "${(delta.abs() * 100).toStringAsFixed(1)}%";

    final bool downtrend = invertDelta ^ delta.isNegative;

    final Color color =
        downtrend ? context.flowColors.expense : context.flowColors.income;

    return InfoCard(
      title: title,
      moneyText: MoneyText(
        money,
        tapToToggleAbbreviation: true,
        initiallyAbbreviated: !LocalPreferences().preferFullAmounts.get(),
        autoSize: true,
        autoSizeGroup: autoSizeGroup,
        style: context.textTheme.displaySmall,
      ),
      delta: delta != 0.0
          ? Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4.0,
              children: [
                Icon(
                  delta.isNegative
                      ? Symbols.arrow_downward
                      : Symbols.arrow_upward,
                  size: context.textTheme.titleSmall!.fontSize,
                  color: color,
                ),
                Text(
                  deltaString,
                  style: context.textTheme.titleSmall!.copyWith(
                    color: color,
                  ),
                )
              ],
            )
          : null,
    );
  }
}

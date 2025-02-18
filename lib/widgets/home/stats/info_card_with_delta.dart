import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/money.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/home/home/info_card.dart";
import "package:flow/widgets/trend.dart";
import "package:flutter/material.dart";

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
      delta: Trend.fromMoney(
        current: money,
        previous: previousMoney,
        invertDelta: invertDelta,
      ),
    );
  }
}

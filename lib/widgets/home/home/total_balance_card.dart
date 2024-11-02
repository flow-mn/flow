import "package:flow/l10n/flow_localizations.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/home/home/analytics_card.dart";
import "package:flutter/material.dart";

class TotalBalanceCard extends StatelessWidget {
  const TotalBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnalyticsCard(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "tabs.home.totalBalance".t(context),
              style: context.textTheme.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Flexible(
              child: Text(
                ObjectBox().getPrimaryCurrencyGrandTotal().moneyCompact,
                style: context.textTheme.displaySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

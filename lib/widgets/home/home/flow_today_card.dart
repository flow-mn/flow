import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/home/home/analytics_card.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class FlowTodayCard extends StatelessWidget {
  final List<Transaction>? transactions;

  const FlowTodayCard({super.key, this.transactions});

  @override
  Widget build(BuildContext context) {
    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    final Money flow = transactions == null
        ? Money(0.0, primaryCurrency)
        : transactions!
            .where((element) =>
                element.transactionDate >= DateTime.now().startOfDay() &&
                element.transactionDate <= DateTime.now())
            .sum;

    return AnalyticsCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "tabs.home.flowToday".t(context),
              style: context.textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Flexible(
              child: MoneyText(
                flow,
                style: context.textTheme.displaySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

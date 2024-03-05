import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/flow_localizations.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/home/home/analytics_card.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';

class FlowTodayCard extends StatelessWidget {
  final List<Transaction>? transactions;

  const FlowTodayCard({super.key, this.transactions});

  @override
  Widget build(BuildContext context) {
    final double flow = transactions == null
        ? 0
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
              child: Text(
                flow.moneyCompact,
                style: context.textTheme.displaySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

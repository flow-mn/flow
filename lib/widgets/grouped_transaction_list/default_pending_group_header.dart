import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:moment_dart/moment_dart.dart";

class DefaultPendingGroupHeader extends StatelessWidget {
  final Map<TimeRange, List<Transaction>>? futureTransactions;

  const DefaultPendingGroupHeader({
    super.key,
    required this.futureTransactions,
  });

  @override
  Widget build(BuildContext context) {
    if (futureTransactions == null || futureTransactions!.isEmpty) {
      return SizedBox.shrink();
    }

    final Map<TimeRange, List<Transaction>> transactions = futureTransactions!;

    final int count = transactions.values.fold<int>(
      0,
      (previousValue, element) => previousValue + element.renderableCount,
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            "tabs.home.upcomingTransactions".t(context, count),
            style: context.textTheme.bodyLarge?.semi(context),
          ),
        ),
        const SizedBox(width: 16.0),
        TextButton(
          onPressed: () => context.push("/transactions/upcoming"),
          child: Text(
            "tabs.home.upcomingTransactions.seeAll".t(context),
          ),
        )
      ],
    );
  }
}

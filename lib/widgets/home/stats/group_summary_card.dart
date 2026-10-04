import "package:flow/data/chart_data.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/chart_data.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flow/widgets/home/stats/group_share_bar.dart";
import "package:flutter/material.dart";

class GroupSummaryCard extends StatelessWidget {
  final Map<String, ChartData> data;
  final Map<String, Color> colors;
  final TransactionType type;
  final bool byCategory;

  const GroupSummaryCard({
    super.key,
    required this.data,
    required this.colors,
    required this.type,
    required this.byCategory,
  });

  @override
  Widget build(BuildContext context) {
    final String currency = data.values.first.money.currency;
    final int transactionCount = data.values.fold(
      0,
      (count, chartData) => count + chartData.transactionCount,
    );

    final String groupCount =
        (byCategory
                ? "tabs.stats.byGroup.categoryCount"
                : "tabs.stats.byGroup.accountCount")
            .t(context, data.length);

    return Surface(
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              (type == TransactionType.income
                      ? "tabs.stats.byGroup.totalEarned"
                      : "tabs.stats.byGroup.totalSpent")
                  .t(context),
              style: context.textTheme.labelMedium,
            ),
            MoneyText(
              Money(data.displayTotal, currency),
              style: context.textTheme.headlineSmall,
            ),
            Text(
              "$groupCount · ${"transactions.count".t(context, transactionCount)}",
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(height: 12.0),
            GroupShareBar(data: data, colors: colors),
          ],
        ),
      ),
    );
  }
}

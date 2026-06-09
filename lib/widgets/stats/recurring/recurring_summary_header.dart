import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/flow_card.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flutter/material.dart";

/// Hero header for the recurring page: the expected recurring [income] and
/// [expense] over the selected range, shown with the universal income/expense
/// [FlowCard]s, plus how many charges are projected.
class RecurringSummaryHeader extends StatelessWidget {
  final Money income;
  final Money expense;
  final int count;

  const RecurringSummaryHeader({
    super.key,
    required this.income,
    required this.expense,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final AutoSizeGroup autoSizeGroup = AutoSizeGroup();

    return Frame(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Expanded(
                child: FlowCard(
                  flow: income,
                  type: TransactionType.income,
                  autoSizeGroup: autoSizeGroup,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: FlowCard(
                  flow: expense,
                  type: TransactionType.expense,
                  autoSizeGroup: autoSizeGroup,
                ),
              ),
            ],
          ),
          if (count > 0) ...[
            const SizedBox(height: 8.0),
            Text(
              "tabs.stats.analytics.recurring.upcomingCharges".t(context, {
                "count": count,
              }),
              style: context.textTheme.bodyMedium?.semi(context),
            ),
          ],
        ],
      ),
    );
  }
}

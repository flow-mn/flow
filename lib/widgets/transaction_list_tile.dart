import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/plated_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:moment_dart/moment_dart.dart';

class TransactionListTile extends StatelessWidget {
  final Transaction transaction;
  final EdgeInsets padding;

  const TransactionListTile({
    super.key,
    required this.transaction,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final bool missingTitle = transaction.title == null;

    return InkWell(
      onTap: () => context.push("/transaction/${transaction.id}"),
      child: Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlatedIcon(
              transaction.category.target?.icon ??
                  Symbols.error_outline_rounded,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    missingTitle
                        ? "transaction.untitledTransaction".t(context)
                        : transaction.title!,
                  ),
                  Text(
                    [
                      transaction.account.target?.name,
                      transaction.transactionDate.format(payload: "LT"),
                    ].join(" • "),
                    style: context.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            _buildAmountText(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountText(BuildContext context) {
    final Color color = transaction.amount > 0
        ? context.flowColors.income
        : context.flowColors.expense;

    return Text(
      transaction.amount.formatMoney(currency: transaction.currency),
      style: context.textTheme.bodyLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

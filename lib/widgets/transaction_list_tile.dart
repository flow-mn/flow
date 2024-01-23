import 'dart:io';

import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/general/plated_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:moment_dart/moment_dart.dart';

class TransactionListTile extends StatelessWidget {
  final Transaction transaction;
  final EdgeInsets padding;

  final VoidCallback deleteFn;

  final Key? dismissibleKey;

  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.deleteFn,
    this.padding = EdgeInsets.zero,
    this.dismissibleKey,
  });

  @override
  Widget build(BuildContext context) {
    final bool missingTitle = transaction.title == null;

    final listTile = InkWell(
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
                        ? "transaction.fallbackTitle".t(context)
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

    return Slidable(
      key: dismissibleKey,
      enabled: kDebugMode || Platform.isIOS,
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => deleteFn(),
            icon: CupertinoIcons.delete,
            backgroundColor: CupertinoColors.destructiveRed,
          )
        ],
      ),
      child: listTile,
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

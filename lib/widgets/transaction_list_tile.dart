import "package:flow/data/flow_icon.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/transfer.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class TransactionListTile extends StatelessWidget {
  final Transaction transaction;
  final EdgeInsets padding;

  final VoidCallback deleteFn;

  final Key? dismissibleKey;

  final bool combineTransfers;

  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.deleteFn,
    required this.combineTransfers,
    this.padding = EdgeInsets.zero,
    this.dismissibleKey,
  });

  @override
  Widget build(BuildContext context) {
    if (combineTransfers &&
        transaction.isTransfer &&
        transaction.amount.isNegative) {
      return Container();
    }

    final bool missingTitle = transaction.title == null;

    final Transfer? transfer =
        transaction.isTransfer ? transaction.extensions.transfer : null;

    final listTile = InkWell(
      onTap: () => context.push("/transaction/${transaction.id}"),
      child: Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlowIcon(
              transaction.isTransfer
                  ? FlowIconData.icon(Symbols.sync_alt_rounded)
                  : transaction.category.target?.icon ??
                      FlowIconData.icon(Symbols.circle_rounded),
              plated: true,
              fill: transaction.category.target != null ? 1.0 : 0.0,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (missingTitle
                        ? "transaction.fallbackTitle".t(context)
                        : transaction.title!),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    [
                      (transaction.isTransfer && combineTransfers)
                          ? "${AccountActions.nameByUuid(transfer!.fromAccountUuid)} → ${AccountActions.nameByUuid(transfer.toAccountUuid)}"
                          : transaction.account.target?.name,
                      transaction.transactionDate.format(payload: "LT"),
                    ].join(" • "),
                    style: context.textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => deleteFn(),
            icon: Symbols.delete_forever_rounded,
            backgroundColor: context.flowColors.expense,
          )
        ],
      ),
      child: listTile,
    );
  }

  Widget _buildAmountText(BuildContext context) {
    return Text(
      transaction.amount.formatMoney(
        currency: transaction.currency,
        takeAbsoluteValue: transaction.isTransfer && combineTransfers,
      ),
      style: context.textTheme.bodyLarge?.copyWith(
        color: transaction.type.color(context),
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

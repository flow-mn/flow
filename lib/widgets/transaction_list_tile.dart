import "package:flow/data/flow_icon.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/transfer.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
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
  final VoidCallback? confirmFn;

  final Key? dismissibleKey;

  final bool combineTransfers;

  final bool obscure;

  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.deleteFn,
    required this.combineTransfers,
    this.padding = EdgeInsets.zero,
    this.obscure = false,
    this.confirmFn,
    this.dismissibleKey,
  });

  @override
  Widget build(BuildContext context) {
    final bool showPendingConfirmation = confirmFn != null &&
        transaction.isPending == true &&
        transaction.transactionDate
            .isPastAnchored(Moment.now().endOfNextMinute());

    if ((combineTransfers || showPendingConfirmation) &&
        transaction.isTransfer &&
        transaction.amount.isNegative) {
      return Container();
    }

    final bool missingTitle = transaction.title == null;

    final Transfer? transfer =
        transaction.isTransfer ? transaction.extensions.transfer : null;

    final Widget listTile = InkWell(
      onTap: () => context.push("/transaction/${transaction.id}"),
      child: Padding(
        padding: padding,
        child: Column(
          children: [
            Row(
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
                          if (transaction.transactionDate.isFuture ||
                              transaction.isPending == true)
                            "transaction.pending".t(context),
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
            if (showPendingConfirmation) ...[
              const SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => confirmFn!(),
                    label: Text("general.confirm".t(context)),
                    icon: Icon(Symbols.check_rounded),
                  )
                ],
              ),
              const SizedBox(height: 12.0),
            ],
          ],
        ),
      ),
    );

    return Slidable(
      key: dismissibleKey,
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          if (confirmFn != null && transaction.transactionDate.isFuture ||
              transaction.isPending == true)
            SlidableAction(
              onPressed: (context) => confirmFn!(),
              icon: Symbols.check_rounded,
              backgroundColor: context.colorScheme.primary,
            ),
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
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: context.textTheme.bodyLarge?.copyWith(
          color: transaction.type.color(context),
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: getAmountText(),
          ),
          if (transaction.transactionDate.isFuture ||
              transaction.isPending == true) ...[
            TextSpan(
              text: " ",
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Symbols.schedule_rounded,
                size: context.textTheme.bodyLarge!.fontSize!,
                fill: 0.0,
                color: context.colorScheme.onSurface.withAlpha(0xc0),
              ),
            )
          ],
        ],
      ),
    );
  }

  String getAmountText() {
    final String text = transaction.money.formatMoney(
      takeAbsoluteValue: transaction.isTransfer && combineTransfers,
    );

    if (obscure) return text.digitsObscured;

    return text;
  }
}

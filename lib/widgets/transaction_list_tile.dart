import "package:flow/data/flow_icon.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/transfer.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/transaction.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class TransactionListTile extends StatelessWidget {
  final Transaction transaction;
  final EdgeInsets padding;

  final VoidCallback deleteFn;
  final Function([bool confirm])? confirmFn;

  final Key? dismissibleKey;

  final bool combineTransfers;

  final bool? overrideObscure;

  /// moment_dart format string
  ///
  /// Defaults to "LT"
  final String dateFormat;

  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.deleteFn,
    required this.combineTransfers,
    this.padding = EdgeInsets.zero,
    this.dateFormat = "LT",
    this.confirmFn,
    this.dismissibleKey,
    this.overrideObscure,
  });

  @override
  Widget build(BuildContext context) {
    final bool showPendingConfirmation =
        confirmFn != null && transaction.confirmable();

    final bool showHoldButton = confirmFn != null && transaction.holdable();

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
                      RichText(
                        text: TextSpan(
                          children: [
                            if (transaction.transactionDate.isFuture) ...[
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Icon(
                                  Symbols.schedule_rounded,
                                  size: context.textTheme.bodyMedium!.fontSize!,
                                  fill: 0.0,
                                  color: transaction.isPending == true
                                      ? context.colorScheme.onSurface
                                          .withAlpha(0xc0)
                                      : context.flowColors.income,
                                ),
                              ),
                              TextSpan(
                                text: " ",
                              ),
                            ],
                            TextSpan(
                              text: (missingTitle
                                  ? "transaction.fallbackTitle".t(context)
                                  : transaction.title!),
                            ),
                          ],
                          style: context.textTheme.bodyMedium,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        [
                          (transaction.isTransfer && combineTransfers)
                              ? "${AccountActions.nameByUuid(transfer!.fromAccountUuid)} → ${AccountActions.nameByUuid(transfer.toAccountUuid)}"
                              : transaction.account.target?.name,
                          transaction.transactionDate
                              .format(payload: dateFormat),
                          if (transaction.transactionDate.isFuture)
                            transaction.isPending == true
                                ? "transaction.pending".t(context)
                                : "transaction.pending.preapproved".t(context),
                        ].join(" • "),
                        style: context.textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                MoneyText(
                  transaction.money,
                  displayAbsoluteAmount:
                      transaction.isTransfer && combineTransfers,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: transaction.type.color(context),
                    fontWeight: FontWeight.bold,
                  ),
                  overrideObscure: overrideObscure,
                ),
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
          if (showPendingConfirmation)
            SlidableAction(
              onPressed: (context) => confirmFn!(),
              icon: Symbols.check_rounded,
              backgroundColor: context.colorScheme.primary,
            ),
          if (showHoldButton)
            SlidableAction(
              onPressed: (context) => confirmFn!(false),
              icon: Symbols.cancel_rounded,
              backgroundColor: context.flowColors.expense,
            ),
          if (!showHoldButton)
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
}

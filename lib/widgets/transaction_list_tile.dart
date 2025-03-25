import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/transfer.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/providers/accounts_provider.dart";
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

  final VoidCallback? recoverFromTrashFn;
  final VoidCallback? moveToTrashFn;
  final VoidCallback? duplicateFn;
  final Function([bool confirm])? confirmFn;

  final Key? dismissibleKey;

  final bool combineTransfers;

  final bool? overrideObscure;

  final bool useCategoryNameForUntitledTransactions;
  final bool useAccountIconForLeading;
  final bool showCategory;

  /// Determines what date/time to show. i.e.:
  ///
  /// * [TransactionGroupRange.hour] - Hour and minute
  /// * [TransactionGroupRange.day] - Hour and minute
  /// * [TransactionGroupRange.week] - Calendar date with hour and minute
  /// * [TransactionGroupRange.month] - Calendar date with hour and minute
  /// * [TransactionGroupRange.year] - Calendar date with hour and minute
  ///
  /// Defaults to [TransactionGroupRange.day]
  final TransactionGroupRange? groupRange;

  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.recoverFromTrashFn,
    required this.moveToTrashFn,
    required this.combineTransfers,
    this.groupRange = TransactionGroupRange.day,
    this.padding = EdgeInsets.zero,
    this.confirmFn,
    this.duplicateFn,
    this.dismissibleKey,
    this.overrideObscure,
    this.useCategoryNameForUntitledTransactions = false,
    this.useAccountIconForLeading = false,
    this.showCategory = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool showPendingConfirmation =
        confirmFn != null && transaction.confirmable();

    final bool showHoldButton = confirmFn != null && transaction.holdable();

    if ((combineTransfers || showPendingConfirmation) &&
        transaction.isTransfer &&
        !transaction.amount.isNegative) {
      return Container();
    }

    final String resolvedTitle =
        transaction.title ??
        ((useCategoryNameForUntitledTransactions
                ? transaction.category.target?.name
                : null) ??
            "transaction.fallbackTitle".t(context));

    final Transfer? transfer =
        transaction.isTransfer ? transaction.extensions.transfer : null;

    final Widget listTile = Material(
      type: MaterialType.card,
      color: kTransparent,
      child: InkWell(
        onTap: () => context.push("/transaction/${transaction.id}"),
        child: Padding(
          padding: padding,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLeading(context),
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
                                    size:
                                        context.textTheme.bodyMedium!.fontSize!,
                                    fill: 0.0,
                                    color:
                                        transaction.isPending == true
                                            ? context.colorScheme.onSurface
                                                .withAlpha(0xc0)
                                            : context.flowColors.income,
                                  ),
                                ),
                                TextSpan(text: " "),
                              ],
                              TextSpan(text: resolvedTitle),
                            ],
                            style: context.textTheme.bodyMedium,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          [
                            (transaction.isTransfer && combineTransfers)
                                ? "${AccountsProvider.of(context).getName(transfer!.fromAccountUuid)} → ${AccountsProvider.of(context).getName(transfer.toAccountUuid)}"
                                : (AccountsProvider.of(
                                      context,
                                    ).getName(transaction.accountUuid) ??
                                    transaction.account.target?.name),
                            if (showCategory &&
                                transaction.category.target != null)
                              transaction.category.target!.name,
                            dateString,
                            if (transaction.transactionDate.isFuture)
                              transaction.isPending == true
                                  ? "transaction.pending".t(context)
                                  : "transaction.pending.preapproved".t(
                                    context,
                                  ),
                          ].join(" • "),
                          style: context.textTheme.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
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
                      if (combineTransfers &&
                          AccountsProvider.of(context).ready &&
                          transaction.extensions.transfer?.conversionRate !=
                              null &&
                          transaction.extensions.transfer?.conversionRate !=
                              1.0)
                        MoneyText(
                          Money(
                            transaction.money.amount *
                                transaction
                                    .extensions
                                    .transfer!
                                    .conversionRate!,
                            AccountsProvider.of(context)
                                .get(
                                  transaction
                                      .extensions
                                      .transfer!
                                      .toAccountUuid,
                                )!
                                .currency,
                          ),
                          displayAbsoluteAmount: true,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurface.withAlpha(
                              0x80,
                            ),
                          ),
                          overrideObscure: overrideObscure,
                        ),
                    ],
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
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
              ],
            ],
          ),
        ),
      ),
    );

    final List<SlidableAction> startActionPanes = [
      if (!transaction.isTransfer && duplicateFn != null)
        SlidableAction(
          onPressed: (context) => duplicateFn!(),
          icon: Symbols.content_copy_rounded,
          backgroundColor: context.flowColors.semi,
        ),
    ];

    final List<SlidableAction> endActionPanes = [
      if (confirmFn != null && transaction.isPending == true)
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
      if (moveToTrashFn != null &&
          !showHoldButton &&
          transaction.isDeleted != true)
        SlidableAction(
          onPressed: (context) => moveToTrashFn!(),
          icon: Symbols.delete_forever_rounded,
          backgroundColor: context.flowColors.expense,
        ),
      if (recoverFromTrashFn != null &&
          !showHoldButton &&
          transaction.isDeleted == true)
        SlidableAction(
          onPressed: (context) => recoverFromTrashFn!(),
          icon: Symbols.restore_page_rounded,
          backgroundColor: context.flowColors.income,
        ),
    ];

    return Slidable(
      key: dismissibleKey,
      groupTag: "transaction_list_tile",
      endActionPane:
          endActionPanes.isNotEmpty
              ? ActionPane(
                motion: const DrawerMotion(),
                children: endActionPanes,
              )
              : null,
      startActionPane:
          startActionPanes.isNotEmpty
              ? ActionPane(
                motion: const DrawerMotion(),
                children: startActionPanes,
              )
              : null,
      child: listTile,
    );
  }

  FlowIcon buildLeading(BuildContext context) {
    late final FlowIconData iconData;

    if (transaction.isTransfer) {
      iconData = FlowIconData.icon(Symbols.sync_alt_rounded);
    } else if (useAccountIconForLeading) {
      iconData =
          AccountsProvider.of(context).get(transaction.accountUuid)?.icon ??
          transaction.account.target?.icon ??
          FlowIconData.icon(Symbols.circle_rounded);
    } else if (transaction.category.target != null) {
      iconData = transaction.category.target!.icon;
    } else {
      iconData = FlowIconData.icon(Symbols.circle_rounded);
    }

    return FlowIcon(
      iconData,
      plated: true,
      fill: transaction.category.target != null ? 1.0 : 0.0,
    );
  }

  String get dateString {
    final DateTime now = Moment.now().startOfNextMinute();

    final bool pending =
        transaction.isPending == true ||
        transaction.transactionDate.isFutureAnchored(now);

    if (pending) return transaction.transactionDate.toMoment().calendar();

    return switch (groupRange) {
      TransactionGroupRange.hour ||
      TransactionGroupRange.day => transaction.transactionDate.toMoment().LT,
      _ => transaction.transactionDate.toMoment().lll,
    };
  }
}

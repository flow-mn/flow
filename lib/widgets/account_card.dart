import "package:flow/data/money_flow.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:moment_dart/moment_dart.dart";

class AccountCard extends StatelessWidget {
  final Account account;

  final Optional<VoidCallback>? onTapOverride;

  final bool useCupertinoContextMenu;

  final bool excludeTransfersInTotal;

  final BorderRadius borderRadius;

  const AccountCard({
    super.key,
    required this.account,
    required this.useCupertinoContextMenu,
    this.onTapOverride,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
    required this.excludeTransfersInTotal,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    final Iterable<Transaction> transactions = account.transactions.nonPending
        .where((x) => x.transactionDate.isAtSameMonthAs(now));

    final MoneyFlow flow = MoneyFlow()
      ..addAll(
        (excludeTransfersInTotal ? transactions.nonTransfers : transactions)
            .map((transaction) => transaction.money),
      );

    final child = Surface(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (context) => InkWell(
        onTap: onTapOverride == null
            ? () => context.push("/account/${account.id}")
            : onTapOverride!.value,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  FlowIcon(
                    account.icon,
                    size: 60.0,
                  ),
                  const SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        account.name,
                        style: context.textTheme.titleSmall,
                      ),
                      MoneyText(
                        account.balance,
                        style: context.textTheme.displaySmall,
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 24.0),
              Text("account.thisMonth".t(context),
                  style: context.textTheme.bodyLarge),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      TransactionType.income.localizedNameContext(context),
                      style: context.textTheme.labelSmall?.semi(context),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      TransactionType.expense.localizedNameContext(context),
                      style: context.textTheme.labelSmall?.semi(context),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: MoneyText(
                      flow.getIncomeByCurrency(account.currency),
                      style: context.textTheme.bodyLarge,
                    ),
                  ),
                  Expanded(
                    child: MoneyText(
                      flow.getExpenseByCurrency(account.currency),
                      style: context.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (!useCupertinoContextMenu) return child;

    return CupertinoContextMenu.builder(
      builder: (context, animation) {
        return Padding(
          padding: const EdgeInsets.all(16.0) * animation.value,
          child: child,
        );
      },
      actions: [
        // TODO Why is it still open? Do I really have to pop, then push?
        CupertinoContextMenuAction(
          onPressed: () => context.push("/account/${account.id}"),
          isDefaultAction: true,
          trailingIcon: CupertinoIcons.pencil,
          child: Text("account.edit".t(context)),
        ),
        CupertinoContextMenuAction(
          onPressed: () => context.push(
              "/account/${account.id}/transactions?title=${"account.transactions.title".t(context, account.name)}"),
          isDefaultAction: true,
          trailingIcon: CupertinoIcons.square_list,
          child: Text("account.transactions".t(context)),
        ),
      ],
    );
  }
}

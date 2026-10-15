import "dart:async";

import "package:flow/data/money.dart";
import "package:flow/data/multi_currency_flow.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/transactions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class AccountCard extends StatefulWidget {
  final Account account;

  final Optional<VoidCallback>? onTapOverride;

  final bool useCupertinoContextMenu;

  final bool excludeTransfersInTotal;

  final bool primary;

  final BorderRadius borderRadius;

  const AccountCard({
    super.key,
    required this.account,
    required this.useCupertinoContextMenu,
    this.onTapOverride,
    this.primary = false,
    this.borderRadius = const .all(Radius.circular(24.0)),
    required this.excludeTransfersInTotal,
  });

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  static const Duration _transactionRefreshDebounce = Duration(
    milliseconds: 300,
  );

  Account get account => widget.account;

  late Money _balance;
  MultiCurrencyFlow _flow = MultiCurrencyFlow();

  Timer? _transactionDebounce;

  @override
  void initState() {
    super.initState();

    _computeStats();
    TransactionsService().addListener(_onTransactionsChanged);
  }

  @override
  void didUpdateWidget(AccountCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.account, widget.account) ||
        oldWidget.excludeTransfersInTotal != widget.excludeTransfersInTotal) {
      _computeStats();
    }
  }

  @override
  void dispose() {
    _transactionDebounce?.cancel();
    TransactionsService().removeListener(_onTransactionsChanged);
    super.dispose();
  }

  void _onTransactionsChanged() {
    _transactionDebounce?.cancel();
    _transactionDebounce = Timer(_transactionRefreshDebounce, () {
      if (!mounted) return;
      setState(_computeStats);
    });
  }

  void _computeStats() {
    _balance = account.balance;

    if (account.archived || account.id <= 0) {
      _flow = MultiCurrencyFlow();
      return;
    }

    final DateTime now = DateTime.now();

    final List<Transaction> transactions = TransactionsService()
        .findSettledBetweenSync(
          Transaction_.account.equals(account.id),
          now.startOfMonth(),
          now.endOfMonth(),
        );

    _flow = MultiCurrencyFlow()
      ..addAll(
        (widget.excludeTransfersInTotal
                ? transactions.nonTransfers
                : transactions)
            .map((transaction) => transaction.money),
      );
  }

  @override
  Widget build(BuildContext context) {
    final Optional<VoidCallback>? onTapOverride = widget.onTapOverride;
    final BorderRadius borderRadius = widget.borderRadius;

    final child = Surface(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (context) => InkWell(
        onTap: onTapOverride == null
            ? () => context.push("/account/${account.id}")
            : onTapOverride.value,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  FlowIcon(
                    account.icon,
                    size: 60.0,
                    colorScheme: account.colorScheme,
                  ),
                  const SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: .start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            if (widget.primary)
                              WidgetSpan(
                                alignment: .middle,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Icon(
                                    Symbols.star_rounded,
                                    size:
                                        context.textTheme.titleSmall?.fontSize,
                                    color: context.colorScheme.primary,
                                  ),
                                ),
                              ),
                            TextSpan(
                              text:
                                  account.name +
                                  (account.archived
                                      ? " (${"account.archived".t(context)})"
                                      : ""),
                            ),
                          ],
                          style: context.textTheme.titleSmall,
                        ),
                      ),

                      MoneyText(
                        _balance,
                        style: context.textTheme.displaySmall,
                      ),
                    ],
                  ),
                ],
              ),
              if (!account.archived) ...[
                const SizedBox(height: 16.0),
                Text(
                  "account.thisMonth".t(context),
                  style: context.textTheme.bodyLarge,
                ),
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
                        _flow.getIncomeByCurrency(account.currency),
                        style: context.textTheme.bodyLarge,
                      ),
                    ),
                    Expanded(
                      child: MoneyText(
                        _flow.getExpenseByCurrency(account.currency),
                        style: context.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!widget.useCupertinoContextMenu) return child;

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
          onPressed: () {
            context.pop();
            SchedulerBinding.instance.addPostFrameCallback((_) {
              context.push("/account/${account.id}/edit");
            });
          },
          isDefaultAction: true,
          trailingIcon: Symbols.edit_rounded,
          child: Text("account.edit".t(context)),
        ),
        CupertinoContextMenuAction(
          onPressed: () {
            context.pop();
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              context.push(
                "/account/${account.id}/transactions?title=${"account.transactions.title".t(context, account.name)}",
              );
            });
          },
          isDefaultAction: true,
          trailingIcon: Symbols.list_rounded,
          child: Text("account.transactions".t(context)),
        ),
      ],
    );
  }
}

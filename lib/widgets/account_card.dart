import 'package:flow/entity/account.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flow/widgets/general/surface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountCard extends StatelessWidget {
  final Account account;

  const AccountCard({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(24.0);

    return CupertinoContextMenu.builder(
      builder: (context, animation) {
        return Padding(
          padding: const EdgeInsets.all(16.0) * animation.value,
          child: Surface(
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            builder: (context) => InkWell(
              onTap: () => context.push("/account/${account.id}"),
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
                            Text(
                              account.balance
                                  .formatMoney(currency: account.currency),
                              style: context.textTheme.displaySmall,
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    Text("This month", style: context.textTheme.bodyLarge),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Income",
                            style: context.textTheme.labelSmall?.semi(context),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Expense",
                            style: context.textTheme.labelSmall?.semi(context),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            account.transactions.incomeSum.formatMoney(
                              currency: account.currency,
                            ),
                            style: context.textTheme.bodyLarge,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            account.transactions.expenseSum.formatMoney(
                              currency: account.currency,
                            ),
                            style: context.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
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
              "/account/${account.id}/transactions?title=${account.name}"),
          isDefaultAction: true,
          trailingIcon: CupertinoIcons.square_list,
          child: Text("account.transactions".t(context)),
        ),
      ],
    );
  }
}

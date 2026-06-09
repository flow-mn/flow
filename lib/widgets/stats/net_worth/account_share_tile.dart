import "package:flow/data/money.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/stats/net_worth/account_balance_share.dart";
import "package:flutter/material.dart";

/// One account row in the net worth "By account" breakdown: an icon, the
/// account name and balance, and a bar sized by the account's share of gross
/// holdings ([gross]). Debts are tinted with the expense color.
class AccountShareTile extends StatelessWidget {
  final AccountBalanceShare share;
  final double gross;
  final String primaryCurrency;

  const AccountShareTile({
    super.key,
    required this.share,
    required this.gross,
    required this.primaryCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final bool negative = share.amount < 0;
    final Color color = negative
        ? context.flowColors.expense
        : context.flowColors.income;
    final double fraction = gross == 0 ? 0.0 : share.amount.abs() / gross;

    return Frame(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            FlowIcon(
              share.account.icon,
              plated: true,
              colorScheme: share.account.colorScheme,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          share.account.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      MoneyText(
                        Money(share.amount, primaryCurrency),
                        style: context.textTheme.titleSmall?.copyWith(
                          color: negative ? color : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  ClipRRect(
                    borderRadius: .all(Radius.circular(4.0)),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 6.0,
                      backgroundColor: context.colorScheme.onSurface.withAlpha(
                        0x14,
                      ),
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money_flow.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:moment_dart/moment_dart.dart";

class CategoryCard extends StatelessWidget {
  final Category category;

  final BorderRadius borderRadius;

  final ExchangeRates? rates;

  final bool excludeTransfersInTotal;

  final bool showAmount;

  final Optional<VoidCallback>? onTapOverride;

  final Widget? trailing;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTapOverride,
    this.trailing,
    this.rates,
    this.showAmount = true,
    this.excludeTransfersInTotal = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    final Iterable<Transaction> transactions = category
        .transactions
        .nonPending
        .nonDeleted
        .where((x) => x.transactionDate.isAtSameMonthAs(now));

    final MoneyFlow flow =
        MoneyFlow()..addAll(
          (excludeTransfersInTotal ? transactions.nonTransfers : transactions)
              .map((transaction) => transaction.money),
        );

    return Surface(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder:
          (context) => InkWell(
            borderRadius: borderRadius,
            onTap:
                onTapOverride == null
                    ? () => context.push("/category/${category.id}")
                    : onTapOverride!.value,
            child: Row(
              children: [
                FlowIcon(category.icon, size: 32.0, plated: true),
                const SizedBox(width: 12.0),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.name, style: context.textTheme.titleSmall),
                    if (showAmount)
                      MoneyText(
                        rates == null
                            ? flow.getFlowByCurrency(primaryCurrency)
                            : flow.getTotalFlow(rates!, primaryCurrency),
                      ),
                  ],
                ),
                const Spacer(),
                if (trailing != null) ...[
                  trailing!,
                  const SizedBox(width: 12.0),
                ],
              ],
            ),
          ),
    );
  }
}

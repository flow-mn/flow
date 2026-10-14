import "package:flow/data/money.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

/// Shows what a foreign currency amount was converted to, along with the rate
class ConvertedAmountButton extends StatelessWidget {
  final Money foreignMoney;

  /// [foreignMoney] in the account's currency
  final Money money;

  final VoidCallback? onTap;

  const ConvertedAmountButton({
    super.key,
    required this.foreignMoney,
    required this.money,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = context.colorScheme.onSurface.withAlpha(0x80);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: .center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4.0,
                children: [
                  Text(
                    "= ${money.formatMoney()}",
                    style: context.textTheme.bodyLarge?.copyWith(color: color),
                  ),
                  Icon(Symbols.edit_rounded, size: 16.0, color: color),
                ],
              ),
              if (rateText(foreignMoney, money) case String rate)
                Text(
                  rate,
                  style: context.textTheme.bodySmall?.copyWith(color: color),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Always shows the rate of the stronger currency, e.g., "1 $ = 3,450 ₮"
  static String? rateText(Money from, Money to) {
    final double fromAmount = from.amount.abs();
    final double toAmount = to.amount.abs();

    if (fromAmount == 0 || toAmount == 0) return null;

    final double rate = toAmount / fromAmount;

    return rate >= 1.0
        ? "${Money(1.0, from.currency).formatMoney()} = ${Money(rate, to.currency).formatMoney()}"
        : "${Money(1.0, to.currency).formatMoney()} = ${Money(1 / rate, from.currency).formatMoney()}";
  }
}

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            if (rateText() case String rate)
              Text(
                rate,
                style: context.textTheme.bodySmall?.copyWith(color: color),
              ),
          ],
        ),
      ),
    );
  }

  /// Always shows the rate of the stronger currency, e.g., "1 $ = 3,450 ₮"
  String? rateText() {
    final double from = foreignMoney.amount.abs();
    final double to = money.amount.abs();

    if (from == 0 || to == 0) return null;

    final double rate = to / from;

    return rate >= 1.0
        ? "${Money(1.0, foreignMoney.currency).formatMoney()} = ${Money(rate, money.currency).formatMoney()}"
        : "${Money(1.0, money.currency).formatMoney()} = ${Money(1 / rate, foreignMoney.currency).formatMoney()}";
  }
}

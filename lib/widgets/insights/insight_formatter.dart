import "package:flow/data/money.dart";
import "package:flow/utils/extensions.dart";

/// Formats insight figures for use inside sentences. Honors privacy mode and
/// the money formatting preferences.
class InsightFormatter {
  final String currency;
  final bool obscure;
  final bool useCurrencySymbol;
  final bool preferFullAmounts;

  const InsightFormatter({
    required this.currency,
    this.obscure = false,
    this.useCurrencySymbol = true,
    this.preferFullAmounts = false,
  });

  /// Cents only matter for small amounts, like a subscription.
  String money(double amount) {
    final double value = amount.abs();
    final Money money = Money(value, currency);

    final String text = !preferFullAmounts && value >= 10000.0
        ? money.formatMoney(compact: true, useCurrencySymbol: useCurrencySymbol)
        : money.formatMoney(
            useCurrencySymbol: useCurrencySymbol,
            decimalDigits: value >= 100.0 ? 0 : null,
          );

    return obscure ? text.digitsObscured : text;
  }

  /// e.g. "27%" for 0.27 or -0.27.
  String percent(double fraction) => fraction.abs().percentInt;

  /// e.g. "1.9×".
  String ratio(double ratio) => "${ratio.toStringAsFixed(1)}×";
}

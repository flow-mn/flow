import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";

extension MoneyConversion on Money {
  /// Converts this amount into [targetCurrency], returning `null` when the
  /// conversion isn't possible — no [rates], or an unsupported currency code —
  /// instead of throwing.
  ///
  /// Same-currency amounts are returned as-is. Analytics call sites treat a
  /// `null` result as "missing data" so a single unconvertible transaction
  /// never aborts a whole aggregation.
  double? tryConvertAmount(String targetCurrency, ExchangeRates? rates) {
    if (currency == targetCurrency) return amount;
    if (rates == null) return null;

    try {
      return convert(targetCurrency, rates).amount;
    } catch (_) {
      return null;
    }
  }
}

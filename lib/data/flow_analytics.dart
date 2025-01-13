import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money_flow.dart";

class FlowAnalytics<T> {
  final DateTime from;
  final DateTime to;

  final Map<String, MultiCurrencyMoneyFlow<T>> flow;

  bool get singleCurrency =>
      flow.values.every((moneyFlow) => moneyFlow.singleCurrency != null);

  const FlowAnalytics({
    required this.from,
    required this.to,
    required this.flow,
  });

  /// Returns a version of [flow] with all currencies converted to a single currency.
  ///
  /// If [currency] is null, uses [rates.baseCurrency]
  Map<String, SingleCurrencyMoneyFlow<T>> mergedFlow(
    ExchangeRates rates, [
    String? currency,
  ]) {
    currency ??= rates.baseCurrency;

    final Map<String, SingleCurrencyMoneyFlow<T>> result = {};

    for (final entry in flow.entries) {
      result[entry.key] = entry.value.merge(rates, currency);
    }

    return result;
  }

  /// Returns result of [mergedFlow] if [rates] is available, else returns only [currency] flow
  Map<String, SingleCurrencyMoneyFlow<T>> relevantFlow(
    String currency,
    ExchangeRates? rates,
  ) {
    if (rates == null) {
      return flow.map(
        (key, value) => MapEntry(
          key,
          value.extractByCurrency(currency),
        ),
      );
    }

    return mergedFlow(rates);
  }
}

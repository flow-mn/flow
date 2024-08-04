import 'package:flow/data/exchange_rates.dart';

class ExchangeRatesSet {
  final Map<String, ExchangeRates> rates;

  ExchangeRatesSet(this.rates);

  void set(String baseCurrency, ExchangeRates exchangeRates) {
    rates[baseCurrency] = exchangeRates;
  }

  ExchangeRates? get(String baseCurrency) {
    return rates[baseCurrency];
  }

  factory ExchangeRatesSet.fromJson(Map<String, dynamic> json) {
    final Map<String, ExchangeRates> rates = {};

    for (final String baseCurrency in json.keys) {
      rates[baseCurrency] = ExchangeRates.fromJson(
        baseCurrency,
        json[baseCurrency],
      );
    }

    return ExchangeRatesSet(rates);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    for (final String baseCurrency in rates.keys) {
      json[baseCurrency] = rates[baseCurrency]!.toJson();
    }

    return json;
  }
}

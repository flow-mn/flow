import "package:flow/data/currencies.dart";
import "package:flow/services/currency_registry.dart";
import "package:moment_dart/moment_dart.dart";

/// Uses endpoints from here:
class ExchangeRates {
  final DateTime date;
  final String baseCurrency;
  final Map<String, num> rates;

  const ExchangeRates({
    required this.date,
    required this.baseCurrency,
    required this.rates,
  });

  factory ExchangeRates.fromJson(Map<String, dynamic> json) {
    final String baseCurrency = json.keys.firstWhere((key) => key != "date");

    return ExchangeRates(
      date: DateTime.parse(json["date"]),
      baseCurrency: baseCurrency,
      rates: Map<String, num>.from(json[baseCurrency.toLowerCase()])
        ..removeWhere((_, rate) => !rate.isFinite || rate <= 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {"date": date.format(payload: "YYYY-MM-DD"), baseCurrency: rates};
  }

  double? getRate(String currency) {
    final CurrencyData? currencyData =
        CurrencyRegistryService().groupedCurrencies[currency];

    if (currencyData == null) {
      return null;
    }

    if (currencyData is CustomCurrencyData) {
      return currencyData.rateFor(baseCurrency.toUpperCase());
    }

    return rates[currency.toLowerCase()]?.toDouble();
  }
}

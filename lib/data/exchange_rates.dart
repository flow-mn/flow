import 'package:moment_dart/moment_dart.dart';

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
      date: DateTime.parse(json['date']),
      baseCurrency: baseCurrency,
      rates: Map<String, num>.from(json[baseCurrency.toLowerCase()]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "date": date.format(payload: "YYYY-MM-DD"),
      baseCurrency: rates,
    };
  }

  double? getRate(String currency) {
    return rates[currency.toLowerCase()]?.toDouble();
  }
}

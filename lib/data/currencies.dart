class CurrencyData {
  /// Three letter [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217) currency code
  final String code;

  /// Country in which the currency is used (in English)
  final String country;

  /// Name of the currency (in English)
  final String name;

  final bool isCrypto;

  final int? decimalDigits;

  const CurrencyData({
    required this.code,
    required this.country,
    required this.name,
    this.isCrypto = false,
    this.decimalDigits,
  });

  const CurrencyData.crypto({
    required this.code,
    required this.name,
    this.decimalDigits,
  }) : isCrypto = true,
       country = "@CRYPTO";
}

class CustomCurrencyData extends CurrencyData {
  /// Function to get the exchange rate for a specific currency
  ///
  /// For example, if you have a custom currency called **DOUBLEUSD**,
  /// this function would return `2` for input of `currency` is 'USD'
  ///
  /// ```dart
  /// CustomCurrencyData(
  ///   code: 'DOUBLEUSD',
  ///   country: 'US',
  ///   name: 'Double USD',
  ///   rateFor: (currency) async {
  ///     final rExchangeRatesService().fetchRates(currency)
  ///   }
  /// )
  /// ```
  final double Function(String currency) rateFor;

  const CustomCurrencyData({
    required super.code,
    required super.country,
    required super.name,
    required this.rateFor,
  });
  const CustomCurrencyData.crypto({
    required super.code,
    required super.name,
    required this.rateFor,
  }) : super.crypto();
}

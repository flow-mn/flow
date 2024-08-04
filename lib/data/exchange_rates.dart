import 'dart:convert';
import 'dart:developer';

import 'package:flow/data/currencies.dart';
import 'package:http/http.dart' as http;
import 'package:moment_dart/moment_dart.dart';

/// Uses endpoints from here:
class ExchangeRates {
  final DateTime date;
  final String baseCurrency;
  final Map<String, double> rates;

  const ExchangeRates({
    required this.date,
    required this.baseCurrency,
    required this.rates,
  });

  factory ExchangeRates.fromJson(
    String baseCurrency,
    Map<String, dynamic> json,
  ) {
    return ExchangeRates(
      date: DateTime.parse(json['date']),
      baseCurrency: baseCurrency,
      rates: Map<String, double>.from(json[baseCurrency.toLowerCase()]),
    );
  }

  static final Map<String, ExchangeRates> _cache = {};

  static Future<ExchangeRates> fetchRates(
    String baseCurrency, [
    DateTime? dateTime,
  ]) async {
    final String normalizedCurrency = baseCurrency.trim().toLowerCase();

    if (!iso4217Currencies
        .any((currency) => currency.code.toLowerCase() == normalizedCurrency)) {
      throw Exception("Invalid currency code: $baseCurrency");
    }

    final String dateParam =
        dateTime == null ? "latest" : dateTime.format(payload: "yyyy-MM-dd");

    Map<String, dynamic>? jsonResponse;

    try {
      final response = await http.get(Uri.parse(
          "https://$dateParam.currency-api.pages.dev/v1/currencies/$normalizedCurrency.json"));
      jsonResponse = jsonDecode(response.body);
    } catch (e) {
      log("Failed to fetch exchange rates from side source", error: e);
    }

    try {
      final response = await http.get(Uri.parse(
          "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@$dateParam/v1/currencies/$normalizedCurrency.json"));
      jsonResponse = jsonDecode(response.body);
    } catch (e) {
      log("Failed to fetch exchange rates from main source", error: e);
    }

    if (jsonResponse == null) {
      throw Exception("Failed to fetch exchange rates");
    }

    final exchangeRates =
        ExchangeRates.fromJson(normalizedCurrency, jsonResponse);
    _cache[baseCurrency] = exchangeRates;
    return exchangeRates;
  }

  static Future<ExchangeRates?> tryFetchRates(
    String baseCurrency, [
    DateTime? dateTime,
  ]) async {
    try {
      final ExchangeRates exchangeRates =
          await fetchRates(baseCurrency, dateTime);
      return exchangeRates;
    } catch (e) {
      return _cache[baseCurrency];
    }
  }
}

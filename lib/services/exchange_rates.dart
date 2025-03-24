import "dart:convert";

import "package:flow/data/currencies.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/exchange_rates_set.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flutter/widgets.dart";
import "package:http/http.dart" as http;
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";

final Logger _log = Logger("ExchangeRatesService");

class ExchangeRatesService {
  final ValueNotifier<ExchangeRatesSet?> exchangeRatesCache =
      ValueNotifier<ExchangeRatesSet?>(null);

  static ExchangeRatesService? _instance;

  factory ExchangeRatesService() =>
      _instance ??= ExchangeRatesService._internal();

  ExchangeRatesService._internal();

  void init() {
    final ExchangeRatesSet? exchangeRates =
        LocalPreferences().exchangeRatesCache.get();

    if (exchangeRates != null) {
      exchangeRatesCache.value = exchangeRates;
    }

    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();
    tryFetchRates(primaryCurrency);
  }

  ExchangeRates? getPrimaryCurrencyRates() {
    return exchangeRatesCache.value?.get(
      LocalPreferences().getPrimaryCurrency(),
    );
  }

  Future<ExchangeRates> fetchRates(
    String baseCurrency, [
    DateTime? dateTime,
  ]) async {
    final String normalizedCurrency = baseCurrency.trim().toLowerCase();

    if (!isCurrencyCodeValid(normalizedCurrency.toUpperCase())) {
      throw FormatException("Invalid currency code: $baseCurrency");
    }

    final String dateParam =
        dateTime == null ? "latest" : dateTime.format(payload: "yyyy-MM-dd");

    Map<String, dynamic>? jsonResponse;

    try {
      final response = await http.get(
        Uri.parse(
          "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@$dateParam/v1/currencies/$normalizedCurrency.min.json",
        ),
      );
      jsonResponse = jsonDecode(response.body);
    } catch (e, stackTrace) {
      _log.warning(
        "Failed to fetch exchange rates from main source",
        e,
        stackTrace,
      );
    }

    try {
      final response = await http.get(
        Uri.parse(
          "https://$dateParam.currency-api.pages.dev/v1/currencies/$normalizedCurrency.min.json",
        ),
      );
      jsonResponse = jsonDecode(response.body);
    } catch (e, stackTrace) {
      _log.warning(
        "Failed to fetch exchange rates from side source",
        e,
        stackTrace,
      );
    }

    if (jsonResponse == null) {
      throw Exception("Failed to fetch exchange rates");
    }

    final ExchangeRates exchangeRates = ExchangeRates.fromJson(jsonResponse);

    updateCache(baseCurrency, exchangeRates);

    return exchangeRates;
  }

  Future<ExchangeRates?> tryFetchRates(
    String baseCurrency, [
    DateTime? dateTime,
  ]) async {
    try {
      _log.warning("Fetching exchange rates for $baseCurrency");

      final ExchangeRates exchangeRates = await fetchRates(
        baseCurrency,
        dateTime,
      );

      return exchangeRates;
    } catch (e, stackTrace) {
      _log.warning(
        "Failed to fetch exchange rates ($baseCurrency)",
        e,
        stackTrace,
      );

      return exchangeRatesCache.value?.get(baseCurrency);
    }
  }

  void updateCache(String baseCurrency, ExchangeRates exchangeRates) {
    ExchangeRatesSet? current = exchangeRatesCache.value;

    if (current == null) {
      current = ExchangeRatesSet({baseCurrency: exchangeRates});
    } else {
      current.set(baseCurrency, exchangeRates);
    }

    exchangeRatesCache.value = current;

    try {
      LocalPreferences().exchangeRatesCache.set(current);
    } catch (e, stackTrace) {
      _log.warning("Failed to update exchange rates cache", e, stackTrace);
    }
  }

  void debugClearCache() {
    LocalPreferences().exchangeRatesCache.remove();
    exchangeRatesCache.value = null;
  }
}

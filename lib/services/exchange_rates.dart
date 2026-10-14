import "dart:convert";

import "package:flow/data/exchange_rates.dart";
import "package:flow/data/exchange_rates_set.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/currency_registry.dart";
import "package:flow/services/user_preferences.dart";
import "package:flutter/widgets.dart";
import "package:http/http.dart" as http;
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";

final Logger _log = Logger("ExchangeRatesService");

class ExchangeRatesService {
  static const Duration freshnessWindow = Duration(hours: 6);
  static const Duration requestTimeout = Duration(seconds: 10);

  final ValueNotifier<ExchangeRatesSet?> exchangeRatesCache =
      ValueNotifier<ExchangeRatesSet?>(null);

  final Map<String, DateTime> _fetchedAt = {};
  final Map<String, Future<ExchangeRates?>> _pendingFetches = {};

  static ExchangeRatesService? _instance;

  factory ExchangeRatesService() =>
      _instance ??= ExchangeRatesService._internal();

  ExchangeRatesService._internal();

  void init() {
    final ExchangeRatesSet? exchangeRates = LocalPreferences()
        .exchangeRatesCache
        .get();

    if (exchangeRates != null) {
      exchangeRatesCache.value = exchangeRates;
    }

    final String primaryCurrency = UserPreferencesService().primaryCurrency;
    tryFetchRates(primaryCurrency);
  }

  ExchangeRates? getPrimaryCurrencyRates() {
    return exchangeRatesCache.value?.get(
      UserPreferencesService().primaryCurrency,
    );
  }

  Future<ExchangeRates> fetchRates(
    String baseCurrency, [
    DateTime? dateTime,
  ]) async {
    final String normalizedCurrency = baseCurrency.trim().toLowerCase();

    if (!CurrencyRegistryService().isCurrencyCodeValid(
      normalizedCurrency.toUpperCase(),
    )) {
      throw FormatException("Invalid currency code: $baseCurrency");
    }

    final String dateParam = dateTime == null
        ? "latest"
        : dateTime.format(payload: "yyyy-MM-dd");

    Map<String, dynamic>? jsonResponse;

    try {
      final response = await http
          .get(
            Uri.parse(
              "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@$dateParam/v1/currencies/$normalizedCurrency.min.json",
            ),
          )
          .timeout(requestTimeout);
      if (response.statusCode != 200) {
        throw Exception("Unexpected status code: ${response.statusCode}");
      }
      jsonResponse = jsonDecode(response.body);
    } catch (e, stackTrace) {
      _log.warning(
        "Failed to fetch exchange rates from main source",
        e,
        stackTrace,
      );
    }

    if (jsonResponse == null) {
      try {
        final response = await http
            .get(
              Uri.parse(
                "https://$dateParam.currency-api.pages.dev/v1/currencies/$normalizedCurrency.min.json",
              ),
            )
            .timeout(requestTimeout);
        if (response.statusCode != 200) {
          throw Exception("Unexpected status code: ${response.statusCode}");
        }
        jsonResponse = jsonDecode(response.body);
      } catch (e, stackTrace) {
        _log.warning(
          "Failed to fetch exchange rates from side source",
          e,
          stackTrace,
        );
      }
    }

    if (jsonResponse == null) {
      throw Exception("Failed to fetch exchange rates");
    }

    final ExchangeRates exchangeRates = ExchangeRates.fromJson(jsonResponse);

    updateCache(baseCurrency, exchangeRates);
    if (dateTime == null) {
      _fetchedAt[baseCurrency] = DateTime.now();
    }

    return exchangeRates;
  }

  /// Skips the network when the cached latest rates are still fresh, and
  /// shares one request between concurrent callers.
  Future<ExchangeRates?> tryFetchRates(
    String baseCurrency, [
    DateTime? dateTime,
  ]) {
    if (dateTime != null) return _tryFetchRates(baseCurrency, dateTime);

    if (_isFresh(baseCurrency)) {
      return Future.value(exchangeRatesCache.value?.rates[baseCurrency]);
    }

    return _pendingFetches[baseCurrency] ??= _tryFetchRates(
      baseCurrency,
    ).whenComplete(() => _pendingFetches.remove(baseCurrency));
  }

  bool _isFresh(String baseCurrency) {
    final DateTime? fetchedAt = _fetchedAt[baseCurrency];
    if (fetchedAt != null &&
        DateTime.now().difference(fetchedAt) < freshnessWindow) {
      return true;
    }

    // Rates are published daily, so nothing newer than today's exists
    final ExchangeRates? cached = exchangeRatesCache.value?.rates[baseCurrency];
    return cached != null && !cached.date.isBefore(Moment.startOfToday());
  }

  Future<ExchangeRates?> _tryFetchRates(
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
    // A new instance, so [exchangeRatesCache] listeners get notified
    final ExchangeRatesSet current = ExchangeRatesSet({
      ...?exchangeRatesCache.value?.rates,
    })..set(baseCurrency, exchangeRates);

    exchangeRatesCache.value = current;

    try {
      LocalPreferences().exchangeRatesCache.set(current);
    } catch (e, stackTrace) {
      _log.warning("Failed to update exchange rates cache", e, stackTrace);
    }
  }

  void debugClearCache() {
    _fetchedAt.clear();
    LocalPreferences().exchangeRatesCache.remove();
    exchangeRatesCache.value = null;
  }
}

import "package:flow/data/exchange_rates.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flutter/widgets.dart";

/// Wires a [State] to the primary currency and its exchange rates.
///
/// Exchange rates and the primary currency can settle a frame or two after a
/// screen opens — and can change while it's open. Mixing this in keeps
/// [primaryCurrency] and [rates] fresh and re-runs [fetch] whenever either
/// changes, so the first paint is never stale and later edits are reflected.
///
/// Implementers provide [fetch]; the mixin owns the listener lifecycle and the
/// two fields. [fetch] is called once after the initial values are resolved and
/// again on every dependency change.
mixin PrimaryCurrencyDependentState<T extends StatefulWidget> on State<T> {
  late String primaryCurrency;
  ExchangeRates? rates;

  /// Reloads this screen's data. Called on init and on every primary-currency
  /// or exchange-rate change.
  Future<void> fetch();

  @override
  void initState() {
    super.initState();

    _refreshPrimaryCurrencyDependencies();
    fetch();

    ExchangeRatesService().exchangeRatesCache.addListener(
      _onDependenciesChanged,
    );
    UserPreferencesService().valueNotifier.addListener(_onDependenciesChanged);
  }

  @override
  void dispose() {
    ExchangeRatesService().exchangeRatesCache.removeListener(
      _onDependenciesChanged,
    );
    UserPreferencesService().valueNotifier.removeListener(
      _onDependenciesChanged,
    );
    super.dispose();
  }

  void _refreshPrimaryCurrencyDependencies() {
    primaryCurrency = UserPreferencesService().primaryCurrency;
    rates = ExchangeRatesService().getPrimaryCurrencyRates();
  }

  void _onDependenciesChanged() {
    if (!mounted) return;
    _refreshPrimaryCurrencyDependencies();
    fetch();
  }
}

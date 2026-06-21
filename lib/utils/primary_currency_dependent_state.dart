import "dart:async";

import "package:flow/data/exchange_rates.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flutter/widgets.dart";

/// Wires a [State] to the primary currency, its exchange rates, and the
/// transaction store.
///
/// Exchange rates and the primary currency can settle a frame or two after a
/// screen opens — and can change while it's open. Mixing this in keeps
/// [primaryCurrency] and [rates] fresh and re-runs [fetch] whenever either
/// changes, so the first paint is never stale and later edits are reflected.
///
/// It also re-runs [fetch] whenever a transaction is added, edited, or removed,
/// so analytics never lag behind the data they summarize. Transaction edits can
/// arrive in bursts (imports, bulk edits), so these are debounced by
/// [_transactionRefreshDebounce] into a single trailing reload.
///
/// Implementers provide [fetch]; the mixin owns the listener lifecycle and the
/// two fields. [fetch] is called once after the initial values are resolved and
/// again on every dependency change.
mixin PrimaryCurrencyDependentState<T extends StatefulWidget> on State<T> {
  late String primaryCurrency;
  ExchangeRates? rates;

  static const Duration _transactionRefreshDebounce = Duration(
    milliseconds: 300,
  );

  Timer? _transactionDebounce;

  /// Reloads this screen's data. Called on init and on every primary-currency,
  /// exchange-rate, or transaction change.
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
    TransactionsService().addListener(_onTransactionsChanged);
  }

  @override
  void dispose() {
    _transactionDebounce?.cancel();
    ExchangeRatesService().exchangeRatesCache.removeListener(
      _onDependenciesChanged,
    );
    UserPreferencesService().valueNotifier.removeListener(
      _onDependenciesChanged,
    );
    TransactionsService().removeListener(_onTransactionsChanged);
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

  void _onTransactionsChanged() {
    _transactionDebounce?.cancel();
    _transactionDebounce = Timer(_transactionRefreshDebounce, () {
      if (!mounted) return;
      fetch();
    });
  }
}

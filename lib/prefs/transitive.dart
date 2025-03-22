import "dart:async";
import "dart:convert";

import "package:flow/data/prefs/frecency.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/objectbox.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/accounts.dart";
import "package:flow/services/transactions.dart";
import "package:local_settings/local_settings.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";
import "package:shared_preferences/shared_preferences.dart";

final Logger _log = Logger("TransitiveLocalPreferences");

class TransitiveLocalPreferences {
  final SharedPreferencesWithCache _prefs;

  static TransitiveLocalPreferences? _instance;

  /// Whether the user uses only one currency across accounts
  late final BoolSettingsEntry transitiveUsesSingleCurrency;

  late final DateTimeSettingsEntry transitiveLastTimeFrecencyUpdated;

  late final DateTimeSettingsEntry lastAutoBackupRanAt;
  late final PrimitiveSettingsEntry<String> lastAutoBackupPath;

  late final BoolSettingsEntry sessionPrivacyMode;

  factory TransitiveLocalPreferences() {
    if (_instance == null) {
      throw Exception(
        "You must initialize TransitiveLocalPreferences by calling initialize().",
      );
    }

    return _instance!;
  }

  TransitiveLocalPreferences._internal(this._prefs) {
    SettingsEntry.defaultPrefix = "flow.";

    transitiveUsesSingleCurrency = BoolSettingsEntry(
      key: "transitive.usesSingleCurrency",
      preferences: _prefs,
      initialValue: true,
    );

    transitiveLastTimeFrecencyUpdated = DateTimeSettingsEntry(
      key: "transitive.lastTimeFrecencyUpdated",
      preferences: _prefs,
    );

    lastAutoBackupRanAt = DateTimeSettingsEntry(
      key: "transitive.lastAutoBackupRanAt",
      preferences: _prefs,
    );

    lastAutoBackupPath = PrimitiveSettingsEntry<String>(
      key: "transitive.lastAutoBackupPath",
      preferences: _prefs,
    );

    sessionPrivacyMode = BoolSettingsEntry(
      key: "transitive.sessionPrivacyMode",
      preferences: _prefs,
      initialValue: false,
    );

    unawaited(updateTransitiveProperties());
  }

  Future<void> updateTransitiveProperties() async {
    try {
      final accounts = await AccountsService().getAll();

      final usesSingleCurrency =
          accounts.map((e) => e.currency).toSet().length == 1;

      await transitiveUsesSingleCurrency.set(usesSingleCurrency);
    } catch (e, stackTrace) {
      _log.warning("Cannot update transitive properties", e, stackTrace);
    }

    try {
      unawaited(sessionPrivacyMode.set(LocalPreferences().privacyMode.get()));
    } catch (e) {
      // Silent fail
    }

    try {
      if (transitiveLastTimeFrecencyUpdated.get() == null ||
          !transitiveLastTimeFrecencyUpdated.get()!.isAtSameDayAs(
            Moment.now(),
          )) {
        unawaited(_reevaluateCategoryFrecency());
        unawaited(_reevaluateAccountFrecency());
        unawaited(transitiveLastTimeFrecencyUpdated.set(DateTime.now()));
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<FrecencyData?> setFrecencyData(
    String type,
    String uuid,
    FrecencyData? value,
  ) async {
    final String prefixedKey = "transitive.frecency.$type.$uuid";

    if (value == null) {
      await _prefs.remove(prefixedKey);
      return null;
    } else {
      await _prefs.setString(prefixedKey, jsonEncode(value.toJson()));
      return value;
    }
  }

  Future<FrecencyData?> updateFrecencyData(String type, String uuid) async {
    final FrecencyData current =
        getFrecencyData(type, uuid) ??
        FrecencyData(lastUsed: DateTime.now(), useCount: 0, uuid: uuid);

    return await setFrecencyData(type, uuid, current.incremented());
  }

  FrecencyData? getFrecencyData(String type, String uuid) {
    final String prefixedKey = "transitive.frecency.$type.$uuid";

    final raw = _prefs.getString(prefixedKey);

    if (raw == null) return null;

    try {
      return FrecencyData.fromJson(jsonDecode(raw));
    } catch (e) {
      return null;
    }
  }

  Future<void> _reevaluateCategoryFrecency() async {
    final List<Category> categories =
        await ObjectBox().box<Category>().getAllAsync();

    if (categories.isEmpty) {
      return;
    }

    for (final category in categories) {
      try {
        final TransactionFilter filter = TransactionFilter(
          categories: [category.uuid],
          range: TransactionFilterTimeRange.fromTimeRange(
            Moment.minValue.rangeTo(Moment.now()),
          ),
          sortBy: TransactionSortField.transactionDate,
          sortDescending: true,
        );

        final int useCount = TransactionsService().countMany(filter);
        final DateTime lastUsed =
            TransactionsService().findFirstSync(filter)?.transactionDate ??
            DateTime.fromMillisecondsSinceEpoch(0);

        unawaited(
          setFrecencyData(
            "category",
            category.uuid,
            FrecencyData(
              uuid: category.uuid,
              lastUsed: lastUsed,
              useCount: useCount,
            ),
          ),
        );
      } catch (e, stackTrace) {
        _log.warning(
          "Failed to build category FrecencyData for $category",
          e,
          stackTrace,
        );
      }
    }
  }

  Future<void> _reevaluateAccountFrecency() async {
    final List<Account> accounts = await AccountsService().getAll();

    if (accounts.isEmpty) {
      return;
    }

    for (final account in accounts) {
      try {
        final TransactionFilter filter = TransactionFilter(
          accounts: [account.uuid],
          range: TransactionFilterTimeRange.fromTimeRange(
            Moment.minValue.rangeTo(Moment.now()),
          ),
          sortBy: TransactionSortField.transactionDate,
          sortDescending: true,
        );

        final int useCount = TransactionsService().countMany(filter);
        final DateTime lastUsed =
            TransactionsService().findFirstSync(filter)?.transactionDate ??
            DateTime.fromMillisecondsSinceEpoch(0);

        unawaited(
          setFrecencyData(
            "account",
            account.uuid,
            FrecencyData(
              uuid: account.uuid,
              lastUsed: lastUsed,
              useCount: useCount,
            ),
          ),
        );
      } catch (e, stackTrace) {
        _log.warning(
          "Failed to build account FrecencyData for $account",
          e,
          stackTrace,
        );
      }
    }
  }

  static TransitiveLocalPreferences initialize(
    SharedPreferencesWithCache instance,
  ) => _instance ??= TransitiveLocalPreferences._internal(instance);
}

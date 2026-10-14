import "dart:async";
import "dart:convert";

import "package:flow/data/prefs/frecency.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/foreign_currency.dart";
import "package:flow/entity/transaction_tag.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/accounts.dart";
import "package:flow/services/user_preferences.dart";
import "package:local_settings/local_settings.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";
import "package:shared_preferences/shared_preferences.dart";

final Logger _log = Logger("TransitiveLocalPreferences");

class TransitiveLocalPreferences {
  final SharedPreferencesWithCache _prefs;

  static TransitiveLocalPreferences? _instance;

  static const int _recentForeignCurrenciesLimit = 5;

  /// Whether the user uses only one currency across accounts
  late final BoolSettingsEntry usesNonPrimaryCurrency;
  late final BoolSettingsEntry usesMultipleCurrencies;

  /// Whether any transaction was made in a currency other than its account's
  late final BoolSettingsEntry usesForeignCurrencyTransactions;

  /// Up to [_recentForeignCurrenciesLimit] currency codes, most recent first
  late final StringListSettingsEntry recentForeignCurrencies;

  late final DateTimeSettingsEntry transitiveLastTimeFrecencyUpdated;

  /// Forces a one-shot rebuild of category frecency the first time the app
  /// runs after the typed-frecency change, so existing users get
  /// `category:income` / `category:expense` records backfilled immediately
  /// instead of waiting for the next daily reevaluation rollover.
  late final BoolSettingsEntry categoryFrecencyTypedBuilt;

  late final DateTimeSettingsEntry lastAutoBackupRanAt;
  late final PrimitiveSettingsEntry<String> lastAutoBackupPath;

  late final DateTimeSettingsEntry lastSuccessfulICloudSyncAt;
  late final BoolSettingsEntry iCloudSyncWorkingFine;

  late final BoolSettingsEntry sessionPrivacyMode;

  // For internal notifications
  late final PrimitiveSettingsEntry<String> lastSavedAutoBackupPath;
  late final DateTimeSettingsEntry lastRateAppShowedAt;
  late final DateTimeSettingsEntry lastStarOnGitHubShowedAt;
  late final DateTimeSettingsEntry lastBudgetAlertShowedAt;

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

    usesNonPrimaryCurrency = BoolSettingsEntry(
      key: "transitive.usesNonPrimaryCurrency",
      preferences: _prefs,
      initialValue: false,
    );
    usesMultipleCurrencies = BoolSettingsEntry(
      key: "transitive.usesMultipleCurrencies",
      preferences: _prefs,
      initialValue: false,
    );
    usesForeignCurrencyTransactions = BoolSettingsEntry(
      key: "transitive.usesForeignCurrencyTransactions",
      preferences: _prefs,
      initialValue: false,
    );
    recentForeignCurrencies = StringListSettingsEntry(
      key: "transitive.recentForeignCurrencies",
      preferences: _prefs,
    );

    transitiveLastTimeFrecencyUpdated = DateTimeSettingsEntry(
      key: "transitive.lastTimeFrecencyUpdated",
      preferences: _prefs,
    );

    categoryFrecencyTypedBuilt = BoolSettingsEntry(
      // Versioned key: bump the suffix whenever the reevaluation logic
      // changes in a way that needs to be re-run for existing users.
      key: "transitive.categoryFrecencyTypedBuilt.v2",
      preferences: _prefs,
      initialValue: false,
    );

    lastAutoBackupRanAt = DateTimeSettingsEntry(
      key: "transitive.lastAutoBackupRanAt",
      preferences: _prefs,
    );

    lastAutoBackupPath = PrimitiveSettingsEntry<String>(
      key: "transitive.lastAutoBackupPath",
      preferences: _prefs,
    );

    lastSuccessfulICloudSyncAt = DateTimeSettingsEntry(
      key: "transitive.lastSuccessfulICloudSyncAt",
      preferences: _prefs,
    );

    iCloudSyncWorkingFine = BoolSettingsEntry(
      key: "transitive.iCloudSyncWorkingFine",
      preferences: _prefs,
      initialValue: true,
    );

    sessionPrivacyMode = BoolSettingsEntry(
      key: "transitive.sessionPrivacyMode",
      preferences: _prefs,
      initialValue: false,
    );

    lastRateAppShowedAt = DateTimeSettingsEntry(
      key: "transitive.lastRateAppShowedAt",
      preferences: _prefs,
    );

    lastStarOnGitHubShowedAt = DateTimeSettingsEntry(
      key: "transitive.lastStarOnGitHubShowedAt",
      preferences: _prefs,
    );

    lastBudgetAlertShowedAt = DateTimeSettingsEntry(
      key: "transitive.lastBudgetAlertShowedAt",
      preferences: _prefs,
    );

    lastSavedAutoBackupPath = PrimitiveSettingsEntry<String>(
      key: "transitive.lastSavedAutoBackupPath",
      preferences: _prefs,
    );

    unawaited(updateTransitiveProperties());
  }

  Future<void> updateTransitiveProperties() async {
    try {
      final accounts = await AccountsService().getAll();

      final String primaryCurrency = UserPreferencesService().primaryCurrency;

      final bool hasAnyNonPrimaryCurrencyAccount = accounts.any(
        (account) => account.currency != primaryCurrency,
      );

      await usesNonPrimaryCurrency.set(hasAnyNonPrimaryCurrencyAccount);
      await usesMultipleCurrencies.set(
        accounts.map((account) => account.currency).toSet().length > 1,
      );
    } catch (e, stackTrace) {
      _log.warning("Cannot update transitive properties", e, stackTrace);
    }

    try {
      await _updateForeignCurrencyProperties();
    } catch (e, stackTrace) {
      _log.warning(
        "Cannot update foreign currency transitive properties",
        e,
        stackTrace,
      );
    }

    try {
      if (transitiveLastTimeFrecencyUpdated.get() == null ||
          !transitiveLastTimeFrecencyUpdated.get()!.isAtSameDayAs(
            Moment.now(),
          )) {
        unawaited(
          _reevaluateFrecency().then(
            (_) => categoryFrecencyTypedBuilt.set(true),
          ),
        );
        unawaited(transitiveLastTimeFrecencyUpdated.set(DateTime.now()));
      } else if (!categoryFrecencyTypedBuilt.get()) {
        unawaited(
          _reevaluateFrecency().then(
            (_) => categoryFrecencyTypedBuilt.set(true),
          ),
        );
      }
    } catch (e) {
      _log.warning("Failed to reevaluate frecency caches", e);
    }
  }

  bool get showCurrencyPickerHint =>
      usesMultipleCurrencies.get() ||
      usesNonPrimaryCurrency.get() ||
      usesForeignCurrencyTransactions.get();

  List<String> getRecentForeignCurrencies() =>
      recentForeignCurrencies.get() ?? const [];

  /// Call when a transaction is saved with a foreign currency
  Future<void> recordForeignCurrencyUse(String currency) async {
    await usesForeignCurrencyTransactions.set(true);
    await recentForeignCurrencies.set(
      {
        currency,
        ...getRecentForeignCurrencies(),
      }.take(_recentForeignCurrenciesLimit).toList(),
    );
  }

  Future<void> _updateForeignCurrencyProperties() async {
    final Query<Transaction> query = const TransactionFilter(
      extraTag: "hasExtension:${ForeignCurrency.keyName}",
    ).queryBuilder().build()..limit = 50;

    final List<Transaction> transactions = await query.findAsync();

    query.close();

    final List<String> currencies = transactions
        .map((transaction) => transaction.extensions.foreignCurrency?.currency)
        .nonNulls
        .toSet()
        .take(_recentForeignCurrenciesLimit)
        .toList();

    await usesForeignCurrencyTransactions.set(currencies.isNotEmpty);
    await recentForeignCurrencies.set(currencies);
  }

  static String categoryFrecencyType(TransactionType type) =>
      "category:${type.value}";

  /// Frecency storage keys to consult for category ranking. When [type] is
  /// null (e.g. bulk-change-category, or a transfer where categories aren't
  /// typed), combine income and expense so categories still rank by overall
  /// usage.
  static List<String> categoryFrecencyTypesFor(TransactionType? type) {
    return switch (type) {
      TransactionType.income ||
      TransactionType.expense => [categoryFrecencyType(type!)],
      _ => const ["category:income", "category:expense"],
    };
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

  /// Rebuilds category, account, and tag frecency from the last 180 days in
  /// a single worker isolate query.
  Future<void> _reevaluateFrecency() async {
    try {
      final DateTime now = DateTime.now();

      final (
        List<Category> categories,
        List<Account> accounts,
        List<TransactionTag> tags,
        Map<String, Map<String, FrecencyData>> usage,
      ) = await (
        ObjectBox().box<Category>().getAllAsync(),
        AccountsService().getAll(),
        ObjectBox().box<TransactionTag>().getAllAsync(),
        ObjectBox().store.runAsync(_tallyUsage, (
          now.subtract(const Duration(days: 180)),
          now,
        )),
      ).wait;

      final DateTime neverUsed = DateTime.fromMillisecondsSinceEpoch(0);

      await Future.wait([
        for (final Category category in categories)
          for (final TransactionType type in const [
            TransactionType.income,
            TransactionType.expense,
          ])
            _setFrecencyDataIfChanged(
              categoryFrecencyType(type),
              category.uuid,
              usage[categoryFrecencyType(type)]?[category.uuid],
            ),
        for (final Account account in accounts)
          _setFrecencyDataIfChanged(
            "account",
            account.uuid,
            usage["account"]?[account.uuid] ??
                FrecencyData(
                  uuid: account.uuid,
                  lastUsed: neverUsed,
                  useCount: 0,
                ),
          ),
        for (final TransactionTag tag in tags)
          _setFrecencyDataIfChanged(
            "tag",
            tag.uuid,
            usage["tag"]?[tag.uuid] ??
                FrecencyData(uuid: tag.uuid, lastUsed: neverUsed, useCount: 0),
          ),
      ]);
    } catch (e, stackTrace) {
      _log.warning("Failed to reevaluate frecency", e, stackTrace);
    }
  }

  Future<void> _setFrecencyDataIfChanged(
    String type,
    String uuid,
    FrecencyData? value,
  ) async {
    final String? current = _prefs.getString("transitive.frecency.$type.$uuid");
    final String? next = value == null ? null : jsonEncode(value.toJson());

    if (current == next) return;

    await setFrecencyData(type, uuid, value);
  }

  /// Runs in a worker isolate. Counts non-deleted transactions in [range] per
  /// frecency type and uuid.
  static Map<String, Map<String, FrecencyData>> _tallyUsage(
    Store store,
    (DateTime, DateTime) range,
  ) {
    final Query<Transaction> query = store
        .box<Transaction>()
        .query(
          Transaction_.transactionDate.betweenDate(range.$1, range.$2) &
              (Transaction_.isDeleted.isNull() |
                  Transaction_.isDeleted.notEquals(true)),
        )
        .build();

    final List<Transaction> transactions;
    try {
      transactions = query.find();
    } finally {
      query.close();
    }

    final Map<String, Map<String, FrecencyData>> usage = {};

    void tally(String type, String? uuid, DateTime date) {
      if (uuid == null) return;

      final Map<String, FrecencyData> byUuid = usage.putIfAbsent(
        type,
        () => {},
      );
      final FrecencyData? current = byUuid[uuid];

      byUuid[uuid] = FrecencyData(
        uuid: uuid,
        useCount: (current?.useCount ?? 0) + 1,
        lastUsed: current == null || date.isAfter(current.lastUsed)
            ? date
            : current.lastUsed,
      );
    }

    for (final Transaction transaction in transactions) {
      final DateTime date = transaction.transactionDate;
      final TransactionType type = transaction.type;

      if (type != TransactionType.transfer) {
        tally(categoryFrecencyType(type), transaction.categoryUuid, date);
      }
      tally("account", transaction.accountUuid, date);
      for (final TransactionTag tag in transaction.tags) {
        tally("tag", tag.uuid, date);
      }
    }

    return usage;
  }

  static TransitiveLocalPreferences initialize(
    SharedPreferencesWithCache instance,
  ) => _instance ??= TransitiveLocalPreferences._internal(instance);
}

import "dart:async";
import "dart:convert";
import "dart:developer";

import "package:flow/data/exchange_rates_set.dart";
import "package:flow/data/prefs/frecency.dart";
import "package:flow/data/upcoming_transactions.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:intl/intl.dart";
import "package:latlong2/latlong.dart";
import "package:local_settings/local_settings.dart";
import "package:moment_dart/moment_dart.dart";
import "package:shared_preferences/shared_preferences.dart";

/// This class contains everything that's stored on
/// device. Such as user preferences and per-device
/// settings
class LocalPreferences {
  final SharedPreferences _prefs;

  static const UpcomingTransactionsDuration
      homeTabPlannedTransactionsDurationDefault =
      UpcomingTransactionsDuration.thisWeek;

  /// Main currency used in the app
  late final PrimitiveSettingsEntry<String> primaryCurrency;

  /// Whether to use phone numpad layout
  ///
  /// When set to true, 1 2 3 will be the top row like
  /// in a modern dialpad
  late final BoolSettingsEntry usePhoneNumpadLayout;

  /// Whether to enable haptic feedback on numpad touch
  late final BoolSettingsEntry enableNumpadHapticFeedback;

  /// Whether to combine transfer transactions in the transaction list
  ///
  /// Doesn't necessarily combine the transactions, but rather
  /// shows them as a single transaction in the transaction list
  ///
  /// It will not work in transactions list where a filter has applied
  late final BoolSettingsEntry combineTransferTransactions;

  /// Whether to exclude transfer transactions from the flow
  ///
  /// When set to true, transfer transactions will not contribute
  /// to total income/expense for a given context
  late final BoolSettingsEntry excludeTransferFromFlow;

  /// Shows next [homeTabPlannedTransactionsDays] days of planned transactions in the home tab
  late final JsonSettingsEntry<UpcomingTransactionsDuration>
      homeTabPlannedTransactionsDuration;
  late final JsonListSettingsEntry<TransactionType> transactionButtonOrder;

  late final BoolSettingsEntry completedInitialSetup;

  late final LocaleSettingsEntry localeOverride;

  /// Whether the user uses only one currency across accounts
  late final BoolSettingsEntry transitiveUsesSingleCurrency;

  late final DateTimeSettingsEntry transitiveLastTimeFrecencyUpdated;

  late final JsonSettingsEntry<ExchangeRatesSet> exchangeRatesCache;

  late final BoolSettingsEntry enableGeo;

  late final BoolSettingsEntry autoAttachTransactionGeo;

  late final JsonSettingsEntry<LatLng> lastKnownGeo;

  late final PrimitiveSettingsEntry<String> themeName;

  LocalPreferences._internal(this._prefs) {
    primaryCurrency = PrimitiveSettingsEntry<String>(
      key: "flow.primaryCurrency",
      preferences: _prefs,
    );
    usePhoneNumpadLayout = BoolSettingsEntry(
      key: "flow.usePhoneNumpadLayout",
      preferences: _prefs,
      initialValue: false,
    );
    enableNumpadHapticFeedback = BoolSettingsEntry(
      key: "flow.enableNumpadHapticFeedback",
      preferences: _prefs,
      initialValue: true,
    );
    combineTransferTransactions = BoolSettingsEntry(
      key: "flow.combineTransferTransactions",
      preferences: _prefs,
      initialValue: true,
    );
    excludeTransferFromFlow = BoolSettingsEntry(
      key: "flow.excludeTransferFromFlow",
      preferences: _prefs,
      initialValue: false,
    );
    homeTabPlannedTransactionsDuration =
        JsonSettingsEntry<UpcomingTransactionsDuration>(
      key: "flow.homeTabPlannedTransactionsDuration",
      preferences: _prefs,
      initialValue: homeTabPlannedTransactionsDurationDefault,
      fromJson: (map) =>
          UpcomingTransactionsDuration.fromJson(map) ??
          homeTabPlannedTransactionsDurationDefault,
      toJson: (data) => data.toJson(),
    );
    transactionButtonOrder = JsonListSettingsEntry<TransactionType>(
      key: "flow.transactionButtonOrder",
      preferences: _prefs,
      removeDuplicates: true,
      initialValue: TransactionType.values,
      fromJson: (json) =>
          TransactionType.fromJson(json) ?? TransactionType.expense,
      toJson: (transactionType) => transactionType.toJson(),
    );

    completedInitialSetup = BoolSettingsEntry(
      key: "flow.completedInitialSetup",
      preferences: _prefs,
      initialValue: false,
    );

    localeOverride = LocaleSettingsEntry(
      key: "flow.localeOverride",
      preferences: _prefs,
    );

    transitiveUsesSingleCurrency = BoolSettingsEntry(
      key: "flow.transitive.usesSingleCurrency",
      preferences: _prefs,
      initialValue: true,
    );

    transitiveLastTimeFrecencyUpdated = DateTimeSettingsEntry(
      key: "flow.transitive.lastTimeFrecencyUpdated",
      preferences: _prefs,
    );

    exchangeRatesCache = JsonSettingsEntry<ExchangeRatesSet>(
      initialValue: ExchangeRatesSet({}),
      key: "flow.caches.exchangeRatesCache",
      preferences: _prefs,
      fromJson: (json) => ExchangeRatesSet.fromJson(json),
      toJson: (data) => data.toJson(),
    );

    enableGeo = BoolSettingsEntry(
      key: "flow.enableGeo",
      preferences: _prefs,
      initialValue: false,
    );

    autoAttachTransactionGeo = BoolSettingsEntry(
      key: "flow.autoAttachTransactionGeo",
      preferences: _prefs,
      initialValue: false,
    );

    lastKnownGeo = JsonSettingsEntry<LatLng>(
      key: "flow.lastKnownGeo",
      preferences: _prefs,
      fromJson: (json) => LatLng.fromJson(json),
      toJson: (data) => data.toJson(),
    );

    themeName = PrimitiveSettingsEntry<String>(
      key: "flow.themeName",
      preferences: _prefs,
      initialValue: lightThemes.keys.first,
    );

    updateTransitiveProperties();
  }

  Future<void> updateTransitiveProperties() async {
    try {
      final accounts = await ObjectBox().box<Account>().getAllAsync();

      final usesSingleCurrency =
          accounts.map((e) => e.currency).toSet().length == 1;

      await transitiveUsesSingleCurrency.set(usesSingleCurrency);
    } catch (e) {
      log("[LocalPreferences] cannot update transitive properties due to: $e");
    }

    if (transitiveLastTimeFrecencyUpdated.get() == null ||
        !transitiveLastTimeFrecencyUpdated.get()!.isAtSameDayAs(Moment.now())) {
      unawaited(_reevaluateCategoryFrecency());
      unawaited(_reevaluateAccountFrecency());
      unawaited(transitiveLastTimeFrecencyUpdated.set(DateTime.now()));
    }
  }

  Future<FrecencyData?> setFrecencyData(
    String type,
    String uuid,
    FrecencyData? value,
  ) async {
    final String prefixedKey = "flow.transitive.frecency.$type.$uuid";

    if (value == null) {
      await _prefs.remove(prefixedKey);
      return null;
    } else {
      await _prefs.setString(prefixedKey, jsonEncode(value.toJson()));
      return value;
    }
  }

  Future<FrecencyData?> updateFrecencyData(
    String type,
    String uuid,
  ) async {
    final FrecencyData current = getFrecencyData(type, uuid) ??
        FrecencyData(lastUsed: DateTime.now(), useCount: 0, uuid: uuid);

    return await setFrecencyData(type, uuid, current.incremented());
  }

  FrecencyData? getFrecencyData(String type, String uuid) {
    final String prefixedKey = "flow.transitive.frecency.$type.$uuid";

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
        final Query<Transaction> categoryTransactionsQuery = ObjectBox()
            .box<Transaction>()
            .query(Transaction_.categoryUuid.equals(category.uuid).and(
                Transaction_.transactionDate
                    .lessThan(DateTime.now().millisecondsSinceEpoch)))
            .order(Transaction_.transactionDate, flags: Order.descending)
            .build();

        final int useCount = categoryTransactionsQuery.count();
        final DateTime lastUsed =
            categoryTransactionsQuery.findFirst()?.transactionDate ??
                DateTime.fromMillisecondsSinceEpoch(0);

        categoryTransactionsQuery.close();

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
      } catch (e) {
        log("Failed to build category FrecencyData for $category due to: $e");
      }
    }
  }

  Future<void> _reevaluateAccountFrecency() async {
    final List<Account> accounts =
        await ObjectBox().box<Account>().getAllAsync();

    if (accounts.isEmpty) {
      return;
    }

    for (final account in accounts) {
      try {
        final Query<Transaction> accountTransactionsQuery = ObjectBox()
            .box<Transaction>()
            .query(Transaction_.accountUuid.equals(account.uuid).and(
                Transaction_.transactionDate
                    .lessThan(DateTime.now().millisecondsSinceEpoch)))
            .order(Transaction_.transactionDate, flags: Order.descending)
            .build();

        final int useCount = accountTransactionsQuery.count();
        final DateTime lastUsed =
            accountTransactionsQuery.findFirst()?.transactionDate ??
                DateTime.fromMillisecondsSinceEpoch(0);

        accountTransactionsQuery.close();

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
      } catch (e) {
        log("Failed to build account FrecencyData for $account due to: $e");
      }
    }
  }

  String getPrimaryCurrency() {
    String? primaryCurrencyName = primaryCurrency.value;

    if (primaryCurrencyName == null) {
      late final String? firstAccountCurency;

      try {
        final Query<Account> firstAccountQuery = ObjectBox()
            .box<Account>()
            .query()
            .order(Account_.createdDate)
            .build();

        firstAccountCurency = firstAccountQuery.findFirst()?.currency;

        firstAccountQuery.close();
      } catch (e) {
        firstAccountCurency = null;
      }

      if (firstAccountCurency == null) {
        // Generally, primary currency will be set up when the user first
        // opens the app. When recovering from a backup, backup logic should
        // handle setting this value.
        primaryCurrencyName =
            NumberFormat.currency(locale: Intl.defaultLocale ?? "en_US")
                    .currencyName ??
                "USD";
      } else {
        primaryCurrencyName = firstAccountCurency;
      }

      primaryCurrency.set(primaryCurrencyName);
    }

    return primaryCurrencyName;
  }

  factory LocalPreferences() {
    if (_instance == null) {
      throw Exception(
        "You must initialize LocalPreferences by calling initialize().",
      );
    }

    return _instance!;
  }

  static LocalPreferences? _instance;

  static Future<void> initialize() async {
    _instance ??=
        LocalPreferences._internal(await SharedPreferences.getInstance());
  }
}

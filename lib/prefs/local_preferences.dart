import "dart:async";

import "package:flow/data/exchange_rates_set.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/logging.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/pending_transactions.dart";
import "package:flow/prefs/theme.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:intl/intl.dart";
import "package:local_settings/local_settings.dart";
import "package:shared_preferences/shared_preferences.dart";

export "./pending_transactions.dart";
export "./theme.dart";
export "./transitive.dart";

/// This class contains everything that's stored on
/// device. Such as user preferences and per-device
/// settings
class LocalPreferences {
  final SharedPreferencesWithCache _prefs;

  /// Main currency used in the app
  late final PrimitiveSettingsEntry<String> primaryCurrency;

  /// Whether to use phone numpad layout
  ///
  /// When set to true, 1 2 3 will be the top row like
  /// in a modern dialpad
  late final BoolSettingsEntry usePhoneNumpadLayout;

  /// Whether to enable haptic feedback upon certain actions
  late final BoolSettingsEntry enableHapticFeedback;

  late final JsonListSettingsEntry<TransactionType> transactionButtonOrder;

  late final BoolSettingsEntry completedInitialSetup;

  late final DateTimeSettingsEntry lastRequestedAppStoreReview;

  late final LocaleSettingsEntry localeOverride;

  late final JsonSettingsEntry<ExchangeRatesSet> exchangeRatesCache;

  late final BoolSettingsEntry enableGeo;

  late final BoolSettingsEntry autoAttachTransactionGeo;

  late final BoolSettingsEntry privacyMode;

  /// This refers to biometric auth, passwords, pins from the operating system
  late final BoolSettingsEntry requireLocalAuth;

  late final BoolSettingsEntry preferFullAmounts;
  late final BoolSettingsEntry useCurrencySymbol;

  late final PendingTransactionsLocalPreferences pendingTransactions;
  late final ThemeLocalPreferences theme;
  late final TransitiveLocalPreferences transitive;

  /// Number of notifications issued by the app
  ///
  /// Used to prevent id collisions
  late final PrimitiveSettingsEntry<int> notificationsIssuedCount;

  LocalPreferences._internal(this._prefs) {
    SettingsEntry.defaultPrefix = "flow.";

    primaryCurrency = PrimitiveSettingsEntry<String>(
      key: "primaryCurrency",
      preferences: _prefs,
    );
    usePhoneNumpadLayout = BoolSettingsEntry(
      key: "usePhoneNumpadLayout",
      preferences: _prefs,
      initialValue: false,
    );
    enableHapticFeedback = BoolSettingsEntry(
      key: "enableHapticFeedback",
      preferences: _prefs,
      initialValue: true,
    );
    transactionButtonOrder = JsonListSettingsEntry<TransactionType>(
      key: "transactionButtonOrder",
      preferences: _prefs,
      removeDuplicates: true,
      initialValue: TransactionType.values,
      fromJson:
          (json) => TransactionType.fromJson(json) ?? TransactionType.expense,
      toJson: (transactionType) => transactionType.toJson(),
    );

    completedInitialSetup = BoolSettingsEntry(
      key: "completedInitialSetup",
      preferences: _prefs,
      initialValue: false,
    );

    localeOverride = LocaleSettingsEntry(
      key: "localeOverride",
      preferences: _prefs,
    );

    exchangeRatesCache = JsonSettingsEntry<ExchangeRatesSet>(
      initialValue: ExchangeRatesSet({}),
      key: "caches.exchangeRatesCache",
      preferences: _prefs,
      fromJson: (json) => ExchangeRatesSet.fromJson(json),
      toJson: (data) => data.toJson(),
    );

    enableGeo = BoolSettingsEntry(
      key: "enableGeo",
      preferences: _prefs,
      initialValue: false,
    );

    autoAttachTransactionGeo = BoolSettingsEntry(
      key: "autoAttachTransactionGeo",
      preferences: _prefs,
      initialValue: false,
    );

    privacyMode = BoolSettingsEntry(
      key: "privacyMode",
      preferences: _prefs,
      initialValue: false,
    );

    requireLocalAuth = BoolSettingsEntry(
      key: "requireLocalAuth",
      preferences: _prefs,
      initialValue: false,
    );

    preferFullAmounts = BoolSettingsEntry(
      key: "preferFullAmounts",
      preferences: _prefs,
      initialValue: false,
    );
    useCurrencySymbol = BoolSettingsEntry(
      key: "useCurrencySymbol",
      preferences: _prefs,
      initialValue: true,
    );

    lastRequestedAppStoreReview = DateTimeSettingsEntry(
      key: "lastRequestedAppStoreReview",
      preferences: _prefs,
      initialValue: null,
    );

    notificationsIssuedCount = PrimitiveSettingsEntry<int>(
      key: "notificationsIssuedCount",
      preferences: _prefs,
      initialValue: 0,
    );

    pendingTransactions = PendingTransactionsLocalPreferences.initialize(
      _prefs,
    );
    theme = ThemeLocalPreferences.initialize(_prefs);
    transitive = TransitiveLocalPreferences.initialize(_prefs);
  }

  String getPrimaryCurrency() {
    String? primaryCurrencyName = primaryCurrency.value;

    if (primaryCurrencyName == null) {
      late final String? firstAccountCurency;

      try {
        final Query<Account> firstAccountQuery =
            ObjectBox()
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
            NumberFormat.currency(
              locale: Intl.defaultLocale ?? "en_US",
            ).currencyName ??
            "USD";
      } else {
        primaryCurrencyName = firstAccountCurency;
      }

      primaryCurrency.set(primaryCurrencyName);
    }

    return primaryCurrencyName;
  }

  String getCurrentTheme() {
    final String? preferencesTheme = theme.themeName.get();
    return validateThemeName(preferencesTheme)
        ? preferencesTheme!
        : flowLights.schemes.first.name;
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
    try {
      await _migrateFromLegacy("migrate-d6bf17de-7a59-493c-aa79-30bcd848021e");
    } catch (e) {
      startupLog.severe(
        "Failed to migrate from legacy shared preferences, this results in data loss of user preferences set for the device",
        e,
      );
    }

    final withCache = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(),
    );

    _instance ??= LocalPreferences._internal(withCache);
  }

  static Future<void> _migrateFromLegacy(String migrationCompletedKey) async {
    final SharedPreferences legacy = await SharedPreferences.getInstance();

    final SharedPreferencesWithCache neuePrefs =
        await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(),
        );

    if (neuePrefs.get(migrationCompletedKey) == true) {
      return;
    }

    await legacy.reload();
    final Set<String> keys = legacy.getKeys();

    for (final String key in keys) {
      final Object? value = legacy.get(key);
      switch (value.runtimeType) {
        case const (bool):
          await neuePrefs.setBool(key, value! as bool);
        case const (int):
          await neuePrefs.setInt(key, value! as int);
        case const (double):
          await neuePrefs.setDouble(key, value! as double);
        case const (String):
          await neuePrefs.setString(key, value! as String);
        case const (List<String>):
        case const (List<String?>):
        case const (List<Object?>):
        case const (List<dynamic>):
          try {
            await neuePrefs.setStringList(
              key,
              (value! as List<Object?>).cast<String>(),
            );
          } on TypeError catch (
            _
          ) {} // Pass over Lists containing non-String values.
      }
    }

    await neuePrefs.setBool(migrationCompletedKey, true);

    return;
  }
}

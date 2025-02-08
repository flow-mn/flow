import "package:local_settings/local_settings.dart";
import "package:shared_preferences/shared_preferences.dart";

class PendingTransactionsLocalPreferences {
  final SharedPreferences _prefs;

  static PendingTransactionsLocalPreferences? _instance;

  factory PendingTransactionsLocalPreferences() {
    if (_instance == null) {
      throw Exception(
        "You must initialize PendingTransactionsLocalPreferences by calling initialize().",
      );
    }

    return _instance!;
  }

  static const int homeTimeframeDefault = 3;
  static final int earlyReminderInSecondsDefault =
      const Duration(days: 1).inSeconds;

  late final BoolSettingsEntry requireConfrimation;

  /// Shows next [homeTabPlannedTransactionsDays] days of planned transactions in the home tab
  late final PrimitiveSettingsEntry<int> homeTimeframe;

  /// Whether to use date of confirmation for `transactionDate` for pending transactions
  late final BoolSettingsEntry updateDateUponConfirmation;

  /// Whether to send push notifications at the time of the planned transaction.
  ///
  /// Also see [earlyReminderSeconds]
  late final BoolSettingsEntry notify;

  late final PrimitiveSettingsEntry<int> earlyReminderInSeconds;

  PendingTransactionsLocalPreferences._internal(this._prefs) {
    SettingsEntry.defaultPrefix = "flow.pendingTransactions.";

    requireConfrimation = BoolSettingsEntry(
      key: "requireConfrimation",
      preferences: _prefs,
      initialValue: true,
    );

    homeTimeframe = PrimitiveSettingsEntry<int>(
      key: "homeTimeframe",
      preferences: _prefs,
      initialValue: homeTimeframeDefault,
    );
    updateDateUponConfirmation = BoolSettingsEntry(
      key: "updateDateUponConfirmation",
      preferences: _prefs,
      initialValue: true,
    );
    notify = BoolSettingsEntry(
      key: "notify",
      preferences: _prefs,
      initialValue: true,
    );
    earlyReminderInSeconds = PrimitiveSettingsEntry<int>(
      key: "earlyReminderInSeconds",
      preferences: _prefs,
      initialValue: earlyReminderInSecondsDefault,
    );
  }

  static PendingTransactionsLocalPreferences initialize(
    SharedPreferences instance,
  ) =>
      _instance ??= PendingTransactionsLocalPreferences._internal(instance);
}

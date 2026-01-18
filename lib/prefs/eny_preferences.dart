import "package:local_settings/local_settings.dart";
import "package:shared_preferences/shared_preferences.dart";

class EnyLocalPreferences {
  final SharedPreferencesWithCache _prefs;

  static EnyLocalPreferences? _instance;

  factory EnyLocalPreferences() {
    if (_instance == null) {
      throw Exception(
        "You must initialize PendingTransactionsLocalPreferences by calling initialize().",
      );
    }

    return _instance!;
  }

  late final PrimitiveSettingsEntry<String> apiKey;
  late final PrimitiveSettingsEntry<String> email;
  late final StringListSettingsEntry pendingReceipts;

  EnyLocalPreferences._internal(this._prefs) {
    SettingsEntry.defaultPrefix = "flow.eny.";

    apiKey = PrimitiveSettingsEntry<String>(key: "apiKey", preferences: _prefs);

    email = PrimitiveSettingsEntry<String>(key: "email", preferences: _prefs);

    pendingReceipts = StringListSettingsEntry(
      key: "pendingReceipts",
      preferences: _prefs,
      removeDuplicates: true,
    );
  }

  static EnyLocalPreferences initialize(SharedPreferencesWithCache instance) =>
      _instance ??= EnyLocalPreferences._internal(instance);
}

import "package:local_settings/local_settings.dart";
import "package:shared_preferences/shared_preferences.dart";

class GoogleLocalPreferences {
  final SharedPreferencesWithCache _prefs;

  static GoogleLocalPreferences? _instance;

  factory GoogleLocalPreferences(SharedPreferences prefs) {
    if (_instance == null) {
      throw Exception(
        "You must initialize GoogleLocalPreferences by calling initialize().",
      );
    }

    return _instance!;
  }

  late final PrimitiveSettingsEntry<String> currentEmail;
  late final BoolSettingsEntry hasSignedIn;

  GoogleLocalPreferences._internal(this._prefs) {
    SettingsEntry.defaultPrefix = "flow.";

    currentEmail = PrimitiveSettingsEntry<String>(
      key: "google.currentEmail",
      preferences: _prefs,
    );
    hasSignedIn = BoolSettingsEntry(
      key: "google.hasSignedIn",
      preferences: _prefs,
      initialValue: false,
    );
  }

  static GoogleLocalPreferences initialize(
    SharedPreferencesWithCache instance,
  ) => _instance ??= GoogleLocalPreferences._internal(instance);
}

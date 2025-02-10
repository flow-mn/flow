import "package:flow/theme/color_themes/registry.dart";
import "package:local_settings/local_settings.dart";
import "package:shared_preferences/shared_preferences.dart";

class ThemeLocalPreferences {
  final SharedPreferences _prefs;

  static ThemeLocalPreferences? _instance;

  factory ThemeLocalPreferences(SharedPreferences prefs) {
    if (_instance == null) {
      throw Exception(
        "You must initialize ThemeLocalPreferences by calling initialize().",
      );
    }

    return _instance!;
  }

  late final PrimitiveSettingsEntry<String> themeName;
  late final BoolSettingsEntry themeChangesAppIcon;

  ThemeLocalPreferences._internal(this._prefs) {
    SettingsEntry.defaultPrefix = "flow.";

    themeName = PrimitiveSettingsEntry<String>(
      key: "themeName",
      preferences: _prefs,
      initialValue: flowLights.schemes.first.name,
    );
    themeChangesAppIcon = BoolSettingsEntry(
      key: "themeChangesAppIcon",
      preferences: _prefs,
      initialValue: true,
    );
  }

  static ThemeLocalPreferences initialize(SharedPreferences instance) =>
      _instance ??= ThemeLocalPreferences._internal(instance);
}

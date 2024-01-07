import 'package:flow/entity/account.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flutter/material.dart';
import 'package:local_settings/local_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This class contains everything that's stored on
/// device. Such as user preferences and per-device
/// settings
class LocalPreferences {
  final SharedPreferences _prefs;

  late final PrimitiveSettingsEntry<String> primaryCurrency;
  late final BoolSettingsEntry usePhoneNumpadLayout;
  late final BoolSettingsEntry enableNumpadHapticFeedback;

  late final ThemeModeSettingsEntry themeMode;
  late final LocaleSettingsEntry localeOverride;

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

    themeMode = ThemeModeSettingsEntry(
      key: "flow.themeMode",
      preferences: _prefs,
      initialValue: ThemeMode.system,
    );
    localeOverride = LocaleSettingsEntry(
      key: "flow.localeOverride",
      preferences: _prefs,
      initialValue: const Locale("en", "US"),
    );
  }

  String getPrimaryCurrency() {
    String? primaryCurrency = LocalPreferences().primaryCurrency.value;

    if (primaryCurrency == null) {
      final String? firstAccountCurency = ObjectBox()
          .box<Account>()
          .query()
          .order(Account_.createdDate)
          .build()
          .findFirst()
          ?.currency;

      if (firstAccountCurency == null) {
        throw StateError(
            "Failed to recover primary currency because user don't have any accounts");
      }

      primaryCurrency = firstAccountCurency;
    }

    return primaryCurrency;
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

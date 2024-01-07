import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FlowLocalizations {
  final Locale locale;
  static Map<String, String> _localizedValues = {};

  FlowLocalizations(this.locale);

  Future<void> load() async {
    String jsonStringValues =
        await rootBundle.loadString('assets/l10n/${locale.code}.json');
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  static String _fillFromTable(Map lookupTable, String text) {
    for (final key in lookupTable.keys) {
      text = text.replaceAll(
          "{$key}",
          lookupTable[key] is String
              ? lookupTable[key]
              : lookupTable[key].toString());
    }

    return text;
  }

  static String getTransalation(String? key, {dynamic replace}) {
    if (key == null) return "";
    if (_localizedValues.isEmpty) return "";

    final String translatedText = _localizedValues[key] ?? key;

    return switch (replace) {
      null => translatedText,
      String singleValue => translatedText.replaceAll("{}", singleValue),
      num singleValue =>
        translatedText.replaceAll("{}", singleValue.toString()),
      Map lookupTable => _fillFromTable(lookupTable, translatedText),
      _ => translatedText,
    };
  }

  String get(String? key, {dynamic replace}) =>
      getTransalation(key, replace: replace);

  static const List<Locale> supportedLanguages = [
    Locale("en", "US"), // Will fallback to this for unsupported locales
    Locale("mn", "MN"),
  ];

  static FlowLocalizations of(BuildContext context) =>
      Localizations.of<FlowLocalizations>(context, FlowLocalizations)!;

  static int supportedLanguagesCount = supportedLanguages.length;

  static printMissingKeys() async {
    final Map<String, Map<String, String>> languages = {};
    for (Locale locale in supportedLanguages) {
      String value =
          await rootBundle.loadString('assets/lang/${locale.code}.json');

      languages[locale.code] = (json.decode(value) as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value.toString()));
    }
    final Set<String> keys = <String>{};
    for (var key in languages.keys) {
      keys.addAll(languages[key]!.keys);
    }

    for (var key in languages.keys) {
      final Iterable<String> missingKeys =
          keys.where((element) => !languages[key]!.keys.contains(element));
      if (missingKeys.isEmpty) {
        log("[Gegee Language Service] $key has no missing keys");
      } else {
        log("[Gegee Language Service] $key has ${missingKeys.length} missing keys");
        for (var element in missingKeys) {
          log(element);
        }
      }
      log("-------------------");
    }
  }

  static const LocalizationsDelegate<FlowLocalizations> delegate =
      _FlowLocalizationDelegate();
}

class _FlowLocalizationDelegate
    extends LocalizationsDelegate<FlowLocalizations> {
  const _FlowLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return FlowLocalizations.supportedLanguages.contains(locale);
  }

  @override
  Future<FlowLocalizations> load(Locale locale) async {
    FlowLocalizations localization = FlowLocalizations(
      FlowLocalizations.supportedLanguages.contains(locale)
          ? locale
          : FlowLocalizations.supportedLanguages[1],
    );
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<FlowLocalizations> old) => false;
}

extension Underscore on Locale {
  /// Example outcome:
  /// * en_US
  /// * mn_Mong_MN
  String get code => [languageCode, scriptCode, countryCode]
      .where((element) => element != null)
      .join("_");
}

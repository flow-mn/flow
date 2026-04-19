import "dart:convert";

import "package:flow/l10n/supported_languages.dart";
import "package:flow/services/widget_summary_sync.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";
import "package:logging/logging.dart";
import "package:flow/l10n/extensions.dart";

export "extensions.dart";

final Logger _log = Logger("FlowLocalizations");

class FlowLocalizations {
  final Locale locale;
  static Map<String, String> _localizedValues = {};
  static Map<String, String> _enUS = {};

  FlowLocalizations(this.locale);

  static Future<Map<String, String>> _loadLocale(Locale locale) async {
    String jsonStringValues = await rootBundle.loadString(
      "assets/l10n/${locale.code}.json",
    );
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    return mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  Future<void> load() async {
    _localizedValues = await _loadLocale(locale);

    if (_enUS.isEmpty) {
      if (locale.code == "en") {
        _enUS = {..._localizedValues};
      } else {
        _enUS = await _loadLocale(Locale("en"));
      }
    }
  }

  static String _fillFromTable(Map lookupTable, String text) {
    for (final key in lookupTable.keys) {
      text = text.replaceAll(
        "{$key}",
        lookupTable[key] is String
            ? lookupTable[key]
            : lookupTable[key].toString(),
      );
    }

    return text;
  }

  static String getTransalation(String? key, {dynamic replace}) {
    if (key == null) return "";
    if (_localizedValues.isEmpty) return "";

    final String translatedText = _localizedValues[key] ?? _enUS[key] ?? key;

    return switch (replace) {
      null => translatedText,
      String singleValue => translatedText.replaceAll(
        RegExp(r"{[^}]*}"),
        singleValue,
      ),
      num singleValue => translatedText.replaceAll(
        RegExp(r"{[^}]*}"),
        singleValue.toString(),
      ),
      Map lookupTable => _fillFromTable(lookupTable, translatedText),
      _ => translatedText,
    };
  }

  String get(String? key, {dynamic replace}) =>
      getTransalation(key, replace: replace);

  static List<Locale> get supportedLocales => supportedLanguages.keys.toList();

  static FlowLocalizations of(BuildContext context) =>
      Localizations.of<FlowLocalizations>(context, FlowLocalizations)!;

  static int supportedLanguagesCount = supportedLocales.length;

  static void printMissingKeys() async {
    final Map<String, Map<String, String>> languages = {};
    for (Locale locale in supportedLocales) {
      String value = await rootBundle.loadString(
        "assets/l10n/${locale.code}.json",
      );

      languages[locale.code] = (json.decode(value) as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value.toString()),
      );
    }
    final Set<String> keys = <String>{};
    for (var key in languages.keys) {
      keys.addAll(languages[key]!.keys);
    }

    for (var key in languages.keys) {
      final Iterable<String> missingKeys = keys.where(
        (element) => !languages[key]!.keys.contains(element),
      );
      if (missingKeys.isEmpty) {
        _log.fine("[Gegee Language Service] $key has no missing keys");
      } else {
        _log.warning(
          "[Gegee Language Service] $key has ${missingKeys.length} missing keys",
        );
        for (var element in missingKeys) {
          _log.warning(element);
        }
      }
      _log.finest("-------------------");
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
    return FlowLocalizations.supportedLocales.contains(locale);
  }

  @override
  Future<FlowLocalizations> load(Locale locale) async {
    FlowLocalizations localization = FlowLocalizations(
      FlowLocalizations.supportedLocales.contains(locale)
          ? locale
          : FlowLocalizations.supportedLocales[1],
    );
    await localization.load();
    WidgetSummarySync.sync();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<FlowLocalizations> old) => false;
}

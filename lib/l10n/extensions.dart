import "package:flow/l10n/flow_localizations.dart";
import "package:flutter/widgets.dart";

extension L10nHelper on BuildContext {
  FlowLocalizations get l => FlowLocalizations.of(this);
}

/// No need to specify the regoin/country unless:
///
/// * The dialect is very different from other dialects of the same language
/// * We have multiple region/dialect support for the same language
final Map<String, (String, String)> _localeNames = {
  "mn_MN": ("Mongolian (Mongolia)", "Монгол (Монгол)"),
  "en_US": ("English (US)", "English (US)"),
  "en_IN": ("English (India)", "English (India)"),
  "it_IT": ("Italian (Italy)", "Italiano (Italia)"),
  "tr_TR": ("Turkish (Turkey)", "Türkçe (Türkiye)"),
  "fr_FR": ("French (France)", "Français (France)"),
};

extension Underscore on Locale {
  /// Example outcome:
  /// * en_US
  /// * mn_Mong_MN
  String get code => [languageCode, scriptCode, countryCode].nonNulls.join("_");

  /// English name
  String get name => _localeNames[code]?.$1 ?? "Unknown";

  /// Language name in the language
  String get endonym => _localeNames[code]?.$2 ?? "Unknown";
}

extension L10nStringHelper on String {
  /// Returns localized version of [this].
  ///
  /// Same as calling context.l.get([this])
  String t(BuildContext context, [dynamic replace]) =>
      context.l.get(this, replace: replace);

  /// Returns localized version of [this].
  ///
  /// This does not require a context
  String tr([dynamic replace]) =>
      FlowLocalizations.getTransalation(this, replace: replace);
}

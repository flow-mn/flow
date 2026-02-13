import "dart:ui";

/// Locale - (English name, Endonym)
///
/// * You have to include a country if the [Locale.countryCode] is not null.
/// * Your file name must match `languageCode_scriptCode_countryCode` format. But both `scriptCode` and `countryCode` is optional.
final Map<Locale, (String, String)> supportedLanguages = {
  const Locale("mn", "MN"): ("Mongolian (Mongolia)", "Монгол (Монгол)"),
  const Locale("en"): ("English", "English"),
  const Locale("cs", "CZ"): ("Czech (Czechia)", "Čeština (Česko)"),
  const Locale("it", "IT"): ("Italian (Italy)", "Italiano (Italia)"),
  const Locale("tr", "TR"): ("Turkish (Turkey)", "Türkçe (Türkiye)"),
  const Locale("fr", "FR"): ("French (France)", "Français (France)"),
  const Locale("de", "DE"): ("German (Germany)", "Deutsch (Deutschland)"),
  const Locale("ru", "RU"): ("Russian (Russia)", "Русский (Россия)"),
  const Locale("es", "ES"): ("Spanish (Spain)", "Español (España)"),
  const Locale("uk", "UA"): ("Ukrainian (Ukraine)", "Українська (Україна)"),
  const Locale("ar"): ("Arabic", "العربية"),
  const Locale("fa", "IR"): ("Persian (Iran)", "فارسی (ایران)"),
};

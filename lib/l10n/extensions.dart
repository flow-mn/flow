import 'package:flow/l10n/flow_localizations.dart';
import 'package:flow/prefs.dart';
import 'package:flutter/widgets.dart';

import 'package:intl/intl.dart';

extension L10nHelper on BuildContext {
  FlowLocalizations get l => FlowLocalizations.of(this);
}

/// No need to specify the regoin/country unless:
///
/// * The dialect is very different from other dialects of the same language
/// * We have multiple region/dialect support for the same language
final Map<String, (String, String)> _localeNames = {
  "mn_MN": ("Mongolian", "Монгол"),
  "en_US": ("Default", "English"),
  "it_IT": ("Italian", "Italiano"),
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
  /// Same as calling context.l.get([this])
  String tr([dynamic replace]) =>
      FlowLocalizations.getTransalation(this, replace: replace);
}

extension MoneyFormatters on num {
  String formatMoney({
    String? currency,
    bool includeCurrency = true,
    bool useCurrencySymbol = true,
    bool compact = false,
    bool takeAbsoluteValue = false,
    int? decimalDigits,
  }) {
    final num amount = takeAbsoluteValue ? abs() : this;

    if (!includeCurrency) {
      currency = "";
      useCurrencySymbol = false;
    } else {
      currency ??= LocalPreferences().getPrimaryCurrency();
    }

    final String? symbol = useCurrencySymbol
        ? NumberFormat.simpleCurrency(
            locale: Intl.defaultLocale,
            name: currency,
          ).currencySymbol
        : null;

    if (compact) {
      return NumberFormat.compactCurrency(
        locale: Intl.defaultLocale,
        name: currency,
        symbol: symbol,
        decimalDigits: decimalDigits,
      ).format(amount);
    }

    return NumberFormat.currency(
      locale: Intl.defaultLocale,
      name: currency,
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  /// Returns money-formatted string in the primary currency
  /// in the default locale
  ///
  /// e.g., $420.69
  String get money => formatMoney();

  /// Returns compact money-formatted string in the primary
  /// currency in the default locale
  ///
  /// e.g., $1.2M
  String get moneyCompact => formatMoney(compact: true);

  /// Returns money-formatted string (in the default locale)
  ///
  /// e.g., 467,000
  String get moneyNoMarker => formatMoney(includeCurrency: false);

  /// Returns money-formatted string (in the default locale)
  ///
  /// e.g., 1.2M
  String get moneyNoMarkerCompact => formatMoney(
        includeCurrency: false,
        compact: true,
      );
}

import 'package:flow/l10n/l10n.dart';
import 'package:flow/prefs.dart';
import 'package:flutter/widgets.dart';

import 'package:intl/intl.dart';

extension L10nHelper on BuildContext {
  FlowLocalizations get l => FlowLocalizations.of(this);
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
    bool useSymbol = true,
    bool compact = false,
    int? decimalDigits,
  }) {
    if (!includeCurrency) {
      currency = "";
      useSymbol = false;
    } else {
      currency ??= LocalPreferences().getPrimaryCurrency();
    }

    final String? symbol = useSymbol
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
      ).format(this);
    }

    return NumberFormat.currency(
      locale: Intl.defaultLocale,
      name: currency,
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(this);
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

import "package:flow/utils/replace_everything_except.dart";
import "package:intl/intl.dart";

double? parseLocaleMoneyString({
  required String? text,
  required String locale,
  bool guardSwappedDecimalIndicators = true,
}) {
  text = text?.trim();

  if (text == null || text.isEmpty) {
    return null;
  }

  if (guardSwappedDecimalIndicators) {
    final NumberFormat numberFormat = NumberFormat.currency(locale: locale);
    final int decimalSepIndex = text.indexOf(numberFormat.symbols.DECIMAL_SEP);
    final int groupSepIndex = text.indexOf(numberFormat.symbols.GROUP_SEP);

    if (decimalSepIndex != -1 && groupSepIndex != -1) {
      if (groupSepIndex > decimalSepIndex) {
        text = text
            .replaceAll(numberFormat.symbols.DECIMAL_SEP, "")
            .replaceAll(
              numberFormat.symbols.GROUP_SEP,
              numberFormat.symbols.DECIMAL_SEP,
            );
      }
    }
  }

  final NumberFormat numberFormat = NumberFormat.currency(locale: locale);
  final String normalized = replaceEverythingExcept(text, [
    numberFormat.symbols.DECIMAL_SEP,
    numberFormat.symbols.GROUP_SEP,
    ...List.generate(10, (index) => index.toString()),
  ]);

  return numberFormat.parse(normalized).toDouble();
}

double? parseMoneyString({
  String? text,
  String? locale,
  bool guardSwappedDecimalIndicators = true,
}) {
  text = text?.trim();

  if (text == null || text.isEmpty) {
    return null;
  }

  try {
    return double.parse(text);
  } catch (e) {
    //
  }

  final String effectiveLocale =
      locale?.replaceAll("-", "_") ?? Intl.defaultLocale ?? Intl.systemLocale;

  try {
    return parseLocaleMoneyString(
      text: text,
      locale: effectiveLocale,
      guardSwappedDecimalIndicators: guardSwappedDecimalIndicators,
    );
  } catch (e) {
    //
  }

  try {
    return parseLocaleMoneyString(
      text: text,
      locale: "en_US",
      guardSwappedDecimalIndicators: guardSwappedDecimalIndicators,
    );
  } catch (e) {
    //
  }

  return null;
}

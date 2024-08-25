import "package:intl/intl.dart";

String getDecimalSeparatorForCurrency(String? currency) {
  return currency == null
      ? "."
      : NumberFormat.simpleCurrency(name: currency).symbols.DECIMAL_SEP;
}

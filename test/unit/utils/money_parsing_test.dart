import "package:flow/utils/money_parsing.dart";
import "package:flutter_test/flutter_test.dart";
import "package:intl/intl.dart";

void main() {
  group("Money parsing utility", () {
    Intl.defaultLocale = "en_US";
    test("Valid money strings are parsed correctly", () {
      expect(parseMoneyString(text: "123.45"), 123.45);
      expect(parseMoneyString(text: "\$1,234.56"), 1234.56);
      Intl.defaultLocale = "fr_FR";
      expect(parseMoneyString(text: "€1.234,56"), 1234.56);
      Intl.defaultLocale = "en_US";
      expect(parseMoneyString(text: "€1.234,56"), 1234.56);
      expect(parseMoneyString(text: "  7890  "), 7890.0);
    });

    test("Invalid money strings return null", () {
      expect(parseMoneyString(text: "abc"), null);
      expect(parseMoneyString(text: ""), null);
      expect(parseMoneyString(text: null), null);
      expect(parseMoneyString(text: "12.34.56"), null);
    });
  });
}

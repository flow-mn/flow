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
      expect(parseMoneyString(text: "0.01"), 0.01);
      expect(parseMoneyString(text: "-50.99"), -50.99);
      expect(parseMoneyString(text: "999999.99"), 999999.99);
    });

    test("Invalid money strings return null", () {
      expect(parseMoneyString(text: "abc"), null);
      expect(parseMoneyString(text: ""), null);
      expect(parseMoneyString(text: null), null);
      expect(parseMoneyString(text: "12.34.56"), null);
      expect(parseMoneyString(text: "12.34.56.90"), null);
      expect(parseMoneyString(text: r"$$$"), null);
    });

    test("Edge cases with different formats", () {
      expect(parseMoneyString(text: "0"), 0.0);
      expect(parseMoneyString(text: ".50"), 0.50);
      expect(parseMoneyString(text: "100."), 100.0);
      Intl.defaultLocale = "de_DE";
      expect(parseMoneyString(text: "1.234,56"), 1234.56);
      expect(parseMoneyString(text: ",56"), 0.56);
      Intl.defaultLocale = "en_US";
    });

    test("Locale specific parsing for European formats", () {
      Intl.defaultLocale = "de_DE";
      expect(parseMoneyString(text: "1.234.567,89"), 1234567.89);
      expect(parseMoneyString(text: "999,99"), 999.99);
      Intl.defaultLocale = "fr_FR";
      expect(parseMoneyString(text: "1 234,56"), 1234.56);
      expect(parseMoneyString(text: "50,5"), 50.5);
      Intl.defaultLocale = "it_IT";
      expect(parseMoneyString(text: "1.234,56"), 1234.56);
      Intl.defaultLocale = "en_US";
    });

    test("Locale specific parsing for Asian formats", () {
      Intl.defaultLocale = "ja_JP";
      expect(parseMoneyString(text: "1,234.56"), 1234.56);
      Intl.defaultLocale = "zh_CN";
      expect(parseMoneyString(text: "1,234.56"), 1234.56);
      Intl.defaultLocale = "en_US";
      expect(parseMoneyString(text: "1,234.56"), 1234.56);
    });

    test("Locale specific parsing for Arabic formats", () {
      Intl.defaultLocale = "ar_EG";
      expect(parseMoneyString(text: "1.234,56"), 1234.56);
      expect(parseMoneyString(text: "999.99"), 999.99);
      Intl.defaultLocale = "ar_SA";
      expect(parseMoneyString(text: "1,234.56"), 1234.56);
      Intl.defaultLocale = "en_US";
    });

    test("Locale specific parsing for Persian formats", () {
      Intl.defaultLocale = "fa_IR";
      expect(parseMoneyString(text: "1,234.56"), 1234.56);
      expect(parseMoneyString(text: "999.99"), 999.99);
      Intl.defaultLocale = "en_US";
    });
  });
}

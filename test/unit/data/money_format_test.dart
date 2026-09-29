import "package:flow/data/money.dart";
import "package:flow/services/user_preferences.dart";
import "package:flutter_test/flutter_test.dart";
import "package:intl/intl.dart";

void main() {
  setUp(() {
    Intl.defaultLocale = "en_US";
  });

  tearDown(() {
    UserPreferencesService().value.hideZeroDecimals = false;
  });

  test("Shows zero decimals by default", () {
    expect(Money(3.0, "USD").formatted, equals(r"$3.00"));
  });

  test("Hides zero decimals per amount when enabled", () {
    UserPreferencesService().value.hideZeroDecimals = true;

    expect(Money(3.0, "USD").formatted, equals(r"$3"));
    expect(Money(1.23, "USD").formatted, equals(r"$1.23"));
    expect(Money(1.5, "USD").formatted, equals(r"$1.50"));
    expect(Money(1200000.0, "USD").formattedCompact, equals(r"$1.2M"));
  });
}

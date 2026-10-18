import "package:flow/utils/loose_parsers.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("looseDouble rejects non-finite values", () {
    expect(looseDouble("NaN"), isNull);
    expect(looseDouble("Infinity"), isNull);
    expect(looseDouble(double.infinity), isNull);
    expect(looseDouble("1e400"), isNull);
    expect(looseDouble("12.5"), 12.5);
    expect(looseDouble(3), 3.0);
    expect(looseDouble(null), isNull);
  });
}

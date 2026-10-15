import "package:decimal/decimal.dart";
import "package:flow/routes/transaction_page/input_amount_sheet/input_value.dart";
import "package:flutter_test/flutter_test.dart";

InputValue _value(String source) =>
    InputValue.fromDecimal(Decimal.parse(source));

Decimal _decimal(String source) => Decimal.parse(source);

void main() {
  group("InputValue arithmetic", () {
    test("Decimal fractions add up exactly", () {
      final InputValue sum = _value("0.1") + _value("0.2");

      expect(sum.decimalAmount, _decimal("0.3"));
      expect(sum.decimalLength, 1);
      expect(sum.currentAmount, 0.3);

      final InputValue other = _value("2.1") + _value("2.2");

      expect(other.decimalAmount, _decimal("4.3"));
      expect(other.decimalLength, 1);
      expect(other.currentAmount, 4.3);
    });

    test("Values from doubles add up exactly", () {
      final InputValue sum = InputValue.fromDouble(
        0.1,
      ).add(InputValue.fromDouble(0.2), maxNumberOfDecimals: 2);

      expect(sum.decimalAmount, _decimal("0.3"));
      expect(sum.currentAmount, 0.3);
    });

    test("Division rounds to the configured precision", () {
      final InputValue ten = _value("10");
      final InputValue three = _value("3");

      final InputValue twoDecimals = ten.divide(three, maxNumberOfDecimals: 2);
      expect(twoDecimals.decimalAmount, _decimal("3.33"));
      expect(twoDecimals.decimalLength, 2);

      expect((ten / three).decimalAmount, _decimal("3.33333333"));

      expect(
        _value("2").divide(three, maxNumberOfDecimals: 2).decimalAmount,
        _decimal("0.67"),
      );
      expect(
        _value("1").divide(_value("8"), maxNumberOfDecimals: 2).decimalAmount,
        _decimal("0.13"),
      );
    });

    test("Exact division keeps no trailing zeros", () {
      final InputValue result = _value(
        "10",
      ).divide(_value("4"), maxNumberOfDecimals: 2);

      expect(result.decimalAmount, _decimal("2.5"));
      expect(result.decimalLength, 1);

      final InputValue whole = _value(
        "10",
      ).divide(_value("5"), maxNumberOfDecimals: 2);

      expect(whole.decimalAmount, _decimal("2"));
      expect(whole.decimalLength, 0);
    });

    test("Chained operations", () {
      final InputValue result = (_value("0.1") + _value("0.2"))
          .multiply(_value("3"))
          .subtract(_value("0.9"));

      expect(result, InputValue.zero);

      final InputValue roundTrip = _value(
        "100",
      ).divide(_value("3"), maxNumberOfDecimals: 2).multiply(_value("3"));

      expect(roundTrip.decimalAmount, _decimal("99.99"));

      final InputValue mixed = _value(
        "19.99",
      ).multiply(_value("3")).add(_value("0.03")).divide(_value("2"));

      expect(mixed.decimalAmount, _decimal("30"));
    });

    test("Multiplication rounds to the configured precision", () {
      final InputValue result = _value(
        "1.25",
      ).multiply(_value("1.25"), maxNumberOfDecimals: 2);

      expect(result.decimalAmount, _decimal("1.56"));
    });

    test("Negative values", () {
      final InputValue sum = _value("-5.5") + _value("2.25");
      expect(sum.decimalAmount, _decimal("-3.25"));
      expect(sum.isNegative, true);

      final InputValue difference = _value("-0.1") - _value("0.2");
      expect(difference.decimalAmount, _decimal("-0.3"));
      expect(difference.currentAmount, -0.3);

      expect((_value("-6") / _value("4")).decimalAmount, _decimal("-1.5"));
      expect((_value("-6") * _value("-0.5")).decimalAmount, _decimal("3"));

      expect(
        _value("-2").divide(_value("3"), maxNumberOfDecimals: 2).decimalAmount,
        _decimal("-0.67"),
      );
      expect(
        _value("-1").divide(_value("8"), maxNumberOfDecimals: 2).decimalAmount,
        _decimal("-0.13"),
      );

      final InputValue zero = _value("-1.5") + _value("1.5");
      expect(zero, InputValue.zero);
      expect(zero.isNegative, false);
    });

    test("Division by zero results in zero", () {
      expect(() => _value("10") / InputValue.zero, returnsNormally);
      expect(_value("10") / InputValue.zero, InputValue.zero);
      expect(_value("-10") / _value("0.00"), InputValue.zero);
      expect(InputValue.zero / InputValue.zero, InputValue.zero);
    });

    test("Large numbers", () {
      final InputValue sum = _value("99999999999999.99") + _value("0.01");
      expect(sum.decimalAmount, _decimal("100000000000000"));
      expect(sum.wholePart, 100000000000000);
      expect(sum.decimalLength, 0);

      final InputValue product = _value("12345678901234.56") * _value("2");
      expect(product.decimalAmount, _decimal("24691357802469.12"));

      final InputValue difference =
          _value("99999999999999.99") - _value("99999999999999.98");
      expect(difference.decimalAmount, _decimal("0.01"));

      expect(
        () => InputValue.fromDouble(1e14) * InputValue.fromDouble(1e14),
        returnsNormally,
      );
    });

    test("Comparison and equality", () {
      expect(InputValue.fromDouble(1.5), _value("1.50"));
      expect(InputValue.fromDouble(1.5).hashCode, _value("1.50").hashCode);
      expect(_value("0.3").compareTo(_value("0.1") + _value("0.2")), 0);
      expect(_value("-1").compareTo(_value("0.01")), lessThan(0));
    });
  });

  group("InputValue conversions", () {
    test("Round trips through double", () {
      final InputValue regular = InputValue.fromDouble(123456789.12);
      expect(regular.wholePart, 123456789);
      expect(regular.decimalPart, 12);
      expect(regular.currentAmount, 123456789.12);

      final InputValue small = InputValue.fromDouble(1e-7);
      expect(small.decimalAmount, _decimal("0.0000001"));
      expect(small.decimalLeadingZeroesCount, 6);
      expect(small.currentAmount, 1e-7);

      final InputValue negativeSmall = InputValue.fromDouble(-1.5e-7);
      expect(negativeSmall.decimalAmount, _decimal("-0.00000015"));
      expect(negativeSmall.currentAmount, -1.5e-7);

      for (final double value in [0.3, 4.3, -50.99, 0.05, 1234.5, 1e13]) {
        expect(InputValue.fromDouble(value).currentAmount, value);
      }
    });

    test("Rounds to the configured precision", () {
      expect(
        InputValue.fromDouble(1e-7, maxNumberOfDecimals: 2),
        InputValue.zero,
      );
      expect(
        InputValue.fromDouble(2.345, maxNumberOfDecimals: 2).decimalAmount,
        _decimal("2.35"),
      );
      expect(
        InputValue.fromDouble(0.005, maxNumberOfDecimals: 2).decimalAmount,
        _decimal("0.01"),
      );
    });

    test("Handles exponential notation and non-finite values", () {
      expect(() => InputValue.fromDouble(1e21), returnsNormally);
      expect(InputValue.fromDouble(1e21).isNegative, false);
      expect(InputValue.fromDouble(1e20).decimalPart, 0);

      expect(InputValue.fromDouble(double.infinity), InputValue.zero);
      expect(InputValue.fromDouble(double.nan), InputValue.zero);
      expect(InputValue.fromDouble(-0.0).isNegative, false);
    });

    test("Typed digits match their decimal value", () {
      final InputValue typed = InputValue.zero
          .appendWhole(1)
          .appendDecimal(0)
          .appendDecimal(5);

      expect(typed.decimalAmount, _decimal("1.05"));
      expect(typed.currentAmount, 1.05);

      final InputValue trailingZero = InputValue.zero
          .appendWhole(2)
          .appendDecimal(0);

      expect(trailingZero.decimalLength, 1);
      expect(trailingZero.decimalAmount, _decimal("2"));
    });
  });
}

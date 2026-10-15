import "dart:math" as math;

import "package:decimal/decimal.dart";

class InputValue implements Comparable<InputValue> {
  static const int _defaultMaxNumberOfDecimals = 8;

  final int wholePart;
  final int decimalPart;
  final bool isNegative;
  final int decimalLeadingZeroesCount;

  int get sign => isNegative ? -1 : 1;

  int get decimalLength =>
      decimalLeadingZeroesCount +
      (decimalPart == 0 ? 0 : decimalPart.abs().toString().length);

  /// Exact value, used for calculations
  Decimal get decimalAmount {
    final String decimals = "${"0" * decimalLeadingZeroesCount}$decimalPart";

    return Decimal.parse("${isNegative ? "-" : ""}$wholePart.$decimals");
  }

  double get currentAmount => double.parse(decimalAmount.toString());

  const InputValue({
    required this.wholePart,
    required this.decimalPart,
    required this.isNegative,
    required this.decimalLeadingZeroesCount,
  }) : assert(wholePart >= 0, "wholePart must be greater than or equal to 0"),
       assert(
         decimalPart >= 0,
         "decimalPart must be greater than or equal to 0",
       );

  factory InputValue.fromDouble(
    double value, {
    int maxNumberOfDecimals = _defaultMaxNumberOfDecimals,
  }) {
    if (!value.isFinite) return zero;

    // [Decimal.parse] also handles exponential notation (e.g., 1e-7, 1e+21)
    return InputValue.fromDecimal(
      Decimal.parse(value.toString()),
      maxNumberOfDecimals: maxNumberOfDecimals,
    );
  }

  /// Rounds (half away from zero) to [maxNumberOfDecimals]
  factory InputValue.fromDecimal(
    Decimal value, {
    int maxNumberOfDecimals = _defaultMaxNumberOfDecimals,
  }) {
    final Decimal rounded = value.round(scale: maxNumberOfDecimals);

    if (rounded == Decimal.zero) return zero;

    final Decimal absolute = rounded.abs();
    final List<String> parts = absolute.toString().split(".");
    final String rawDecimal = parts.length > 1 ? parts.last : "";

    final int decimalPart = int.tryParse(rawDecimal) ?? 0;

    final int decimalLeadingZeroesCount = decimalPart == 0
        ? 0
        : rawDecimal.length - decimalPart.toString().length;

    return InputValue(
      wholePart: absolute.toBigInt().toInt(),
      decimalPart: decimalPart,
      isNegative: rounded < Decimal.zero,
      decimalLeadingZeroesCount: decimalLeadingZeroesCount,
    );
  }

  static const zero = InputValue(
    wholePart: 0,
    decimalPart: 0,
    isNegative: false,
    decimalLeadingZeroesCount: 0,
  );

  InputValue signed(num sign) => InputValue(
    wholePart: wholePart,
    decimalPart: decimalPart,
    isNegative: sign.isNegative,
    decimalLeadingZeroesCount: decimalLeadingZeroesCount,
  );

  InputValue negated([bool? isNegative]) => InputValue(
    wholePart: wholePart,
    decimalPart: decimalPart,
    isNegative: isNegative ?? !this.isNegative,
    decimalLeadingZeroesCount: decimalLeadingZeroesCount,
  );

  InputValue abs() => isNegative
      ? InputValue(
          wholePart: wholePart,
          decimalPart: decimalPart,
          isNegative: false,
          decimalLeadingZeroesCount: decimalLeadingZeroesCount,
        )
      : this;

  InputValue appendWhole(int n) {
    assert(n >= 0 && n <= 9);

    return InputValue(
      wholePart: wholePart * 10 + n,
      decimalPart: decimalPart,
      isNegative: isNegative,
      decimalLeadingZeroesCount: decimalLeadingZeroesCount,
    );
  }

  InputValue appendDecimal(int n) {
    assert(n >= 0 && n <= 9);

    final bool zeroOnZero = n == 0 && decimalPart == 0;

    return InputValue(
      wholePart: wholePart,
      decimalPart: decimalPart * 10 + n,
      isNegative: isNegative,
      decimalLeadingZeroesCount: zeroOnZero
          ? decimalLeadingZeroesCount + 1
          : decimalLeadingZeroesCount,
    );
  }

  InputValue removeWhole() {
    if (wholePart == 0) return this;

    return InputValue(
      wholePart: wholePart ~/ 10,
      decimalPart: decimalPart,
      isNegative: isNegative,
      decimalLeadingZeroesCount: decimalLeadingZeroesCount,
    );
  }

  InputValue removeDecimal() {
    return InputValue(
      wholePart: wholePart,
      decimalPart: decimalPart ~/ 10,
      isNegative: isNegative,
      decimalLeadingZeroesCount: decimalPart == 0
          ? math.max(decimalLeadingZeroesCount - 1, 0)
          : decimalLeadingZeroesCount,
    );
  }

  InputValue truncate() => InputValue(
    wholePart: wholePart,
    decimalPart: 0,
    isNegative: isNegative,
    decimalLeadingZeroesCount: 0,
  );

  InputValue add(
    InputValue other, {
    int maxNumberOfDecimals = _defaultMaxNumberOfDecimals,
  }) => InputValue.fromDecimal(
    decimalAmount + other.decimalAmount,
    maxNumberOfDecimals: maxNumberOfDecimals,
  );
  InputValue subtract(
    InputValue other, {
    int maxNumberOfDecimals = _defaultMaxNumberOfDecimals,
  }) => InputValue.fromDecimal(
    decimalAmount - other.decimalAmount,
    maxNumberOfDecimals: maxNumberOfDecimals,
  );
  InputValue multiply(
    InputValue other, {
    int maxNumberOfDecimals = _defaultMaxNumberOfDecimals,
  }) => InputValue.fromDecimal(
    decimalAmount * other.decimalAmount,
    maxNumberOfDecimals: maxNumberOfDecimals,
  );

  /// Returns [zero] when dividing by zero
  InputValue divide(
    InputValue other, {
    int maxNumberOfDecimals = _defaultMaxNumberOfDecimals,
  }) {
    final Decimal divisor = other.decimalAmount;

    if (divisor == Decimal.zero) return zero;

    return InputValue.fromDecimal(
      (decimalAmount / divisor).toDecimal(
        scaleOnInfinitePrecision: maxNumberOfDecimals,
        toBigInt: (value) => value.round(),
      ),
      maxNumberOfDecimals: maxNumberOfDecimals,
    );
  }

  InputValue operator +(InputValue other) => add(other);
  InputValue operator -(InputValue other) => subtract(other);
  InputValue operator *(InputValue other) => multiply(other);
  InputValue operator /(InputValue other) => divide(other);

  InputValue operator -() => negated();

  InputValue operator ~/(InputValue other) => divide(other).truncate();

  @override
  int get hashCode => decimalAmount.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is InputValue) return decimalAmount == other.decimalAmount;

    if (other is! num) return false;

    return currentAmount == other;
  }

  @override
  int compareTo(InputValue other) =>
      decimalAmount.compareTo(other.decimalAmount);
}

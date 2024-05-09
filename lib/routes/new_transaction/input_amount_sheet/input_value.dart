import "dart:math" as math;

class InputValue implements Comparable<InputValue> {
  final int wholePart;
  final int decimalPart;
  final bool isNegative;
  final int decimalLeadingZeroesCount;

  int get sign => isNegative ? -1 : 1;

  int get decimalLength =>
      decimalLeadingZeroesCount +
      (decimalPart == 0 ? 0 : decimalPart.abs().toString().length);

  double get currentAmount =>
      (wholePart + (decimalPart * math.pow(10.0, -decimalLength).toDouble())) *
      (isNegative ? -1 : 1);

  const InputValue({
    required this.wholePart,
    required this.decimalPart,
    required this.isNegative,
    required this.decimalLeadingZeroesCount,
  })  : assert(wholePart >= 0, 'wholePart must be greater than or equal to 0'),
        assert(
            decimalPart >= 0, 'decimalPart must be greater than or equal to 0');

  factory InputValue.fromDouble(double value, {int maxNumberOfDecimals = 10}) {
    if (value.isInfinite || value.isNaN || value == 0) return zero;

    final int wholePart = value.abs().truncate();

    final String rawDecimal = value
        .toString()
        .split(".")
        .last
        .padRight(maxNumberOfDecimals, '0')
        .substring(0, maxNumberOfDecimals);

    final int decimalPart = int.parse(rawDecimal);

    final int decimalLeadingZeroesCount = decimalPart == 0
        ? 0
        : rawDecimal.length - decimalPart.toString().length;

    return InputValue(
      wholePart: wholePart,
      decimalPart: decimalPart,
      isNegative: value.isNegative,
      decimalLeadingZeroesCount: decimalLeadingZeroesCount,
    );
  }

  static const zero = InputValue(
      wholePart: 0,
      decimalPart: 0,
      isNegative: false,
      decimalLeadingZeroesCount: 0);

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

  InputValue add(InputValue other) =>
      InputValue.fromDouble(currentAmount + other.currentAmount);
  InputValue subtract(InputValue other) =>
      InputValue.fromDouble(currentAmount - other.currentAmount);
  InputValue multiply(InputValue other) =>
      InputValue.fromDouble(currentAmount * other.currentAmount);
  InputValue divide(InputValue other) =>
      InputValue.fromDouble(currentAmount / other.currentAmount);

  InputValue operator +(InputValue other) => add(other);
  InputValue operator -(InputValue other) => subtract(other);
  InputValue operator *(InputValue other) => multiply(other);
  InputValue operator /(InputValue other) => divide(other);

  InputValue operator -() => negated();

  InputValue operator ~/(InputValue other) => divide(other).truncate();

  @override
  int get hashCode => currentAmount.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is InputValue) return currentAmount == other.currentAmount;

    if (other is! num) return false;

    return currentAmount == other;
  }

  @override
  int compareTo(InputValue other) =>
      currentAmount.compareTo(other.currentAmount);
}

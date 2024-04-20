import "dart:math" as math;

class InputValue implements Comparable<InputValue> {
  final int wholePart;
  final int decimalPart;
  final bool isNegative;

  int get sign => isNegative ? -1 : 1;

  int get decimalLength =>
      decimalPart == 0 ? 0 : decimalPart.abs().toString().length;

  double get currentAmount =>
      (wholePart + (decimalPart * math.pow(10.0, -decimalLength).toDouble())) *
      (isNegative ? -1 : 1);

  const InputValue({
    required this.wholePart,
    required this.decimalPart,
    required this.isNegative,
  })  : assert(wholePart >= 0, 'wholePart must be greater than or equal to 0'),
        assert(
            decimalPart >= 0, 'decimalPart must be greater than or equal to 0');

  factory InputValue.fromDouble(double value) {
    final double decimal = (value - value.truncate()).abs();

    final int wholePart = value.abs().truncate();
    final int decimalPart =
        (decimal * math.pow(10, decimal.toString().length - 2)).round();

    return InputValue(
      wholePart: wholePart,
      decimalPart: decimalPart,
      isNegative: value.isNegative,
    );
  }

  static const zero =
      InputValue(wholePart: 0, decimalPart: 0, isNegative: false);

  InputValue signed(num sign) => InputValue(
        wholePart: wholePart,
        decimalPart: decimalPart,
        isNegative: sign.isNegative,
      );

  InputValue negated([bool? isNegative]) => InputValue(
        wholePart: wholePart,
        decimalPart: decimalPart,
        isNegative: isNegative ?? !this.isNegative,
      );

  InputValue abs() => isNegative
      ? InputValue(
          wholePart: wholePart,
          decimalPart: decimalPart,
          isNegative: false,
        )
      : this;

  InputValue appendWhole(int n) {
    assert(n >= 0 && n <= 9);

    return InputValue(
      wholePart: wholePart * 10 + n,
      decimalPart: decimalPart,
      isNegative: isNegative,
    );
  }

  InputValue appendDecimal(int n) {
    assert(n >= 0 && n <= 9);

    return InputValue(
      wholePart: wholePart,
      decimalPart: decimalPart * 10 + n,
      isNegative: isNegative,
    );
  }

  InputValue removeWhole() {
    if (wholePart == 0) return this;

    return InputValue(
      wholePart: wholePart ~/ 10,
      decimalPart: decimalPart,
      isNegative: isNegative,
    );
  }

  InputValue removeDecimal() {
    if (decimalPart == 0) return this;

    return InputValue(
      wholePart: wholePart,
      decimalPart: decimalPart ~/ 10,
      isNegative: isNegative,
    );
  }

  InputValue truncate() => InputValue(
        wholePart: wholePart,
        decimalPart: 0,
        isNegative: isNegative,
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

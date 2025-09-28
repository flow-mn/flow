class ChangeVisuals {
  final bool incomeIncreaseUpArrow;
  final bool incomeIncreaseGreen;
  final bool expenseIncreaseUpArrow;
  final bool expenseIncreaseRed;

  const ChangeVisuals({
    required this.incomeIncreaseUpArrow,
    required this.incomeIncreaseGreen,
    required this.expenseIncreaseUpArrow,
    required this.expenseIncreaseRed,
  });

  static const ChangeVisuals defaults = ChangeVisuals(
    incomeIncreaseUpArrow: true,
    incomeIncreaseGreen: true,
    expenseIncreaseUpArrow: true,
    expenseIncreaseRed: true,
  );

  String serialize() {
    return [
      incomeIncreaseUpArrow ? "1" : "0",
      incomeIncreaseGreen ? "1" : "0",
      expenseIncreaseUpArrow ? "1" : "0",
      expenseIncreaseRed ? "1" : "0",
    ].join("");
  }

  @override
  String toString() => serialize();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChangeVisuals &&
        other.incomeIncreaseUpArrow == incomeIncreaseUpArrow &&
        other.incomeIncreaseGreen == incomeIncreaseGreen &&
        other.expenseIncreaseUpArrow == expenseIncreaseUpArrow &&
        other.expenseIncreaseRed == expenseIncreaseRed;
  }

  @override
  int get hashCode {
    return Object.hash(
      incomeIncreaseUpArrow,
      incomeIncreaseGreen,
      expenseIncreaseUpArrow,
      expenseIncreaseRed,
    );
  }

  ChangeVisuals copyWith({
    bool? incomeIncreaseUpArrow,
    bool? incomeIncreaseGreen,
    bool? expenseIncreaseUpArrow,
    bool? expenseIncreaseRed,
  }) {
    return ChangeVisuals(
      incomeIncreaseUpArrow:
          incomeIncreaseUpArrow ?? this.incomeIncreaseUpArrow,
      incomeIncreaseGreen: incomeIncreaseGreen ?? this.incomeIncreaseGreen,
      expenseIncreaseUpArrow:
          expenseIncreaseUpArrow ?? this.expenseIncreaseUpArrow,
      expenseIncreaseRed: expenseIncreaseRed ?? this.expenseIncreaseRed,
    );
  }

  static ChangeVisuals? tryParse(String? serialized) {
    try {
      if (serialized == null || serialized.length != 4) return null;

      return ChangeVisuals(
        incomeIncreaseUpArrow: serialized[0] == "1",
        incomeIncreaseGreen: serialized[1] == "1",
        expenseIncreaseUpArrow: serialized[2] == "1",
        expenseIncreaseRed: serialized[3] == "1",
      );
    } catch (e) {
      return null;
    }
  }

  static ChangeVisuals parse(String serialized) {
    final ChangeVisuals? parsed = tryParse(serialized);
    if (parsed == null) {
      throw FormatException("Invalid serialized ChangeVisuals: $serialized");
    }
    return parsed;
  }
}

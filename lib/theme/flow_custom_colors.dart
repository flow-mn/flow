import "package:flutter/material.dart";

class FlowCustomColors extends ThemeExtension<FlowCustomColors> {
  /// Color for income
  final Color income;

  /// Color for expense
  final Color expense;

  /// Color for labels, secondary body texts
  final Color semi;

  const FlowCustomColors({
    required this.income,
    required this.expense,
    required this.semi,
  });

  @override
  FlowCustomColors copyWith({Color? income, Color? expense, Color? semi}) {
    return FlowCustomColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      semi: semi ?? this.semi,
    );
  }

  @override
  FlowCustomColors lerp(FlowCustomColors? other, double t) {
    if (other is! FlowCustomColors) return this;

    return FlowCustomColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      semi: Color.lerp(semi, other.semi, t)!,
    );
  }
}

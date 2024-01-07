import 'package:flutter/material.dart';

class FlowColors extends ThemeExtension<FlowColors> {
  /// Color for income
  final Color income;

  /// Color for expense
  final Color expense;

  /// Color for labels, secondary body texts
  final Color semi;

  const FlowColors({
    required this.income,
    required this.expense,
    required this.semi,
  });

  @override
  FlowColors copyWith({
    Color? income,
    Color? expense,
    Color? semi,
  }) {
    return FlowColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      semi: semi ?? this.semi,
    );
  }

  @override
  FlowColors lerp(FlowColors? other, double t) {
    if (other is! FlowColors) return this;

    return FlowColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      semi: Color.lerp(semi, other.semi, t)!,
    );
  }
}

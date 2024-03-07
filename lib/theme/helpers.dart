import 'package:flow/entity/transaction.dart';
import 'package:flow/theme/flow_colors.dart';
import 'package:flutter/material.dart';

extension ThemeAccessor on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  FlowColors get flowColors => Theme.of(this).extension<FlowColors>()!;
}

extension TextStyleHelper on TextStyle {
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle semi(BuildContext context) =>
      copyWith(color: context.flowColors.semi);
}

extension TransactionTypeColor on TransactionType {
  Color color(BuildContext context) => switch (this) {
        TransactionType.income => context.flowColors.income,
        TransactionType.expense => context.flowColors.expense,
        TransactionType.transfer => context.colorScheme.onBackground,
      };
}

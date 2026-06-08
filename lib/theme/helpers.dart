import "package:flow/entity/transaction.dart";
import "package:flow/theme/flow_custom_colors.dart";
import "package:flow/theme/pie_theme_extension.dart";
import "package:flow/theme/primary_colors.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:pie_menu/pie_menu.dart";

extension ThemeAccessor on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  FlowCustomColors get flowColors =>
      Theme.of(this).extension<FlowCustomColors>()!;
  PieTheme get pieTheme =>
      Theme.of(this).extension<PieThemeExtension>()!.pieTheme;

  /// Palette for auto-assigning colors to chart series (category slices, Sankey
  /// nodes) that lack their own color. The pale [accentColors] read well on
  /// dark surfaces but wash out on light ones, so fall back to the saturated,
  /// contrast-checked [primaryColors] in light mode. Both lists share a length,
  /// so callers can index either with `% length`.
  List<Color> get chartAccents =>
      Theme.of(this).brightness == Brightness.dark
      ? accentColors
      : primaryColors;
}

extension TextStyleHelper on TextStyle {
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle semi(BuildContext context) =>
      copyWith(color: context.flowColors.semi);
}

extension TransactionTypeWidgetData on TransactionType {
  IconData get icon {
    switch (this) {
      case TransactionType.income:
        return Symbols.stat_minus_2_rounded;
      case TransactionType.expense:
        return Symbols.stat_2_rounded;
      case TransactionType.transfer:
        return Symbols.compare_arrows_rounded;
    }
  }

  Color color(BuildContext context) => switch (this) {
    TransactionType.income => context.flowColors.income,
    TransactionType.expense => context.flowColors.expense,
    TransactionType.transfer => context.colorScheme.onSurface,
  };

  Color actionColor(BuildContext context) => switch (this) {
    TransactionType.income => context.colorScheme.onError,
    TransactionType.expense => context.colorScheme.onError,
    TransactionType.transfer => context.colorScheme.onSecondary,
  };

  Color actionBackgroundColor(BuildContext context) => switch (this) {
    TransactionType.income => context.flowColors.income,
    TransactionType.expense => context.flowColors.expense,
    TransactionType.transfer => context.colorScheme.secondary,
  };
}

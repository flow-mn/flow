import "package:flutter/material.dart";

class TransactionListTileTheme extends InheritedTheme {
  final TransactionListTileThemeData data;

  const TransactionListTileTheme({
    super.key,
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    if (oldWidget is! TransactionListTileTheme) return true;

    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return TransactionListTileTheme(data: data, child: child);
  }

  static TransactionListTileTheme? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TransactionListTileTheme>();
  }
}

class TransactionListTileThemeData {
  final EdgeInsetsGeometry? padding;

  final bool? useCategoryNameForUntitledTransactions;
  final bool? useAccountIconForLeading;
  final bool? showExternalSource;
  final bool? showCategory;

  final double? spacing;
  final double? titleSpacing;

  EdgeInsetsGeometry get paddingOrDefault => padding ?? fallback.padding!;

  bool get useCategoryNameForUntitledTransactionsOrDefault =>
      useCategoryNameForUntitledTransactions ??
      fallback.useCategoryNameForUntitledTransactions!;

  bool get useAccountIconForLeadingOrDefault =>
      useAccountIconForLeading ?? fallback.useAccountIconForLeading!;

  bool get showCategoryOrDefault => showCategory ?? fallback.showCategory!;

  bool get showExternalSourceOrDefault =>
      showExternalSource ?? fallback.showExternalSource!;

  double get spacingOrDefault => spacing ?? fallback.spacing!;

  double get titleSpacingOrDefault => titleSpacing ?? fallback.titleSpacing!;

  const TransactionListTileThemeData({
    this.padding,
    this.useCategoryNameForUntitledTransactions,
    this.useAccountIconForLeading,
    this.showExternalSource,
    this.showCategory,
    this.spacing,
    this.titleSpacing,
  });

  static const TransactionListTileThemeData fallback =
      TransactionListTileThemeData(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        useCategoryNameForUntitledTransactions: true,
        useAccountIconForLeading: false,
        showExternalSource: true,
        showCategory: false,
        spacing: 8.0,
        titleSpacing: 0.0,
      );

  TransactionListTileThemeData merge(TransactionListTileThemeData? other) =>
      TransactionListTileThemeData(
        padding: other?.padding ?? padding,
        useCategoryNameForUntitledTransactions:
            other?.useCategoryNameForUntitledTransactions ??
            useCategoryNameForUntitledTransactions,
        useAccountIconForLeading:
            other?.useAccountIconForLeading ?? useAccountIconForLeading,
        showExternalSource: other?.showExternalSource ?? showExternalSource,
        showCategory: other?.showCategory ?? showCategory,
        spacing: other?.spacing ?? spacing,
        titleSpacing: other?.titleSpacing ?? titleSpacing,
      );

  TransactionListTileThemeData copyWith({
    EdgeInsetsGeometry? padding,
    bool? useCategoryNameForUntitledTransactions,
    bool? useAccountIconForLeading,
    bool? showExternalSource,
    bool? showCategory,
    double? spacing,
    double? titleSpacing,
  }) {
    return TransactionListTileThemeData(
      padding: padding ?? this.padding,
      useCategoryNameForUntitledTransactions:
          useCategoryNameForUntitledTransactions ??
          this.useCategoryNameForUntitledTransactions,
      useAccountIconForLeading:
          useAccountIconForLeading ?? this.useAccountIconForLeading,
      showExternalSource: showExternalSource ?? this.showExternalSource,
      showCategory: showCategory ?? this.showCategory,
      spacing: spacing ?? this.spacing,
      titleSpacing: titleSpacing ?? this.titleSpacing,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TransactionListTileThemeData) return false;
    return padding == other.padding &&
        useCategoryNameForUntitledTransactions ==
            other.useCategoryNameForUntitledTransactions &&
        useAccountIconForLeading == other.useAccountIconForLeading &&
        showExternalSource == other.showExternalSource &&
        showCategory == other.showCategory &&
        spacing == other.spacing &&
        titleSpacing == other.titleSpacing;
  }

  @override
  int get hashCode {
    return Object.hash(
      padding,
      useCategoryNameForUntitledTransactions,
      useAccountIconForLeading,
      showExternalSource,
      showCategory,
      spacing,
      titleSpacing,
    );
  }
}

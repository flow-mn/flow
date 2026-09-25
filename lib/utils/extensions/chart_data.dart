import "package:flow/data/chart_data.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

extension ChartDataGroupHelpers on ChartData {
  String resolveName(BuildContext context) => switch (associatedData) {
    Category category => category.name,
    Account account => account.name,
    _ => "category.none".t(context),
  };

  FlowIconData get icon => switch (associatedData) {
    Category category => category.icon,
    Account account => account.icon,
    _ => FlowIconData.icon(Symbols.category_rounded),
  };

  FlowColorScheme? get colorScheme => switch (associatedData) {
    Category category => category.colorScheme,
    Account account => account.colorScheme,
    _ => null,
  };
}

extension ChartDataMapHelpers on Map<String, ChartData> {
  double get displayTotal =>
      values.fold(0.0, (total, chartData) => total + chartData.displayTotal);

  /// Uses each group's own color, falling back to [ThemeAccessor.chartAccents]
  /// in map order, so the list and the chart agree.
  Map<String, Color> resolveColors(BuildContext context) {
    final List<Color> palette = context.chartAccents;
    int fallbackIndex = 0;

    return map(
      (key, chartData) => MapEntry(
        key,
        chartData.colorScheme?.primary ??
            palette[fallbackIndex++ % palette.length],
      ),
    );
  }
}

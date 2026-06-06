import "package:flow/data/chart_data.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class GroupListTile extends StatelessWidget {
  final ChartData chartData;
  final double percent;
  final VoidCallback? onTap;

  const GroupListTile({
    super.key,
    required this.chartData,
    required this.percent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String name = _resolveName(context, chartData.associatedData);
    final FlowIconData iconData = _resolveIcon(chartData.associatedData);
    final FlowColorScheme? colorScheme = _resolveColorScheme(
      chartData.associatedData,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          spacing: 12.0,
          children: [
            FlowIcon(
              iconData,
              plated: true,
              color: colorScheme?.primary,
              plateColor: colorScheme?.secondary,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: .start,
                children: [
                  Text(
                    name,
                    style: context.textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text("${percent.toStringAsFixed(1)}%"),
                ],
              ),
            ),
            MoneyText(
              chartData.money,
              displayAbsoluteAmount: true,
              style: context.textTheme.bodyLarge?.copyWith(
                color: chartData.money.isNegative
                    ? context.flowColors.expense
                    : context.flowColors.income,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _resolveName(BuildContext context, Object? entity) =>
      switch (entity) {
        Category category => category.name,
        Account account => account.name,
        _ => "category.none".t(context),
      };

  static FlowIconData _resolveIcon(Object? entity) => switch (entity) {
    Category category => category.icon,
    Account account => account.icon,
    _ => FlowIconData.icon(Symbols.category_rounded),
  };

  static FlowColorScheme? _resolveColorScheme(Object? entity) =>
      switch (entity) {
        Category category => category.colorScheme,
        Account account => account.colorScheme,
        _ => null,
      };
}

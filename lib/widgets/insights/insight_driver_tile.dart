import "package:flow/data/flow_icon.dart";
import "package:flow/data/insights/insight_engine.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/providers/categories_provider.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/insights/insight_formatter.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// A category that moved a month comparison, opening that category's month.
class InsightDriverTile extends StatelessWidget {
  final InsightCategoryDelta driver;

  /// First day of the analyzed month.
  final DateTime month;

  final InsightFormatter format;

  const InsightDriverTile({
    super.key,
    required this.driver,
    required this.month,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final Category? category = driver.categoryUuid == null
        ? null
        : CategoriesProvider.of(context).get(driver.categoryUuid);
    final String range = Uri.encodeQueryComponent(
      MonthTimeRange.fromDateTime(month).encodeShort(),
    );

    return ListTile(
      leading: FlowIcon(
        category?.icon ?? FlowIconData.icon(Symbols.category_rounded),
        plated: true,
        colorScheme: category?.colorScheme,
      ),
      title: Text(
        category?.name ?? "tabs.stats.analytics.uncategorized".t(context),
      ),
      subtitle: Text(
        (driver.delta >= 0.0
                ? "tabs.stats.worthKnowing.moreThanUsual"
                : "tabs.stats.worthKnowing.lessThanUsual")
            .t(context, {"amount": format.money(driver.delta)}),
      ),
      trailing: Text(
        format.money(driver.current),
        style: context.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: category == null
          ? null
          : () => context.push("/category/${category.id}?range=$range"),
    );
  }
}

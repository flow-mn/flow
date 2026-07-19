import "package:flow/data/flow_icon.dart";
import "package:flow/entity/category.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

/// A compact, wrapping row of category pills for a budget.
///
/// Shows up to [maxVisible] category chips (icon + name); any remainder
/// collapses into a "+N" pill. When [categories] is empty the budget counts
/// all spending, so a single [allSpendingLabel] pill is shown instead.
class BudgetCategoryChips extends StatelessWidget {
  final List<Category> categories;

  /// Label for the "counts everything" pill shown when [categories] is empty.
  final String allSpendingLabel;

  final int maxVisible;

  const BudgetCategoryChips({
    super.key,
    required this.categories,
    required this.allSpendingLabel,
    this.maxVisible = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Wrap(
        children: [
          _Pill(
            icon: FlowIcon(
              FlowIconData.icon(Symbols.all_inclusive_rounded),
              size: 14.0,
            ),
            label: allSpendingLabel,
          ),
        ],
      );
    }

    final List<Category> visible = categories.take(maxVisible).toList();
    final int overflow = categories.length - visible.length;

    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children: [
        for (final Category category in visible)
          _Pill(
            icon: FlowIcon(
              category.icon,
              size: 14.0,
              colorScheme: category.colorScheme,
            ),
            label: category.name,
          ),
        if (overflow > 0) _Pill(label: "+$overflow"),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final Widget? icon;
  final String label;

  const _Pill({this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: icon == null ? 10.0 : 8.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.onSurface.withAlpha(0x14),
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Row(
        mainAxisSize: .min,
        spacing: 4.0,
        children: [
          ?icon,
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurface.withAlpha(0xcc),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

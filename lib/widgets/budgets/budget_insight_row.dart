import "package:flow/data/budget_progress.dart";
import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

/// One rule-based takeaway about a budget, as an icon and a sentence.
///
/// Shared by the budgets overview (where several stack up as
/// "Recommendations") and a single budget's detail page. Keeping the
/// icon/tint/sentence mapping in one place means the overview and the detail
/// page can never disagree about what a budget's situation is called.
class BudgetInsightRow extends StatelessWidget {
  final BudgetProgress progress;

  /// Drops the budget's name from the sentence.
  ///
  /// On a detail page the name is already the page title, so repeating it
  /// reads as a stutter. The overview lists several budgets at once and needs
  /// it.
  final bool omitName;

  const BudgetInsightRow({
    super.key,
    required this.progress,
    this.omitName = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color tint = tintFor(context, progress.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Icon(iconFor(progress.primaryInsight), color: tint, size: 20.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              messageFor(context, progress, omitName: omitName),
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  static Color tintFor(BuildContext context, BudgetStatus status) =>
      switch (status) {
        BudgetStatus.over => context.flowColors.expense,
        // No dedicated warning color in the palette; a softened expense reads
        // as "caution" without introducing a new hue.
        BudgetStatus.warning => context.flowColors.expense.withAlpha(0xb0),
        BudgetStatus.healthy => context.flowColors.semi,
      };

  static IconData iconFor(BudgetInsightType insight) => switch (insight) {
    BudgetInsightType.over => Symbols.error_circle_rounded,
    BudgetInsightType.nearingLimit => Symbols.warning_rounded,
    BudgetInsightType.overpacing => Symbols.speed_rounded,
    BudgetInsightType.onTrack => Symbols.check_circle_rounded,
    BudgetInsightType.underspending => Symbols.savings_rounded,
  };

  static String messageFor(
    BuildContext context,
    BudgetProgress progress, {
    bool omitName = false,
  }) {
    final String suffix = omitName ? ".short" : "";
    final String name = progress.budget.name;

    return switch (progress.primaryInsight) {
      BudgetInsightType.over => "budget.insight.over$suffix".t(context, {
        "amount": progress.overBy.formatted,
        "name": name,
      }),
      BudgetInsightType.nearingLimit => "budget.insight.nearingLimit$suffix".t(
        context,
        {
          "name": name,
          "percent": "${progress.percent}",
          // nearingLimit only fires while the period is still live, so there is
          // always time left; round the trailing partial day up to avoid "0d".
          "days": "${progress.daysLeft < 1 ? 1 : progress.daysLeft}",
        },
      ),
      BudgetInsightType.overpacing =>
        "budget.insight.overpacing$suffix".t(context, {
          "name": name,
          "amount": Money(
            progress.limit.amount * (progress.projectedRatio - 1),
            progress.currency,
          ).formatted,
        }),
      BudgetInsightType.onTrack => "budget.insight.onTrack$suffix".t(context, {
        "name": name,
        "amount": progress.remaining.formatted,
      }),
      BudgetInsightType.underspending =>
        "budget.insight.underspending$suffix".t(context, {
          "name": name,
          "amount": progress.remaining.formatted,
        }),
    };
  }
}

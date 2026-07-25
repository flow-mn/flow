import "package:flow/data/budget_progress.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/budget.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/budget_change_aware_state.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/analytics/bullet_chart.dart";
import "package:flow/widgets/home/stats/bento/bento_tile.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";

/// Bento preview of budgets: a status glance across every budget's current
/// period — all-clear, or the worst offender with how many are over/nearing.
/// Range-independent, since each budget tracks its own period regardless of the
/// Stats range selector.
///
/// Deliberately not a summed spent-vs-limit bar: Flow's budgets are independent
/// and can overlap or span different periods, so a combined total would
/// double-count (see [BudgetsSummary]).
class BudgetTile extends StatefulWidget {
  const BudgetTile({super.key});

  @override
  State<BudgetTile> createState() => _BudgetTileState();
}

class _BudgetTileState extends State<BudgetTile>
    with
        PrimaryCurrencyDependentState<BudgetTile>,
        BudgetChangeAwareState<BudgetTile> {
  bool busy = true;
  bool loaded = false;

  BudgetsSummary? summary;

  @override
  Widget build(BuildContext context) {
    final BudgetsSummary? summary = this.summary;

    return BentoTile(
      label: "tabs.stats.analytics.budgets".t(context),
      icon: Symbols.money_bag_rounded,
      height: 158.0,
      busy: busy && !loaded,
      onTap: () => context.push("/stats/budgets"),
      child: summary == null || summary.isEmpty
          ? Text(
              "tabs.stats.analytics.budgets.empty".t(context),
              style: context.textTheme.bodySmall?.semi(context),
            )
          : summary.allHealthy
          ? _buildHealthy(context, summary)
          : _buildAttention(context, summary),
    );
  }

  Widget _buildHealthy(BuildContext context, BudgetsSummary summary) {
    return Column(
      crossAxisAlignment: .start,
      mainAxisAlignment: .center,
      children: [
        Text(
          "tabs.stats.analytics.budgets.onTrack".t(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.headlineSmall?.copyWith(
            color: context.flowColors.income,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          "tabs.stats.analytics.budgets.tracked".t(
            context,
            summary.budgetCount,
          ),
          style: context.textTheme.bodySmall?.semi(context),
        ),
      ],
    );
  }

  Widget _buildAttention(BuildContext context, BudgetsSummary summary) {
    final BudgetProgress? worst = summary.worst;
    final bool anyOver = summary.overCount > 0;
    final Color tint = anyOver
        ? context.flowColors.expense
        // No dedicated warning hue in the palette; a softened expense reads as
        // "caution" without a new color.
        : context.flowColors.expense.withAlpha(0xb0);

    return Column(
      crossAxisAlignment: .start,
      mainAxisAlignment: .center,
      children: [
        if (worst != null) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  worst.budget.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                "${worst.percent}%",
                style: context.textTheme.labelLarge?.copyWith(
                  color: tint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          BulletChart(
            value: worst.spent.amount,
            target: worst.limit.amount,
            height: 12.0,
          ),
          const SizedBox(height: 8.0),
        ],
        Text(
          anyOver
              ? "tabs.stats.analytics.budgets.overCount".t(
                  context,
                  summary.overCount,
                )
              : "tabs.stats.analytics.budgets.nearingCount".t(
                  context,
                  summary.warningCount,
                ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(color: tint),
        ),
      ],
    );
  }

  @override
  Future<void> fetch() async {
    try {
      final List<BudgetProgress> progresses =
          (await BudgetService().computeAllProgressAsync(
            rates: rates,
          )).where((progress) => progress.isCurrent).toList();
      summary = BudgetService().computeSummary(progresses);
      loaded = true;
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }
}

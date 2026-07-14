import "package:flow/data/budget_progress.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/budget.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/budgets/budget_card.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/empty_state.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flow/widgets/stats/stats_app_bar.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";

/// Budgets overview.
///
/// Shows a status roll-up across every current budget — how many are over or
/// nearing their limit, and which one is worst — rather than a summed money
/// total: Flow's budgets are independent and can overlap or span different
/// periods, so a combined spent-vs-limit total would mislead (see
/// [BudgetsSummary]). Surfaces rule-based recommendations for the budgets most
/// in need of attention, and lists each budget's live [BudgetCard]. Budgets
/// track their own periods, so unlike most stats pages there is no time-range
/// selector.
class BudgetsOverviewPage extends StatefulWidget {
  const BudgetsOverviewPage({super.key});

  @override
  State<BudgetsOverviewPage> createState() => _BudgetsOverviewPageState();
}

class _BudgetsOverviewPageState extends State<BudgetsOverviewPage>
    with PrimaryCurrencyDependentState<BudgetsOverviewPage> {
  /// How many budgets get a recommendation row; progresses arrive sorted
  /// most-urgent first, so the cut keeps the ones that matter.
  static const int _maxRecommendations = 4;

  bool busy = false;

  List<BudgetProgress> progresses = [];
  BudgetsSummary? summary;

  @override
  Widget build(BuildContext context) {
    final BudgetsSummary? summary = this.summary;

    // Only budgets whose period includes now are relevant to a "this period"
    // overview — a stale past-period budget (custom range, or a non-renewing
    // one whose period ended) must not count toward the summary, drive
    // recommendations, or appear as a live card. Its spend is historical.
    final List<BudgetProgress> current = progresses
        .where((progress) => progress.isCurrent)
        .toList();

    // Only budgets that actually warrant a nudge get a recommendation row —
    // over/nearing (needsAttention) or projected to overshoot (overpacing).
    // Healthy budgets stay quiet; the summary banner speaks for them.
    final List<BudgetProgress> actionable = current
        .where(
          (progress) =>
              progress.needsAttention ||
              progress.primaryInsight == BudgetInsightType.overpacing,
        )
        .toList();

    return Scaffold(
      appBar: StatsAppBar(title: "budget.overview.title".t(context)),
      body: SafeArea(
        child: busy && summary == null
            ? const Spinner.center()
            : summary == null || summary.isEmpty
            ? _buildEmptyState(context)
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    const SizedBox(height: 16.0),
                    ListHeader("budget.overview.summary".t(context)),
                    const SizedBox(height: 2.0),
                    _buildSummaryCard(
                      context,
                      summary,
                      hasHeadsUp: actionable.isNotEmpty,
                    ),
                    if (actionable.isNotEmpty) ...[
                      const SizedBox(height: 24.0),
                      ListHeader(
                        "budget.overview.recommendations".t(context),
                      ),
                      const SizedBox(height: 8.0),
                      ..._buildRecommendations(context, actionable),
                    ],
                    const SizedBox(height: 24.0),
                    ListHeader("budget.overview.perBudget".t(context)),
                    const SizedBox(height: 2.0),
                    ...current.map(
                      (progress) => BudgetCard(budget: progress.budget),
                    ),
                    const SizedBox(height: 96.0),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: EmptyState(
          icon: FlowIconData.icon(Symbols.money_bag_rounded),
          title: Text("budget.overview.empty".t(context)),
          subtitle: Text("budget.overview.empty.description".t(context)),
          trailing: Button(
            onTap: () => context.push("/budgets/new"),
            leading: const Icon(Symbols.add_rounded),
            child: Text("budget.overview.create".t(context)),
          ),
        ),
      ),
    );
  }

  /// A status banner, not a money roll-up: Flow's budgets are independent and
  /// can overlap or span different periods, so a summed spent-vs-limit total
  /// would double-count. This answers the only question the screen exists for
  /// — is anything in trouble? — with honest counts.
  Widget _buildSummaryCard(
    BuildContext context,
    BudgetsSummary summary, {
    required bool hasHeadsUp,
  }) {
    return Surface(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: summary.allHealthy
            ? _buildHealthySummary(context, summary, hasHeadsUp: hasHeadsUp)
            : _buildAttentionSummary(context, summary),
      ),
    );
  }

  Widget _buildHealthySummary(
    BuildContext context,
    BudgetsSummary summary, {
    required bool hasHeadsUp,
  }) {
    return Row(
      children: [
        Icon(
          Symbols.check_circle_rounded,
          color: context.flowColors.income,
          size: 28.0,
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                // Nothing is over or nearing a limit. If a healthy budget is
                // still pacing hot, a heads-up recommendation shows below, so
                // stay factual here rather than congratulatory.
                (hasHeadsUp
                        ? "budget.overview.nothingOver"
                        : "budget.overview.allHealthy")
                    .t(context),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                "budget.overview.budgetsTracked".t(
                  context,
                  summary.budgetCount,
                ),
                style: context.textTheme.bodySmall?.semi(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttentionSummary(BuildContext context, BudgetsSummary summary) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        if (summary.overCount > 0)
          _buildCountLine(
            context,
            icon: Symbols.error_circle_rounded,
            tint: context.flowColors.expense,
            text: "budget.overview.overLimit".t(context, summary.overCount),
          ),
        if (summary.warningCount > 0) ...[
          if (summary.overCount > 0) const SizedBox(height: 10.0),
          _buildCountLine(
            context,
            icon: Symbols.warning_rounded,
            // No dedicated warning hue in the palette; a softened expense reads
            // as "caution" without introducing a new color.
            tint: context.flowColors.expense.withAlpha(0xb0),
            text: "budget.overview.nearingLimit".t(
              context,
              summary.warningCount,
            ),
          ),
        ],
        const SizedBox(height: 12.0),
        Text(
          "budget.overview.budgetsTracked".t(context, summary.budgetCount),
          style: context.textTheme.bodySmall?.semi(context),
        ),
        if (summary.hasMissingData) ...[
          const SizedBox(height: 8.0),
          Text(
            "budget.overview.missingRates".t(context),
            style: context.textTheme.bodySmall?.semi(context),
          ),
        ],
      ],
    );
  }

  Widget _buildCountLine(
    BuildContext context, {
    required IconData icon,
    required Color tint,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: tint, size: 22.0),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.titleSmall?.copyWith(
              color: tint,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// [actionable] is already filtered to budgets that warrant a nudge and
  /// sorted most-urgent first, so this just caps and renders it.
  List<Widget> _buildRecommendations(
    BuildContext context,
    List<BudgetProgress> actionable,
  ) {
    return actionable
        .take(_maxRecommendations)
        .map(
          (progress) => _buildRecommendationRow(
            context,
            icon: _insightIcon(progress.primaryInsight),
            tint: _statusTint(context, progress.status),
            message: _insightMessage(context, progress),
          ),
        )
        .toList();
  }

  Widget _buildRecommendationRow(
    BuildContext context, {
    required IconData icon,
    required Color tint,
    required String message,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Icon(icon, color: tint, size: 20.0),
          const SizedBox(width: 12.0),
          Expanded(child: Text(message, style: context.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Color _statusTint(BuildContext context, BudgetStatus status) =>
      switch (status) {
        BudgetStatus.over => context.flowColors.expense,
        // No dedicated warning color in the palette; a softened expense reads
        // as "caution" without introducing a new hue.
        BudgetStatus.warning => context.flowColors.expense.withAlpha(0xb0),
        BudgetStatus.healthy => context.flowColors.semi,
      };

  IconData _insightIcon(BudgetInsightType insight) => switch (insight) {
    BudgetInsightType.over => Symbols.error_circle_rounded,
    BudgetInsightType.nearingLimit => Symbols.warning_rounded,
    BudgetInsightType.overpacing => Symbols.speed_rounded,
    BudgetInsightType.onTrack => Symbols.check_circle_rounded,
    BudgetInsightType.underspending => Symbols.savings_rounded,
  };

  String _insightMessage(BuildContext context, BudgetProgress progress) {
    return switch (progress.primaryInsight) {
      BudgetInsightType.over => "budget.insight.over".t(context, {
        "amount": progress.overBy.formatted,
        "name": progress.budget.name,
      }),
      BudgetInsightType.nearingLimit =>
        "budget.insight.nearingLimit".t(context, {
          "name": progress.budget.name,
          "percent": "${progress.percent}",
          // nearingLimit only fires while the period is still live, so there is
          // always time left; round the trailing partial day up to avoid "0d".
          "days": "${progress.daysLeft < 1 ? 1 : progress.daysLeft}",
        }),
      BudgetInsightType.overpacing => "budget.insight.overpacing".t(context, {
        "name": progress.budget.name,
        "amount": Money(
          progress.limit.amount * (progress.projectedRatio - 1),
          progress.currency,
        ).formatted,
      }),
      BudgetInsightType.onTrack => "budget.insight.onTrack".t(context, {
        "name": progress.budget.name,
        "amount": progress.remaining.formatted,
      }),
      BudgetInsightType.underspending => "budget.insight.underspending".t(
        context,
        {"name": progress.budget.name, "amount": progress.remaining.formatted},
      ),
    };
  }

  @override
  Future<void> fetch() async {
    if (!mounted) return;
    setState(() {
      busy = true;
    });

    try {
      // The app may have crossed a period boundary since startup; advance
      // auto-renewing budgets to their current period before computing.
      await BudgetService().renewDueBudgets();

      progresses = BudgetService().computeAllProgress(rates: rates);
      summary = BudgetService().computeSummary(
        progresses.where((progress) => progress.isCurrent).toList(),
      );
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }
}

import "package:flow/data/budget_progress.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

/// A budget's recent periods as a row of bars, oldest to newest.
///
/// Only possible because renewal is derived rather than written: a budget's
/// anchor still points at its whole series, so any past period can be measured
/// from transactions that were never touched. Before that, a rolled-over period
/// was simply gone.
///
/// Bars are scaled against the limit, not against each other, so the limit line
/// sits at a constant height and an overrun is visible as a bar crossing it.
class BudgetHistoryStrip extends StatelessWidget {
  /// Oldest first; the last entry is the live period.
  final List<BudgetProgress> history;

  final double height;

  const BudgetHistoryStrip({
    super.key,
    required this.history,
    this.height = 72.0,
  });

  @override
  Widget build(BuildContext context) {
    // A single period is just the current one restated — the strip would imply
    // a trend that isn't there.
    if (history.length < 2) return const SizedBox.shrink();

    // Headroom above the limit line so an overrun has somewhere to go, and so
    // a wildly-over period doesn't squash every other bar to nothing.
    final double ceiling = history
        .map((progress) => progress.ratio)
        .fold(1.25, (a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: .end,
        children: [
          for (final BudgetProgress progress in history)
            Expanded(
              child: _Bar(
                progress: progress,
                ceiling: ceiling,
                isCurrent: progress == history.last,
              ),
            ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final BudgetProgress progress;
  final double ceiling;
  final bool isCurrent;

  const _Bar({
    required this.progress,
    required this.ceiling,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final Color tint = switch (progress.status) {
      BudgetStatus.over => context.flowColors.expense,
      BudgetStatus.warning => context.flowColors.expense.withAlpha(0xb0),
      BudgetStatus.healthy => context.flowColors.income,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: Column(
        mainAxisAlignment: .end,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double fraction = (progress.ratio / ceiling).clamp(
                  0.0,
                  1.0,
                );

                return Stack(
                  alignment: .bottomCenter,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: context.colorScheme.onSurface.withAlpha(0x14),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                    ),
                    // The limit line, at a constant height across every bar —
                    // that's what makes "crossed it" readable at a glance.
                    Positioned(
                      bottom: constraints.maxHeight * (1 / ceiling),
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        height: 1.0,
                        color: context.colorScheme.onSurface.withAlpha(0x40),
                      ),
                    ),
                    Container(
                      height: constraints.maxHeight * fraction,
                      decoration: BoxDecoration(
                        color: tint.withAlpha(isCurrent ? 0xff : 0xa0),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            _label(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurface.withAlpha(
                isCurrent ? 0xdd : 0x99,
              ),
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  String _label() => switch (progress.range) {
    MonthTimeRange month => month.from.format(payload: "MMM"),
    YearTimeRange year => year.year.toString(),
    _ => progress.range.from.format(payload: "D/M"),
  };
}

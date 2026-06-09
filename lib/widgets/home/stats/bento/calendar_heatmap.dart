import "package:flutter/material.dart";

/// A compact GitHub-style heatmap of daily spend for the bento calendar tile.
///
/// Renders [weeks] columns of 7 day-cells starting at [gridStart]; each cell's
/// opacity scales with that day's spend relative to [maxDaily]. Future days
/// are left transparent.
class CalendarHeatmap extends StatelessWidget {
  final DateTime gridStart;
  final int weeks;
  final Map<DateTime, double> dailyExpense;
  final double maxDaily;
  final Color filled;
  final Color empty;

  const CalendarHeatmap({
    super.key,
    required this.gridStart,
    required this.weeks,
    required this.dailyExpense,
    required this.maxDaily,
    required this.filled,
    required this.empty,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    const double cell = 11.0;
    const double gap = 2.5;

    return Row(
      mainAxisSize: .min,
      children: List.generate(weeks, (week) {
        return Padding(
          padding: const EdgeInsets.only(right: gap),
          child: Column(
            mainAxisSize: .min,
            children: List.generate(7, (weekday) {
              final DateTime day = gridStart.add(
                Duration(days: week * 7 + weekday),
              );
              final bool future = day.isAfter(now);
              final double amount = dailyExpense[day] ?? 0.0;
              final double factor = maxDaily <= 0
                  ? 0.0
                  : (amount / maxDaily).clamp(0.0, 1.0);

              final Color color = future
                  ? Colors.transparent
                  : amount <= 0
                  ? empty
                  : Color.alphaBlend(
                      filled.withAlpha((factor * 0xff).round()),
                      empty,
                    );

              return Padding(
                padding: const EdgeInsets.only(bottom: gap),
                child: Container(
                  width: cell,
                  height: cell,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: .all(Radius.circular(2.5)),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

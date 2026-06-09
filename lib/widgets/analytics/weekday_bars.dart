import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

/// A small 7-bar weekday spend strip (Mon .. Sun), highlighting [topWeekday].
///
/// Shared by the analytics-lab pages that surface a weekday rhythm. Expects
/// [byWeekday] keyed by `DateTime.weekday` (1 = Monday .. 7 = Sunday).
class WeekdayBars extends StatelessWidget {
  final Map<int, double> byWeekday;
  final int topWeekday;
  final Color accent;

  const WeekdayBars({
    super.key,
    required this.byWeekday,
    required this.topWeekday,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final double max = byWeekday.values.isEmpty
        ? 0.0
        : byWeekday.values.reduce((a, b) => a > b ? a : b);
    final Color base = context.colorScheme.onSurface.withAlpha(0x33);

    const List<String> labels = ["M", "T", "W", "T", "F", "S", "S"];

    return SizedBox(
      height: 56.0,
      child: Row(
        crossAxisAlignment: .end,
        children: List.generate(7, (index) {
          final int weekday = index + 1;
          final double value = byWeekday[weekday] ?? 0.0;
          final double factor = max <= 0 ? 0.0 : value / max;
          final bool isTop = weekday == topWeekday;

          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: FractionallySizedBox(
                        heightFactor: factor.clamp(0.04, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isTop ? accent : base,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  labels[index],
                  style: context.textTheme.labelSmall?.copyWith(
                    color: isTop
                        ? accent
                        : context.colorScheme.onSecondary.withAlpha(0x80),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

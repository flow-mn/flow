import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

/// A GitHub-style calendar heatmap of daily spend intensity.
///
/// Buckets non-zero days into quartiles so one outlier day doesn't wash out
/// the rest. Every cell carries a [Semantics] label and a [Tooltip] so the
/// value is reachable without relying on color alone.
class SpendingHeatmap extends StatelessWidget {
  /// Date (at day resolution) -> summed expense magnitude in [currency].
  final Map<DateTime, double> dailyExpense;

  final DateTime from;
  final DateTime to;
  final String currency;

  final double cellSize;
  final double gap;

  const SpendingHeatmap({
    super.key,
    required this.dailyExpense,
    required this.from,
    required this.to,
    required this.currency,
    this.cellSize = 15.0,
    this.gap = 4.0,
  });

  /// Fixed height reserved for the month-label row, shared between the grid
  /// and the weekday rail so the two stay vertically aligned regardless of
  /// font metrics or text scaling.
  static const double _headerHeight = 16.0;
  static const double _headerGap = 2.0;

  @override
  Widget build(BuildContext context) {
    final List<double> sorted =
        dailyExpense.values.where((value) => value > 0).toList()..sort();

    final List<DateTime> weeks = _weekStarts();
    final double columnWidth = cellSize + gap;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          crossAxisAlignment: .start,
          children: [
            _WeekdayLabels(
              cellSize: cellSize,
              gap: gap,
              topOffset: _headerHeight + _headerGap,
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    SizedBox(
                      height: _headerHeight,
                      child: _MonthLabels(
                        weeks: weeks,
                        columnWidth: columnWidth,
                      ),
                    ),
                    const SizedBox(height: _headerGap),
                    Row(
                      children: weeks
                          .map(
                            (monday) => Padding(
                              padding: EdgeInsets.only(right: gap),
                              child: _WeekColumn(
                                monday: monday,
                                dailyExpense: dailyExpense,
                                thresholds: sorted,
                                from: from,
                                to: to,
                                currency: currency,
                                cellSize: cellSize,
                                gap: gap,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        _Legend(),
      ],
    );
  }

  List<DateTime> _weekStarts() {
    final List<DateTime> weeks = [];
    DateTime cursor = _mondayOf(from);
    final DateTime last = _mondayOf(to);
    while (!cursor.isAfter(last)) {
      weeks.add(cursor);
      cursor = cursor.add(const Duration(days: 7));
    }
    return weeks;
  }
}

DateTime _mondayOf(DateTime date) {
  final DateTime day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

/// Quartile bucket (0 == none, 1..4 increasing) for [value].
int _levelFor(double value, List<double> sortedNonZero) {
  if (value <= 0 || sortedNonZero.isEmpty) return 0;

  double quantile(double p) {
    final int index = (p * (sortedNonZero.length - 1)).floor();
    return sortedNonZero[index];
  }

  if (value <= quantile(0.25)) return 1;
  if (value <= quantile(0.5)) return 2;
  if (value <= quantile(0.75)) return 3;
  return 4;
}

Color _levelColor(BuildContext context, int level) {
  final Color primary = context.colorScheme.primary;
  return switch (level) {
    0 => context.colorScheme.onSurface.withAlpha(0x14),
    1 => primary.withAlpha(0x45),
    2 => primary.withAlpha(0x80),
    3 => primary.withAlpha(0xc0),
    _ => primary,
  };
}

class _WeekColumn extends StatelessWidget {
  final DateTime monday;
  final Map<DateTime, double> dailyExpense;
  final List<double> thresholds;
  final DateTime from;
  final DateTime to;
  final String currency;
  final double cellSize;
  final double gap;

  const _WeekColumn({
    required this.monday,
    required this.dailyExpense,
    required this.thresholds,
    required this.from,
    required this.to,
    required this.currency,
    required this.cellSize,
    required this.gap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(7, (index) {
        final DateTime day = monday.add(Duration(days: index));
        final bool outOfRange = day.isBefore(_dayOnly(from)) || day.isAfter(to);

        if (outOfRange) {
          return Padding(
            padding: EdgeInsets.only(bottom: gap),
            child: SizedBox.square(dimension: cellSize),
          );
        }

        final double value = dailyExpense[_dayOnly(day)] ?? 0.0;
        final int level = _levelFor(value, thresholds);
        final String label =
            "${day.toMoment().format("dddd, MMM D")}: "
            "${Money(value, currency).formatted}";

        return Padding(
          padding: EdgeInsets.only(bottom: gap),
          child: Tooltip(
            message: label,
            child: Semantics(
              label: label,
              button: false,
              child: Container(
                width: cellSize,
                height: cellSize,
                decoration: BoxDecoration(
                  color: _levelColor(context, level),
                  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  DateTime _dayOnly(DateTime date) => DateTime(date.year, date.month, date.day);
}

class _WeekdayLabels extends StatelessWidget {
  final double cellSize;
  final double gap;
  final double topOffset;

  const _WeekdayLabels({
    required this.cellSize,
    required this.gap,
    required this.topOffset,
  });

  @override
  Widget build(BuildContext context) {
    // Only label Mon / Wed / Fri to keep the rail uncluttered.
    const Map<int, String> labels = {0: "M", 2: "W", 4: "F"};
    final TextStyle? style = context.textTheme.labelSmall?.semi(context);

    return Padding(
      padding: EdgeInsets.only(right: gap, top: topOffset),
      child: Column(
        children: List.generate(7, (index) {
          return Container(
            height: cellSize,
            margin: EdgeInsets.only(bottom: gap),
            alignment: Alignment.centerRight,
            child: Text(labels[index] ?? "", style: style),
          );
        }),
      ),
    );
  }
}

class _MonthLabels extends StatelessWidget {
  final List<DateTime> weeks;
  final double columnWidth;

  const _MonthLabels({required this.weeks, required this.columnWidth});

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = context.textTheme.labelSmall?.semi(context);

    return Row(
      children: weeks.asMap().entries.map((entry) {
        final int index = entry.key;
        final DateTime monday = entry.value;
        final bool newMonth =
            index == 0 || weeks[index - 1].month != monday.month;

        return SizedBox(
          width: columnWidth,
          child: newMonth
              ? Text(monday.toMoment().format("MMM"), style: style)
              : const SizedBox.shrink(),
        );
      }).toList(),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .end,
      children: [
        Text(
          "tabs.stats.analytics.heatmap.less".t(context),
          style: context.textTheme.labelSmall?.semi(context),
        ),
        const SizedBox(width: 6.0),
        ...List.generate(5, (level) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Container(
              width: 12.0,
              height: 12.0,
              decoration: BoxDecoration(
                color: _levelColor(context, level),
                borderRadius: const BorderRadius.all(Radius.circular(3.0)),
              ),
            ),
          );
        }),
        const SizedBox(width: 6.0),
        Text(
          "tabs.stats.analytics.heatmap.more".t(context),
          style: context.textTheme.labelSmall?.semi(context),
        ),
      ],
    );
  }
}

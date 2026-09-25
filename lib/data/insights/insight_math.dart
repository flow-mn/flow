import "dart:math" as math;

/// Months since year 0, so month arithmetic never touches [Duration]s.
int monthIndexOf(DateTime date) => date.year * 12 + date.month - 1;

DateTime monthStartOf(int monthIndex) =>
    DateTime(monthIndex ~/ 12, monthIndex % 12 + 1);

int daysInMonth(int monthIndex) =>
    DateTime.utc(monthIndex ~/ 12, monthIndex % 12 + 2, 0).day;

/// Calendar days from [from] to [to], ignoring time of day and DST.
int dayDifference(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// The charge day for [anchorDay] in a month, clamped for short months.
DateTime chargeDayOf(int monthIndex, int anchorDay) => DateTime(
  monthIndex ~/ 12,
  monthIndex % 12 + 1,
  math.min(anchorDay, daysInMonth(monthIndex)),
);

/// The month whose charge on [anchorDay] is nearest to [date], and the signed
/// distance in days (positive when [date] is late).
({int slot, int offset}) nearestSlot(DateTime date, int anchorDay) {
  final int index = monthIndexOf(date);

  ({int slot, int offset})? best;

  for (int slot = index - 1; slot <= index + 1; slot++) {
    final int offset = dayDifference(chargeDayOf(slot, anchorDay), date);
    if (best == null || offset.abs() < best.offset.abs()) {
      best = (slot: slot, offset: offset);
    }
  }

  return best!;
}

/// Returns 0.0 for an empty list.
double median(Iterable<double> values) {
  final List<double> sorted = values.toList()..sort();

  if (sorted.isEmpty) return 0.0;

  final int middle = sorted.length ~/ 2;

  if (sorted.length.isOdd) return sorted[middle];

  return (sorted[middle - 1] + sorted[middle]) / 2;
}

double mean(Iterable<double> values) {
  if (values.isEmpty) return 0.0;

  return values.fold<double>(0.0, (a, b) => a + b) / values.length;
}

/// Standard deviation over mean. 0.0 for fewer than two values or a zero mean.
double coefficientOfVariation(List<double> values) {
  if (values.length < 2) return 0.0;

  final double average = mean(values);
  if (average == 0.0) return 0.0;

  final double variance = mean(
    values.map((value) => (value - average) * (value - average)),
  );

  return math.sqrt(variance) / average.abs();
}

final RegExp _separators = RegExp(r"[^\p{L}\p{N}]+", unicode: true);
final RegExp _digit = RegExp(r"\d");

/// Lowercased title without punctuation and without tokens that contain
/// digits (reference numbers, dates), so "NETFLIX #1234" and "Netflix" group
/// together. Null when nothing is left.
String? normalizeTitle(String? title) {
  if (title == null) return null;

  final String normalized = title
      .toLowerCase()
      .split(_separators)
      .where((token) => token.isNotEmpty && !token.contains(_digit))
      .join(" ");

  return normalized.isEmpty ? null : normalized;
}

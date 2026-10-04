import "package:flow/data/insights/recurring_series.dart";

export "package:flow/data/insights/recurring_series.dart";

/// One per "don't show this kind" switch.
enum InsightType {
  monthPace,
  categorySpike,
  categoryDrop,
  newCategory,
  recurringCharge,
  priceChange,
}

enum InsightDirection { above, below }

/// A month's value in an evidence chart.
class InsightMonthValue {
  /// First day of the month.
  final DateTime month;

  final double amount;

  /// False for months skipped as logging gaps (too few entries).
  final bool counted;

  const InsightMonthValue({
    required this.month,
    required this.amount,
    required this.counted,
  });
}

/// The single transaction that explains most of a change.
class InsightAttribution {
  final String transactionUuid;
  final String? title;
  final String? categoryUuid;
  final DateTime date;

  /// Absolute amount, in the primary currency.
  final double amount;

  const InsightAttribution({
    required this.transactionUuid,
    required this.title,
    required this.categoryUuid,
    required this.date,
    required this.amount,
  });
}

/// How much one category moved a month comparison.
class InsightCategoryDelta {
  /// Null for uncategorized.
  final String? categoryUuid;
  final double current;
  final double usual;

  const InsightCategoryDelta({
    required this.categoryUuid,
    required this.current,
    required this.usual,
  });

  double get delta => current - usual;
}

/// All amounts are absolute, in the primary currency.
sealed class Insight {
  /// Money at stake relative to the usual month, used for ranking.
  final double score;

  const Insight({required this.score});

  InsightType get type;

  /// What this insight is about, within its [type].
  String get subject;

  /// Stable identity for cooldowns and dismissals.
  String get key => "${type.name}:$subject";

  /// Money at stake. Never negative.
  double get stake;

  /// The transactions behind the insight, most relevant first.
  List<String> get transactionUuids;
}

/// The month as a whole is running above or below the usual. For an
/// in-progress month, both sides are measured through [throughDay].
final class MonthPaceInsight extends Insight {
  final InsightDirection direction;
  final double current;
  final double usual;

  /// Null for a complete month.
  final int? throughDay;

  /// Baseline months, oldest first, measured the same way as [current].
  final List<InsightMonthValue> history;

  /// Only for [InsightDirection.above].
  final InsightAttribution? attribution;

  /// Categories that moved in [direction], biggest first.
  final List<InsightCategoryDelta> drivers;

  @override
  final List<String> transactionUuids;

  const MonthPaceInsight({
    required super.score,
    required this.direction,
    required this.current,
    required this.usual,
    required this.throughDay,
    required this.history,
    required this.attribution,
    required this.drivers,
    required this.transactionUuids,
  });

  @override
  InsightType get type => .monthPace;

  @override
  String get subject => direction.name;

  @override
  double get stake => (current - usual).abs();

  /// e.g. 1.27 for "27% above".
  double get ratio => current / usual;

  /// [current] without [attribution], if any.
  double? get currentWithoutAttribution =>
      attribution == null ? null : current - attribution!.amount;

  double? get ratioWithoutAttribution =>
      attribution == null ? null : currentWithoutAttribution! / usual;

  /// The first driver when it explains at least half of the change.
  InsightCategoryDelta? get dominantDriver {
    final InsightCategoryDelta? first = drivers.firstOrNull;
    if (first == null) return null;

    return first.delta.abs() * 2 >= stake ? first : null;
  }
}

/// A category is well above its usual month. [current] may be a month in
/// progress; [usual] is always a complete month.
final class CategorySpikeInsight extends Insight {
  final String categoryUuid;
  final double current;
  final double usual;
  final int entryCount;

  /// Complete baseline months, oldest first.
  final List<InsightMonthValue> history;

  final InsightAttribution? attribution;

  @override
  final List<String> transactionUuids;

  const CategorySpikeInsight({
    required super.score,
    required this.categoryUuid,
    required this.current,
    required this.usual,
    required this.entryCount,
    required this.history,
    required this.attribution,
    required this.transactionUuids,
  });

  @override
  InsightType get type => .categorySpike;

  @override
  String get subject => categoryUuid;

  @override
  double get stake => current - usual;

  double get ratio => current / usual;
}

/// A regular category is well below its usual. For an in-progress month,
/// both sides are measured through [throughDay].
final class CategoryDropInsight extends Insight {
  final String categoryUuid;
  final double current;
  final double usual;
  final int? throughDay;
  final List<InsightMonthValue> history;

  @override
  final List<String> transactionUuids;

  const CategoryDropInsight({
    required super.score,
    required this.categoryUuid,
    required this.current,
    required this.usual,
    required this.throughDay,
    required this.history,
    required this.transactionUuids,
  });

  @override
  InsightType get type => .categoryDrop;

  @override
  String get subject => categoryUuid;

  @override
  double get stake => usual - current;

  double get ratio => current / usual;
}

/// Spend in a category that had none in the baseline months.
final class NewCategoryInsight extends Insight {
  final String categoryUuid;
  final double current;
  final int entryCount;

  @override
  final List<String> transactionUuids;

  const NewCategoryInsight({
    required super.score,
    required this.categoryUuid,
    required this.current,
    required this.entryCount,
    required this.transactionUuids,
  });

  @override
  InsightType get type => .newCategory;

  @override
  String get subject => categoryUuid;

  @override
  double get stake => current;
}

/// A charge that repeats but isn't tracked as recurring in Flow yet.
final class RecurringChargeInsight extends Insight {
  final RecurringSeries series;

  const RecurringChargeInsight({required super.score, required this.series});

  @override
  InsightType get type => .recurringCharge;

  @override
  String get subject => series.key;

  @override
  double get stake => series.annualCost;

  @override
  List<String> get transactionUuids => series.occurrences.reversed
      .map((occurrence) => occurrence.transactionUuid)
      .toList();
}

/// The latest charge of a recurring series changed price.
final class PriceChangeInsight extends Insight {
  final RecurringSeries series;
  final double previousAmount;
  final double currentAmount;

  const PriceChangeInsight({
    required super.score,
    required this.series,
    required this.previousAmount,
    required this.currentAmount,
  });

  @override
  InsightType get type => .priceChange;

  @override
  String get subject => series.key;

  /// Yearly difference.
  @override
  double get stake =>
      (currentAmount - previousAmount).abs() * series.cadence.perYear;

  double get ratio => currentAmount / previousAmount;

  DateTime get changedOn => series.occurrences.last.date;

  @override
  List<String> get transactionUuids => series.occurrences.reversed
      .map((occurrence) => occurrence.transactionUuid)
      .toList();
}

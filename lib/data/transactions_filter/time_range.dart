import "package:flow/prefs/custom_cycles.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/utils/time_and_range.dart";
import "package:moment_dart/moment_dart.dart";

enum TransactionFilterTimeRangePreset with LocalizedEnum {
  last30Days("last30Days"),
  thisWeek("thisWeek"),
  thisMonth("thisMonth"),
  thisYear("thisYear"),
  currentCycle("currentCycle"),
  allTime("allTime");

  final String value;

  const TransactionFilterTimeRangePreset(this.value);

  @override
  String get localizationEnumName => "TransactionFilterRangePreset";

  @override
  String get localizationEnumValue => value;
}

class TransactionFilterTimeRange {
  static const String _monthCyclePrefix = "cycle:month:";
  static const String _customCyclePrefix = "cycle:custom:";

  final String value;

  const TransactionFilterTimeRange(this.value);
  factory TransactionFilterTimeRange._fromPreset(
    TransactionFilterTimeRangePreset preset,
  ) => TransactionFilterTimeRange(preset.value);

  factory TransactionFilterTimeRange.fromTimeRange(TimeRange range) =>
      TransactionFilterTimeRange(range.encodeShort());

  static TransactionFilterTimeRange customCycle(String cycleId) =>
      TransactionFilterTimeRange("$_customCyclePrefix$cycleId:current");

  static TransactionFilterTimeRange customCycleForMonth(
    String cycleId,
    DateTime month,
  ) {
    final CustomCycle? cycle = CustomCyclePreferences().cycleById(cycleId);
    if (cycle == null) {
      return TransactionFilterTimeRange.currentCycle();
    }

    final TimeRange range = resolveCustomCycleMonth(
      month: DateTime(month.year, month.month, 1),
      cycle: cycle,
    );

    return TransactionFilterTimeRange.fromTimeRange(range);
  }

  static CustomTimeRange resolveCustomCycleMonth({
    required DateTime month,
    required CustomCycle cycle,
  }) {
    final int startDay = cycle.startDay;
    final int endDay = cycle.endDay;

    final DateTime cycleStartMonth = startDay > endDay
        ? DateTime(month.year, month.month - 1, 1)
        : DateTime(month.year, month.month, 1);
    final DateTime cycleEndMonth = DateTime(month.year, month.month, 1);

    final DateTime cycleStart = _boundedDay(cycleStartMonth, startDay);
    final DateTime cycleEnd = _boundedDay(cycleEndMonth, endDay);

    return CustomTimeRange(cycleStart.startOfDay(), cycleEnd.endOfDay());
  }

  static TransactionFilterTimeRange last30Days =
      TransactionFilterTimeRange._fromPreset(
        TransactionFilterTimeRangePreset.last30Days,
      );
  static TransactionFilterTimeRange thisWeek =
      TransactionFilterTimeRange._fromPreset(
        TransactionFilterTimeRangePreset.thisWeek,
      );
  static TransactionFilterTimeRange thisMonth =
      TransactionFilterTimeRange._fromPreset(
        TransactionFilterTimeRangePreset.thisMonth,
      );
  static TransactionFilterTimeRange thisYear =
      TransactionFilterTimeRange._fromPreset(
        TransactionFilterTimeRangePreset.thisYear,
      );
  static TransactionFilterTimeRange allTime =
      TransactionFilterTimeRange._fromPreset(
        TransactionFilterTimeRangePreset.allTime,
      );

  static TransactionFilterTimeRange currentCycle({
    int startDay = 21,
    int endDay = 20,
  }) => TransactionFilterTimeRange(
    "$_monthCyclePrefix$startDay:$endDay:current",
  );

  TimeRange? get range {
    if (TransactionFilterTimeRangePreset.last30Days.value == value) {
      return last30DaysRange();
    }
    if (TransactionFilterTimeRangePreset.thisWeek.value == value) {
      return TimeRange.thisLocalWeek();
    }
    if (TransactionFilterTimeRangePreset.thisMonth.value == value) {
      return TimeRange.thisMonth();
    }
    if (TransactionFilterTimeRangePreset.thisYear.value == value) {
      return TimeRange.thisYear();
    }
    if (TransactionFilterTimeRangePreset.allTime.value == value) {
      return Moment.minValue.rangeToMax();
    }
    if (value.startsWith(_monthCyclePrefix)) {
      return resolveMonthCycle(anchor: DateTime.now(), value: value);
    }
    if (value.startsWith(_customCyclePrefix)) {
      return resolveCustomCycle(anchor: DateTime.now(), value: value);
    }

    return TimeRange.tryParse(value);
  }

  static TimeRange resolveCustomCycle({
    required DateTime anchor,
    required String value,
  }) {
    final List<String> parts = value.split(":");
    if (parts.length < 4) {
      return TimeRange.thisMonth();
    }

    final String cycleId = parts[2];
    final String mode = parts[3];
    final CustomCycle? cycle = CustomCyclePreferences().cycleById(cycleId);

    if (cycle == null) {
      return TimeRange.thisMonth();
    }

    switch (mode) {
      case "current":
        return resolveMonthCycle(
          anchor: anchor,
          value: "cycle:month:${cycle.startDay}:${cycle.endDay}:current",
        );
      default:
        return TimeRange.thisMonth();
    }
  }

  static TimeRange resolveMonthCycle({
    required DateTime anchor,
    required String value,
  }) {
    final List<String> parts = value.split(":");
    if (parts.length < 5) {
      return TimeRange.thisMonth();
    }

    final int startDay = int.tryParse(parts[2]) ?? 21;
    final int endDay = int.tryParse(parts[3]) ?? 20;
    final bool previous = parts[4] == "previous";

    final DateTime currentCycleStartMonth = anchor.day >= startDay
        ? DateTime(anchor.year, anchor.month, 1)
        : DateTime(anchor.year, anchor.month - 1, 1);

    final DateTime startMonth = previous
        ? DateTime(currentCycleStartMonth.year, currentCycleStartMonth.month - 1, 1)
        : currentCycleStartMonth;

    final DateTime endMonth = previous
        ? currentCycleStartMonth
        : DateTime(currentCycleStartMonth.year, currentCycleStartMonth.month + 1, 1);

    final DateTime cycleStart = _boundedDay(startMonth, startDay);
    final DateTime cycleEnd = _boundedDay(endMonth, endDay);

    return CustomTimeRange(cycleStart.startOfDay(), cycleEnd.endOfDay());
  }

  static DateTime _boundedDay(DateTime monthStart, int day) {
    final int daysInMonth = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    final int boundedDay = day.clamp(1, daysInMonth);
    return DateTime(monthStart.year, monthStart.month, boundedDay);
  }

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TransactionFilterTimeRange) return false;

    return value == other.value;
  }

  TransactionFilterTimeRangePreset? get preset =>
      TransactionFilterTimeRangePreset.values.firstWhereOrNull(
        (preset) => preset.value == value,
      );

  String toJson() => value;
  factory TransactionFilterTimeRange.fromJson(String value) =>
      TransactionFilterTimeRange(value);
}

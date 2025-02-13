import "package:flow/l10n/named_enum.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/widgets/utils/time_and_range.dart";
import "package:moment_dart/moment_dart.dart";

enum TransactionFilterTimeRangePreset implements LocalizedEnum {
  last30Days("last30Days"),
  thisWeek("thisWeek"),
  thisMonth("thisMonth"),
  thisYear("thisYear"),
  allTime("allTime");

  final String value;

  const TransactionFilterTimeRangePreset(this.value);

  @override
  String get localizationEnumName => "TransactionFilterRangePreset";

  @override
  String get localizationEnumValue => value;
}

class TransactionFilterTimeRange {
  final String value;

  const TransactionFilterTimeRange(this.value);
  factory TransactionFilterTimeRange._fromPreset(
          TransactionFilterTimeRangePreset preset) =>
      TransactionFilterTimeRange(preset.value);
  factory TransactionFilterTimeRange.fromTimeRange(TimeRange range) =>
      TransactionFilterTimeRange(range.encodeShort());

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
          TransactionFilterTimeRangePreset.allTime);

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

    return TimeRange.tryParse(value);
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
      TransactionFilterTimeRangePreset.values
          .firstWhereOrNull((preset) => preset.value == value);

  String toJson() => value;
  factory TransactionFilterTimeRange.fromJson(String value) =>
      TransactionFilterTimeRange(value);
}

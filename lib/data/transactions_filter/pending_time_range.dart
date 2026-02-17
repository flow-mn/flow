import "package:flow/l10n/named_enum.dart";
import "package:flow/utils/time_and_range.dart";
import "package:moment_dart/moment_dart.dart";

class PendingTimeRange with LocalizedEnum {
  final String value;
  final Duration? futureDuration;

  static const List<PendingTimeRange> presets = [
    PendingTimeRange.followHome(),
    PendingTimeRange.duration(Duration(days: 3)),
    PendingTimeRange.duration(Duration(days: 7)),
    PendingTimeRange.duration(Duration(days: 14)),
    PendingTimeRange.duration(Duration(days: 30)),
    PendingTimeRange.duration(Duration(days: 60)),
    PendingTimeRange.thisWeek(),
    PendingTimeRange.thisMonth(),
    PendingTimeRange.thisYear(),
    PendingTimeRange.allTime(),
  ];

  factory PendingTimeRange._normalized(
    String? value,
    Duration? futureDuration,
  ) {
    if (value == "nextNDays") {
      if (futureDuration == null) {
        throw ArgumentError(
          "futureDuration must be provided for nextNDays preset",
        );
      }
      return PendingTimeRange.duration(futureDuration);
    }

    switch (value) {
      case "followHome":
        return const PendingTimeRange.followHome();
      case "thisWeek":
        return const PendingTimeRange.thisWeek();
      case "thisMonth":
        return const PendingTimeRange.thisMonth();
      case "thisYear":
        return const PendingTimeRange.thisYear();
      case "allTime":
        return const PendingTimeRange.allTime();
      default:
        throw ArgumentError("Invalid value for PendingTimeRange: $value");
    }
  }

  const PendingTimeRange._(this.value, {this.futureDuration});
  const PendingTimeRange.duration(this.futureDuration) : value = "nextNDays";
  const PendingTimeRange.followHome() : this._("followHome");
  const PendingTimeRange.thisWeek() : this._("thisWeek");
  const PendingTimeRange.thisMonth() : this._("thisMonth");
  const PendingTimeRange.thisYear() : this._("thisYear");
  const PendingTimeRange.allTime() : this._("allTime");

  @override
  String toString() {
    if (value == "nextNDays") {
      return (futureDuration ?? Duration.zero).abs().inSeconds.toRadixString(
        36,
      );
    }

    return value;
  }

  static PendingTimeRange? tryParse(String? value) {
    if (value == null) return null;

    if (value == "followHome") return const PendingTimeRange.followHome();
    if (value == "thisWeek") return const PendingTimeRange.thisWeek();
    if (value == "thisMonth") return const PendingTimeRange.thisMonth();
    if (value == "thisYear") return const PendingTimeRange.thisYear();
    if (value == "allTime") return const PendingTimeRange.allTime();

    try {
      final int seconds = int.parse(value, radix: 36);
      return PendingTimeRange.duration(Duration(seconds: seconds));
    } catch (_) {
      return null;
    }
  }

  /// Throws [FormatException] if the value is not valid
  static PendingTimeRange parse(String value) {
    return tryParse(value) ??
        (throw FormatException("Invalid PendingTimeRangePreset value: $value"));
  }

  PendingTimeRange copyWith({String? value, Duration? futureDuration}) {
    return PendingTimeRange._normalized(
      value ?? this.value,
      futureDuration ?? this.futureDuration,
    );
  }

  @override
  String get localizationEnumName => "PendingTimeRange";

  @override
  String get localizationEnumValue => value;

  @override
  bool operator ==(Object other) {
    if (other is! PendingTimeRange) return false;
    if (identical(this, other)) return true;

    return value == other.value && futureDuration == other.futureDuration;
  }

  @override
  int get hashCode => Object.hash(value, futureDuration);

  TimeRange range({TimeRange? homeTimeRange}) => switch (value) {
    "nextNDays" => nextNDaysRange(futureDuration?.inDays ?? 0),
    "thisWeek" => TimeRange.thisLocalWeek(),
    "thisMonth" => TimeRange.thisMonth(),
    "thisYear" => TimeRange.thisYear(),
    "allTime" => TimeRange.allTime(),
    "followHome" when homeTimeRange != null => homeTimeRange,
    _ => nextNDaysRange(7),
  };
}

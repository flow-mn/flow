import "package:json_annotation/json_annotation.dart";
import "package:moment_dart/moment_dart.dart";

class TimeRangeConverter implements JsonConverter<TimeRange, String> {
  const TimeRangeConverter();

  @override
  TimeRange fromJson(String serialized) {
    return TimeRange.parse(serialized);
  }

  @override
  String toJson(TimeRange range) {
    return range.encodeShort();
  }
}

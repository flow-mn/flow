import "package:json_annotation/json_annotation.dart";

class DurationConverter implements JsonConverter<Duration, int> {
  const DurationConverter();

  @override
  Duration fromJson(int duration) {
    return Duration(microseconds: duration);
  }

  @override
  int toJson(Duration duration) {
    return duration.inMicroseconds;
  }
}

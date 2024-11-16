import "package:json_annotation/json_annotation.dart";

class UTCDateTimeConverter implements JsonConverter<DateTime, String> {
  const UTCDateTimeConverter();

  @override
  DateTime fromJson(String dateTime) {
    return DateTime.parse(dateTime).toLocal();
  }

  @override
  String toJson(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }
}

import "package:flow/l10n/named_enum.dart";
import "package:flow/utils/utils.dart";
import "package:json_annotation/json_annotation.dart";
import "package:moment_dart/moment_dart.dart";

@JsonEnum(valueField: "value")
enum UpcomingTransactionsDuration implements LocalizedEnum {
  none("none"),
  next7Days("next7Days"),
  next14Days("next14Days"),
  next30Days("next30Days"),
  thisWeek("thisWeek"),
  thisMonth("thisMonth"),
  thisYear("thisYear"),
  allTime("allTime");

  final String value;

  const UpcomingTransactionsDuration(this.value);

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "UpcomingTransactionsDuration";

  DateTime? endsAt([DateTime? anchor]) {
    final Moment now = anchor?.toMoment() ?? Moment.now();
    switch (this) {
      case UpcomingTransactionsDuration.none:
        return null;
      case UpcomingTransactionsDuration.next7Days:
        return now.add(Duration(days: 7)).endOfDay();
      case UpcomingTransactionsDuration.next14Days:
        return now.add(Duration(days: 14)).endOfDay();
      case UpcomingTransactionsDuration.next30Days:
        return now.add(Duration(days: 30)).endOfDay();
      case UpcomingTransactionsDuration.thisWeek:
        return now.endOfLocalWeek();
      case UpcomingTransactionsDuration.thisMonth:
        return now.endOfMonth();
      case UpcomingTransactionsDuration.thisYear:
        return now.endOfYear();
      case UpcomingTransactionsDuration.allTime:
        return Moment.maxValue;
    }
  }

  static UpcomingTransactionsDuration? fromJson(Map json) {
    return UpcomingTransactionsDuration.values
        .firstWhereOrNull((element) => element.value == json["value"]);
  }

  Map<String, dynamic> toJson() => {"value": value};
}

import "package:flow/l10n/named_enum.dart";
import "package:flow/utils/utils.dart";
import "package:json_annotation/json_annotation.dart";
import "package:moment_dart/moment_dart.dart";

@JsonEnum(valueField: "value")
enum UpcomingTransactionsDuration implements LocalizedEnum {
  next1Days("next1Days"),
  next2Days("next2Days"),
  next3Days("next3Days"),
  next5Days("next5Days"),
  next7Days("next7Days");

  final String value;

  const UpcomingTransactionsDuration(this.value);

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "UpcomingTransactionsDuration";

  DateTime? endsAt([DateTime? anchor]) {
    final Moment now = anchor?.toMoment() ?? Moment.now();
    switch (this) {
      case UpcomingTransactionsDuration.next1Days:
        return now.add(Duration(days: 1)).endOfDay();
      case UpcomingTransactionsDuration.next2Days:
        return now.add(Duration(days: 2)).endOfDay();
      case UpcomingTransactionsDuration.next3Days:
        return now.add(Duration(days: 3)).endOfDay();
      case UpcomingTransactionsDuration.next5Days:
        return now.add(Duration(days: 5)).endOfDay();
      case UpcomingTransactionsDuration.next7Days:
        return now.add(Duration(days: 7)).endOfDay();
    }
  }

  static UpcomingTransactionsDuration? fromJson(Map json) {
    return UpcomingTransactionsDuration.values
        .firstWhereOrNull((element) => element.value == json["value"]);
  }

  Map<String, dynamic> toJson() => {"value": value};
}

import "package:flow/l10n/named_enum.dart";
import "package:flow/utils/utils.dart";
import "package:json_annotation/json_annotation.dart";
import "package:moment_dart/moment_dart.dart";

@JsonEnum(valueField: "value")
enum PendingTransactionsDuration implements LocalizedEnum {
  next1Days("next1Days"),
  next2Days("next2Days"),
  next3Days("next3Days"),
  next5Days("next5Days"),
  next7Days("next7Days");

  final String value;

  const PendingTransactionsDuration(this.value);

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "PendingTransactionsDuration";

  DateTime? endsAt([DateTime? anchor]) {
    final Moment now = anchor?.toMoment() ?? Moment.now();
    switch (this) {
      case PendingTransactionsDuration.next1Days:
        return now.add(Duration(days: 1)).endOfDay();
      case PendingTransactionsDuration.next2Days:
        return now.add(Duration(days: 2)).endOfDay();
      case PendingTransactionsDuration.next3Days:
        return now.add(Duration(days: 3)).endOfDay();
      case PendingTransactionsDuration.next5Days:
        return now.add(Duration(days: 5)).endOfDay();
      case PendingTransactionsDuration.next7Days:
        return now.add(Duration(days: 7)).endOfDay();
    }
  }

  static PendingTransactionsDuration? fromJson(Map json) {
    return PendingTransactionsDuration.values
        .firstWhereOrNull((element) => element.value == json["value"]);
  }

  Map<String, dynamic> toJson() => {"value": value};
}

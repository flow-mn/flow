import "package:flow/l10n/named_enum.dart";
import "package:json_annotation/json_annotation.dart";

@JsonEnum(valueField: "value")
enum RecurrenceMode implements LocalizedEnum {
  everyDay("everyDay"),
  everyWeek("everyWeek"),
  every2Week("every2Week"),
  everyMonth("everyMonth"),
  everyYear("everyYear"),
  custom("custom");

  final String value;

  const RecurrenceMode(this.value);

  @override
  String get localizationEnumName => "RecurrenceMode";

  @override
  String get localizationEnumValue => value;
}

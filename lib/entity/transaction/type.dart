import "package:flow/l10n/named_enum.dart";
import "package:json_annotation/json_annotation.dart";

@JsonEnum(valueField: "value")
enum TransactionType with LocalizedEnum {
  transfer("transfer"),
  income("income"),
  expense("expense");

  final String value;

  const TransactionType(this.value);

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "TransactionType";
}

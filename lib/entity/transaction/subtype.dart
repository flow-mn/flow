import "package:flow/l10n/named_enum.dart";
import "package:json_annotation/json_annotation.dart";

@JsonEnum(valueField: "value")
enum TransactionSubtype with LocalizedEnum {
  transactionFee("transactionFee"),
  givenLoan("loan.given"),
  receivedLoan("loan.received"),
  updateBalance("updateBalance");

  final String value;

  const TransactionSubtype(this.value);

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "TransactionSubtype";
}

import "package:flow/l10n/named_enum.dart";
import "package:json_annotation/json_annotation.dart";

@JsonEnum(valueField: "value")
enum TransactionTagType with LocalizedEnum {
  generic("generic"),
  location("location"),
  contact("contact");

  final String value;

  const TransactionTagType(this.value);

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "TransactionTagType";

  static TransactionTagType fromString(String? value) {
    return TransactionTagType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionTagType.generic,
    );
  }
}

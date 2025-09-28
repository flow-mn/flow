import "package:flow/l10n/named_enum.dart";

enum CSVHeader with LocalizedEnum {
  uuid,
  title,
  notes,
  amount,
  currency,
  account,
  accountUuid,
  category,
  categoryUuid,
  type,
  subtype,
  createdDate,
  transactionDate,
  transactionDateIso8601,
  latitude,
  longitude,
  extra;

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "CSVHeader";
}

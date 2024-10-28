import "package:flow/l10n/named_enum.dart";

enum CSVHeadersV1 implements LocalizedEnum {
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
  latitude,
  longitude,
  extra;

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "CSVHeadersV1";
}

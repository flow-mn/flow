import 'package:flow/l10n/named_enum.dart';

enum CSVHeadersV1 implements LocalizedEnum {
  uuid,
  title,
  amount,
  currency,
  account,
  accountUuid,
  category,
  categoryUuid,
  subtype,
  createdDate,
  transactionDate,
  extra;

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "CSVHeadersV1";
}

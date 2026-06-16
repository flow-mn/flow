// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
  name: json['name'] as String,
  currency: json['currency'] as String,
  iconCode: json['iconCode'] as String,
  creditLimit: (json['creditLimit'] as num?)?.toDouble(),
  colorSchemeName: json['colorSchemeName'] as String?,
  excludeFromTotalBalance: json['excludeFromTotalBalance'] as bool? ?? false,
  archived: json['archived'] as bool? ?? false,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? -1,
  type: json['type'] as String? ?? AccountType.debitValue,
  createdDate: _$JsonConverterFromJson<String, DateTime>(
    json['createdDate'],
    const UTCDateTimeConverter().fromJson,
  ),
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updatedAt'],
    const UTCDateTimeConverter().fromJson,
  ),
  isDeleted: json['isDeleted'] as bool?,
  deletedDate: _$JsonConverterFromJson<String, DateTime>(
    json['deletedDate'],
    const UTCDateTimeConverter().fromJson,
  ),
)..uuid = json['uuid'] as String;

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'createdDate': const UTCDateTimeConverter().toJson(instance.createdDate),
  'updatedAt': _$JsonConverterToJson<String, DateTime>(
    instance.updatedAt,
    const UTCDateTimeConverter().toJson,
  ),
  'isDeleted': instance.isDeleted,
  'deletedDate': _$JsonConverterToJson<String, DateTime>(
    instance.deletedDate,
    const UTCDateTimeConverter().toJson,
  ),
  'name': instance.name,
  'currency': instance.currency,
  'creditLimit': instance.creditLimit,
  'sortOrder': instance.sortOrder,
  'type': instance.type,
  'excludeFromTotalBalance': instance.excludeFromTotalBalance,
  'archived': instance.archived,
  'colorSchemeName': instance.colorSchemeName,
  'iconCode': instance.iconCode,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  name: json['name'] as String,
  iconCode: json['iconCode'] as String,
  createdDate: _$JsonConverterFromJson<String, DateTime>(
    json['createdDate'],
    const UTCDateTimeConverter().fromJson,
  ),
  colorSchemeName: json['colorSchemeName'] as String?,
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

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
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
  'iconCode': instance.iconCode,
  'colorSchemeName': instance.colorSchemeName,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

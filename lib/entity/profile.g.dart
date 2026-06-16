// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
  createdDate: _$JsonConverterFromJson<String, DateTime>(
    json['createdDate'],
    const UTCDateTimeConverter().fromJson,
  ),
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updatedAt'],
    const UTCDateTimeConverter().fromJson,
  ),
  name: json['name'] as String,
)..uuid = json['uuid'] as String;

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'createdDate': const UTCDateTimeConverter().toJson(instance.createdDate),
  'updatedAt': _$JsonConverterToJson<String, DateTime>(
    instance.updatedAt,
    const UTCDateTimeConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionTag _$TransactionTagFromJson(Map<String, dynamic> json) =>
    TransactionTag(
      uuid: json['uuid'] as String?,
      createdDate: _$JsonConverterFromJson<String, DateTime>(
        json['createdDate'],
        const UTCDateTimeConverter().fromJson,
      ),
      isDeleted: json['isDeleted'] as bool?,
      deletedDate: _$JsonConverterFromJson<String, DateTime>(
        json['deletedDate'],
        const UTCDateTimeConverter().fromJson,
      ),
      title: json['title'] as String,
      type: json['type'] as String?,
      payload: json['payload'] as String?,
      iconCode: json['iconCode'] as String?,
      colorSchemeName: json['colorSchemeName'] as String?,
    );

Map<String, dynamic> _$TransactionTagToJson(TransactionTag instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'createdDate': const UTCDateTimeConverter().toJson(instance.createdDate),
      'isDeleted': instance.isDeleted,
      'deletedDate': _$JsonConverterToJson<String, DateTime>(
        instance.deletedDate,
        const UTCDateTimeConverter().toJson,
      ),
      'title': instance.title,
      'iconCode': instance.iconCode,
      'colorSchemeName': instance.colorSchemeName,
      'type': instance.type,
      'payload': instance.payload,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_filter_preset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionFilterPreset _$TransactionFilterPresetFromJson(
  Map<String, dynamic> json,
) => TransactionFilterPreset(
  createdDate: _$JsonConverterFromJson<String, DateTime>(
    json['createdDate'],
    const UTCDateTimeConverter().fromJson,
  ),
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updatedAt'],
    const UTCDateTimeConverter().fromJson,
  ),
  jsonTransactionFilter: json['jsonTransactionFilter'] as String,
  name: json['name'] as String,
)..uuid = json['uuid'] as String;

Map<String, dynamic> _$TransactionFilterPresetToJson(
  TransactionFilterPreset instance,
) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'jsonTransactionFilter': instance.jsonTransactionFilter,
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

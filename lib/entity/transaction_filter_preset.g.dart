// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_filter_preset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionFilterPreset _$TransactionFilterPresetFromJson(
        Map<String, dynamic> json) =>
    TransactionFilterPreset(
      createdDate: _$JsonConverterFromJson<String, DateTime>(
          json['createdDate'], const UTCDateTimeConverter().fromJson),
      jsonTransactionFilter: json['jsonTransactionFilter'] as String,
      name: json['name'] as String,
    )..uuid = json['uuid'] as String;

Map<String, dynamic> _$TransactionFilterPresetToJson(
        TransactionFilterPreset instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'jsonTransactionFilter': instance.jsonTransactionFilter,
      'createdDate': const UTCDateTimeConverter().toJson(instance.createdDate),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

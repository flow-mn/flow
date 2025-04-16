// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringTransaction _$RecurringTransactionFromJson(
  Map<String, dynamic> json,
) => RecurringTransaction(
  disabled: json['disabled'] as bool? ?? false,
  rules: (json['rules'] as List<dynamic>).map((e) => e as String).toList(),
  jsonTransactionTemplate: json['jsonTransactionTemplate'] as String,
  transferToAccountUuid: json['transferToAccountUuid'] as String?,
  createdDate: _$JsonConverterFromJson<String, DateTime>(
    json['createdDate'],
    const UTCDateTimeConverter().fromJson,
  ),
  range: json['range'] as String?,
  uuid: json['uuid'] as String?,
  lastGeneratedTransactionDate: _$JsonConverterFromJson<String, DateTime>(
    json['lastGeneratedTransactionDate'],
    const UTCDateTimeConverter().fromJson,
  ),
  lastGeneratedTransactionUuid: json['lastGeneratedTransactionUuid'] as String?,
);

Map<String, dynamic> _$RecurringTransactionToJson(
  RecurringTransaction instance,
) => <String, dynamic>{
  'uuid': instance.uuid,
  'jsonTransactionTemplate': instance.jsonTransactionTemplate,
  'transferToAccountUuid': instance.transferToAccountUuid,
  'range': instance.range,
  'rules': instance.rules,
  'createdDate': const UTCDateTimeConverter().toJson(instance.createdDate),
  'lastGeneratedTransactionDate': _$JsonConverterToJson<String, DateTime>(
    instance.lastGeneratedTransactionDate,
    const UTCDateTimeConverter().toJson,
  ),
  'lastGeneratedTransactionUuid': instance.lastGeneratedTransactionUuid,
  'disabled': instance.disabled,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

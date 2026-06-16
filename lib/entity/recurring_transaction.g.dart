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
  range: json['range'] as String,
  transferToAccountUuid: json['transferToAccountUuid'] as String?,
  lastGeneratedTransactionDate: _$JsonConverterFromJson<String, DateTime>(
    json['lastGeneratedTransactionDate'],
    const UTCDateTimeConverter().fromJson,
  ),
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
  uuid: json['uuid'] as String?,
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
  'updatedAt': _$JsonConverterToJson<String, DateTime>(
    instance.updatedAt,
    const UTCDateTimeConverter().toJson,
  ),
  'isDeleted': instance.isDeleted,
  'deletedDate': _$JsonConverterToJson<String, DateTime>(
    instance.deletedDate,
    const UTCDateTimeConverter().toJson,
  ),
  'lastGeneratedTransactionDate': _$JsonConverterToJson<String, DateTime>(
    instance.lastGeneratedTransactionDate,
    const UTCDateTimeConverter().toJson,
  ),
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

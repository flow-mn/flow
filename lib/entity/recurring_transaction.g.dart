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
  createdDate: _$JsonConverterFromJson<String, DateTime>(
    json['createdDate'],
    const UTCDateTimeConverter().fromJson,
  ),
  range: json['range'] as String?,
)..uuid = json['uuid'] as String;

Map<String, dynamic> _$RecurringTransactionToJson(
  RecurringTransaction instance,
) => <String, dynamic>{
  'uuid': instance.uuid,
  'jsonTransactionTemplate': instance.jsonTransactionTemplate,
  'range': instance.range,
  'rules': instance.rules,
  'createdDate': const UTCDateTimeConverter().toJson(instance.createdDate),
  'disabled': instance.disabled,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recurring _$RecurringFromJson(Map<String, dynamic> json) => Recurring(
  relatedTransactionUuid: json['relatedTransactionUuid'] as String?,
  range: json['range'] as String?,
  rules: (json['rules'] as List<dynamic>).map((e) => e as String).toList(),
  uuid: json['uuid'] as String,
);

Map<String, dynamic> _$RecurringToJson(Recurring instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'relatedTransactionUuid': instance.relatedTransactionUuid,
  'range': instance.range,
  'rules': instance.rules,
  'key': instance.key,
};

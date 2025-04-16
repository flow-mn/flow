// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recurring _$RecurringFromJson(Map<String, dynamic> json) => Recurring(
  relatedTransactionUuid: json['relatedTransactionUuid'] as String?,
  recurringTransactionUuid: json['recurringTransactionUuid'] as String,
  uuid: json['uuid'] as String,
  locked: json['locked'] as bool? ?? false,
);

Map<String, dynamic> _$RecurringToJson(Recurring instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'relatedTransactionUuid': instance.relatedTransactionUuid,
  'recurringTransactionUuid': instance.recurringTransactionUuid,
  'locked': instance.locked,
  'key': instance.key,
};

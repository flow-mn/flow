// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recurring _$RecurringFromJson(Map<String, dynamic> json) => Recurring(
  uuid: json['uuid'] as String,
  relatedTransactionUuid: json['relatedTransactionUuid'] as String?,
  locked: json['locked'] as bool? ?? false,
);

Map<String, dynamic> _$RecurringToJson(Recurring instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'relatedTransactionUuid': instance.relatedTransactionUuid,
  'locked': instance.locked,
  'key': instance.key,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transfer _$TransferFromJson(Map<String, dynamic> json) => Transfer(
  uuid: json['uuid'] as String,
  fromAccountUuid: json['fromAccountUuid'] as String,
  toAccountUuid: json['toAccountUuid'] as String,
  relatedTransactionUuid: json['relatedTransactionUuid'] as String?,
  conversionRate: (json['conversionRate'] as num?)?.toDouble(),
);

Map<String, dynamic> _$TransferToJson(Transfer instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'key': instance.key,
  'fromAccountUuid': instance.fromAccountUuid,
  'toAccountUuid': instance.toAccountUuid,
  'conversionRate': instance.conversionRate,
  'relatedTransactionUuid': instance.relatedTransactionUuid,
};

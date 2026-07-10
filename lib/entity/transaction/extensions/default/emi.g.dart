// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmiExtension _$EmiExtensionFromJson(Map<String, dynamic> json) => EmiExtension(
  uuid: json['uuid'] as String,
  emiUuid: json['emiUuid'] as String,
)..relatedTransactionUuid = json['relatedTransactionUuid'] as String?;

Map<String, dynamic> _$EmiExtensionToJson(EmiExtension instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'key': instance.key,
      'emiUuid': instance.emiUuid,
      'relatedTransactionUuid': instance.relatedTransactionUuid,
    };

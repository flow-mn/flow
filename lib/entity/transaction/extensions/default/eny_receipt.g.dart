// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eny_receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnyReceipt _$EnyReceiptFromJson(Map<String, dynamic> json) => EnyReceipt(
  uuid: json['uuid'] as String,
  relatedTransactionUuid: json['relatedTransactionUuid'] as String?,
  enyImageUrl: json['enyImageUrl'] as String?,
  enyReceiptId: json['enyReceiptId'] as String?,
  partOfMultiTransaction: json['partOfMultiTransaction'] as bool?,
);

Map<String, dynamic> _$EnyReceiptToJson(EnyReceipt instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'relatedTransactionUuid': instance.relatedTransactionUuid,
      'enyReceiptId': instance.enyReceiptId,
      'enyImageUrl': instance.enyImageUrl,
      'partOfMultiTransaction': instance.partOfMultiTransaction,
      'key': instance.key,
    };

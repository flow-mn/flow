// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
      title: json['title'] as String?,
      subtype: json['subtype'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      transactionDate: json['transactionDate'] == null
          ? null
          : DateTime.parse(json['transactionDate'] as String),
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
    )
      ..uuid = json['uuid'] as String
      ..extra = json['extra'] as String?
      ..categoryUuid = json['categoryUuid'] as String?
      ..accountUuid = json['accountUuid'] as String?;

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'createdDate': instance.createdDate.toIso8601String(),
      'transactionDate': instance.transactionDate.toIso8601String(),
      'title': instance.title,
      'amount': instance.amount,
      'currency': instance.currency,
      'subtype': instance.subtype,
      'extra': instance.extra,
      'categoryUuid': instance.categoryUuid,
      'accountUuid': instance.accountUuid,
    };

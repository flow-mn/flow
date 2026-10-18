// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foreign_currency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForeignCurrency _$ForeignCurrencyFromJson(Map<String, dynamic> json) =>
    ForeignCurrency(
      uuid: json['uuid'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      relatedTransactionUuid: json['relatedTransactionUuid'] as String?,
    );

Map<String, dynamic> _$ForeignCurrencyToJson(ForeignCurrency instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'key': instance.key,
      'amount': instance.amount,
      'currency': instance.currency,
      'relatedTransactionUuid': instance.relatedTransactionUuid,
    };

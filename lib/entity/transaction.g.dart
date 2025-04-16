// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) =>
    Transaction(
        title: json['title'] as String?,
        description: json['description'] as String?,
        subtype: json['subtype'] as String?,
        isPending: json['isPending'] as bool?,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String,
        uuid: json['uuid'] as String,
        transactionDate: _$JsonConverterFromJson<String, DateTime>(
          json['transactionDate'],
          const UTCDateTimeConverter().fromJson,
        ),
        createdDate: _$JsonConverterFromJson<String, DateTime>(
          json['createdDate'],
          const UTCDateTimeConverter().fromJson,
        ),
      )
      ..isDeleted = json['isDeleted'] as bool?
      ..deletedDate = _$JsonConverterFromJson<String, DateTime>(
        json['deletedDate'],
        const UTCDateTimeConverter().fromJson,
      )
      ..extra = json['extra'] as String?
      ..extraKeys = json['extraKeys'] as String?
      ..categoryUuid = json['categoryUuid'] as String?
      ..accountUuid = json['accountUuid'] as String?;

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'createdDate': const UTCDateTimeConverter().toJson(instance.createdDate),
      'transactionDate': const UTCDateTimeConverter().toJson(
        instance.transactionDate,
      ),
      'isDeleted': instance.isDeleted,
      'deletedDate': _$JsonConverterToJson<String, DateTime>(
        instance.deletedDate,
        const UTCDateTimeConverter().toJson,
      ),
      'title': instance.title,
      'description': instance.description,
      'amount': instance.amount,
      'isPending': instance.isPending,
      'currency': instance.currency,
      'subtype': instance.subtype,
      'extra': instance.extra,
      'extraKeys': instance.extraKeys,
      'categoryUuid': instance.categoryUuid,
      'accountUuid': instance.accountUuid,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

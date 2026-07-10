// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Emi _$EmiFromJson(Map<String, dynamic> json) =>
    Emi(
        title: json['title'] as String,
        description: json['description'] as String?,
        totalAmount: (json['totalAmount'] as num).toDouble(),
        installmentAmount: (json['installmentAmount'] as num).toDouble(),
        totalInstallments: (json['totalInstallments'] as num).toInt(),
        paidInstallments: (json['paidInstallments'] as num?)?.toInt() ?? 0,
        remainingInstallments: (json['remainingInstallments'] as num).toInt(),
        paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
        remainingAmount: (json['remainingAmount'] as num).toDouble(),
        startDate: const UTCDateTimeConverter().fromJson(
          json['startDate'] as String,
        ),
        nextDueDate: _$JsonConverterFromJson<String, DateTime>(
          json['nextDueDate'],
          const UTCDateTimeConverter().fromJson,
        ),
        status: json['status'] as String? ?? "active",
        createdDate: _$JsonConverterFromJson<String, DateTime>(
          json['createdDate'],
          const UTCDateTimeConverter().fromJson,
        ),
      )
      ..uuid = json['uuid'] as String
      ..accountUuid = json['accountUuid'] as String?
      ..categoryUuid = json['categoryUuid'] as String?;

Map<String, dynamic> _$EmiToJson(Emi instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'createdDate': const UTCDateTimeConverter().toJson(instance.createdDate),
  'title': instance.title,
  'description': instance.description,
  'totalAmount': instance.totalAmount,
  'installmentAmount': instance.installmentAmount,
  'totalInstallments': instance.totalInstallments,
  'paidInstallments': instance.paidInstallments,
  'remainingInstallments': instance.remainingInstallments,
  'paidAmount': instance.paidAmount,
  'remainingAmount': instance.remainingAmount,
  'startDate': const UTCDateTimeConverter().toJson(instance.startDate),
  'nextDueDate': _$JsonConverterToJson<String, DateTime>(
    instance.nextDueDate,
    const UTCDateTimeConverter().toJson,
  ),
  'accountUuid': instance.accountUuid,
  'categoryUuid': instance.categoryUuid,
  'status': instance.status,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

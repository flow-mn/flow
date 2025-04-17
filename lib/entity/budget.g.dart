// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Budget _$BudgetFromJson(Map<String, dynamic> json) => Budget(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      range: json['range'] as String,
      createdDate: _$JsonConverterFromJson<String, DateTime>(
          json['createdDate'], const UTCDateTimeConverter().fromJson),
    )
      ..uuid = json['uuid'] as String
      ..timeRange =
          const TimeRangeConverter().fromJson(json['timeRange'] as String)
      ..categoryUuid = json['categoryUuid'] as String?;

Map<String, dynamic> _$BudgetToJson(Budget instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'createdDate': const UTCDateTimeConverter().toJson(instance.createdDate),
      'name': instance.name,
      'range': instance.range,
      'timeRange': const TimeRangeConverter().toJson(instance.timeRange),
      'amount': instance.amount,
      'currency': instance.currency,
      'categoryUuid': instance.categoryUuid,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

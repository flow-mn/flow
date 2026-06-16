// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Budget _$BudgetFromJson(Map<String, dynamic> json) =>
    Budget(
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String,
        range: json['range'] as String,
        renewAutomatically: json['renewAutomatically'] as bool? ?? true,
        createdDate: _$JsonConverterFromJson<String, DateTime>(
          json['createdDate'],
          const UTCDateTimeConverter().fromJson,
        ),
        updatedAt: _$JsonConverterFromJson<String, DateTime>(
          json['updatedAt'],
          const UTCDateTimeConverter().fromJson,
        ),
        isDeleted: json['isDeleted'] as bool?,
        deletedDate: _$JsonConverterFromJson<String, DateTime>(
          json['deletedDate'],
          const UTCDateTimeConverter().fromJson,
        ),
      )
      ..uuid = json['uuid'] as String
      ..timeRange = const TimeRangeConverter().fromJson(
        json['timeRange'] as String,
      )
      ..categoriesUuids = (json['categoriesUuids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList();

Map<String, dynamic> _$BudgetToJson(Budget instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'createdDate': const UTCDateTimeConverter().toJson(instance.createdDate),
  'updatedAt': _$JsonConverterToJson<String, DateTime>(
    instance.updatedAt,
    const UTCDateTimeConverter().toJson,
  ),
  'isDeleted': instance.isDeleted,
  'deletedDate': _$JsonConverterToJson<String, DateTime>(
    instance.deletedDate,
    const UTCDateTimeConverter().toJson,
  ),
  'name': instance.name,
  'range': instance.range,
  'timeRange': const TimeRangeConverter().toJson(instance.timeRange),
  'renewAutomatically': instance.renewAutomatically,
  'amount': instance.amount,
  'currency': instance.currency,
  'categoriesUuids': instance.categoriesUuids,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

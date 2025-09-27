// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Goal _$GoalFromJson(Map<String, dynamic> json) =>
    Goal(
        name: json['name'] as String,
        targetBalance: (json['targetBalance'] as num).toDouble(),
        currency: json['currency'] as String,
        range: json['range'] as String?,
        iconCode: json['iconCode'] as String?,
        createdDate: _$JsonConverterFromJson<String, DateTime>(
          json['createdDate'],
          const UTCDateTimeConverter().fromJson,
        ),
      )
      ..uuid = json['uuid'] as String
      ..timeRange = _$JsonConverterFromJson<String, TimeRange>(
        json['timeRange'],
        const TimeRangeConverter().fromJson,
      )
      ..accountUuid = json['accountUuid'] as String?;

Map<String, dynamic> _$GoalToJson(Goal instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'createdDate': const UTCDateTimeConverter().toJson(instance.createdDate),
  'name': instance.name,
  'range': instance.range,
  'timeRange': _$JsonConverterToJson<String, TimeRange>(
    instance.timeRange,
    const TimeRangeConverter().toJson,
  ),
  'targetBalance': instance.targetBalance,
  'currency': instance.currency,
  'iconCode': instance.iconCode,
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

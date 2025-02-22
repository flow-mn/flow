// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
        combineTransfers: json['combineTransfers'] as bool? ?? true,
        excludeTransfersFromFlow:
            json['excludeTransfersFromFlow'] as bool? ?? true,
        trashBinRetentionDays:
            (json['trashBinRetentionDays'] as num?)?.toInt() ?? 30,
        defaultFilterPreset: json['defaultFilterPreset'] as String?,
      )
      ..uuid = json['uuid'] as String
      ..remindDailyAt = _$JsonConverterFromJson<int, Duration>(
        json['remindDailyAt'],
        const DurationConverter().fromJson,
      );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'combineTransfers': instance.combineTransfers,
      'excludeTransfersFromFlow': instance.excludeTransfersFromFlow,
      'trashBinRetentionDays': instance.trashBinRetentionDays,
      'defaultFilterPreset': instance.defaultFilterPreset,
      'remindDailyAt': _$JsonConverterToJson<int, Duration>(
        instance.remindDailyAt,
        const DurationConverter().toJson,
      ),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

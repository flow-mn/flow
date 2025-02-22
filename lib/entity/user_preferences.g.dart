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
      ..remindDailyAtRelativeSeconds =
          (json['remindDailyAtRelativeSeconds'] as num?)?.toInt();

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'combineTransfers': instance.combineTransfers,
      'excludeTransfersFromFlow': instance.excludeTransfersFromFlow,
      'trashBinRetentionDays': instance.trashBinRetentionDays,
      'defaultFilterPreset': instance.defaultFilterPreset,
      'remindDailyAtRelativeSeconds': instance.remindDailyAtRelativeSeconds,
    };

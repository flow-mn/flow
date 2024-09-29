// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frecency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FrecencyData _$FrecencyDataFromJson(Map<String, dynamic> json) => FrecencyData(
      uuid: json['uuid'] as String,
      lastUsed: DateTime.parse(json['lastUsed'] as String),
      useCount: (json['useCount'] as num).toInt(),
    );

Map<String, dynamic> _$FrecencyDataToJson(FrecencyData instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'lastUsed': instance.lastUsed.toIso8601String(),
      'useCount': instance.useCount,
    };

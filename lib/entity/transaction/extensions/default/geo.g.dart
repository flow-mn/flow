// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Geo _$GeoFromJson(Map<String, dynamic> json) => Geo(
      uuid: json['uuid'] as String,
      relatedTransactionUuid: json['relatedTransactionUuid'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      isMocked: json['isMocked'] as bool? ?? false,
    );

Map<String, dynamic> _$GeoToJson(Geo instance) => <String, dynamic>{
      'key': instance.key,
      'uuid': instance.uuid,
      'relatedTransactionUuid': instance.relatedTransactionUuid,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'altitude': instance.altitude,
      'timestamp': instance.timestamp?.toIso8601String(),
      'isMocked': instance.isMocked,
    };

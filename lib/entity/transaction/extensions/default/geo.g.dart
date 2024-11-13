// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Geo _$GeoFromJson(Map<String, dynamic> json) => Geo(
      uuid: json['uuid'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      relatedTransactionUuid: json['relatedTransactionUuid'] as String?,
      altitude: (json['altitude'] as num?)?.toDouble(),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      isMocked: json['isMocked'] as bool? ?? false,
    );

Map<String, dynamic> _$GeoToJson(Geo instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'key': instance.key,
      'relatedTransactionUuid': instance.relatedTransactionUuid,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'altitude': instance.altitude,
      'timestamp': instance.timestamp?.toIso8601String(),
      'isMocked': instance.isMocked,
    };

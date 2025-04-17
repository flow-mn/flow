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
  timestamp: _$JsonConverterFromJson<String, DateTime>(
    json['timestamp'],
    const UTCDateTimeConverter().fromJson,
  ),
  isMocked: json['isMocked'] as bool? ?? false,
);

Map<String, dynamic> _$GeoToJson(Geo instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'key': instance.key,
  'relatedTransactionUuid': instance.relatedTransactionUuid,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'altitude': instance.altitude,
  'timestamp': _$JsonConverterToJson<String, DateTime>(
    instance.timestamp,
    const UTCDateTimeConverter().toJson,
  ),
  'isMocked': instance.isMocked,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

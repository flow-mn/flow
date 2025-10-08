// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionTagLocationPayload _$TransactionTagLocationPayloadFromJson(
  Map<String, dynamic> json,
) => TransactionTagLocationPayload(
  (json['lat'] as num).toDouble(),
  (json['lng'] as num).toDouble(),
);

Map<String, dynamic> _$TransactionTagLocationPayloadToJson(
  TransactionTagLocationPayload instance,
) => <String, dynamic>{'lat': instance.lat, 'lng': instance.lng};

TransactionContactTag _$TransactionContactTagFromJson(
  Map<String, dynamic> json,
) => TransactionContactTag(
  id: json['id'] as String?,
  name: json['name'] as String?,
);

Map<String, dynamic> _$TransactionContactTagToJson(
  TransactionContactTag instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};

TransactionTagPayload _$TransactionTagPayloadFromJson(
  Map<String, dynamic> json,
) => TransactionTagPayload(
  location: json['location'] == null
      ? null
      : TransactionTagLocationPayload.fromJson(
          json['location'] as Map<String, dynamic>,
        ),
  contact: json['contact'] == null
      ? null
      : TransactionContactTag.fromJson(json['contact'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TransactionTagPayloadToJson(
  TransactionTagPayload instance,
) => <String, dynamic>{
  'location': instance.location,
  'contact': instance.contact,
};

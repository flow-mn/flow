// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileAttachment _$FileAttachmentFromJson(Map<String, dynamic> json) =>
    FileAttachment(
      name: json['name'] as String?,
      filePath: json['filePath'] as String,
      createdDate: _$JsonConverterFromJson<String, DateTime>(
        json['createdDate'],
        const UTCDateTimeConverter().fromJson,
      ),
    )..uuid = json['uuid'] as String;

Map<String, dynamic> _$FileAttachmentToJson(FileAttachment instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'createdDate': const UTCDateTimeConverter().toJson(instance.createdDate),
      'name': instance.name,
      'filePath': instance.filePath,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

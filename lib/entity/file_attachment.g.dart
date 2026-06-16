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
      updatedAt: _$JsonConverterFromJson<String, DateTime>(
        json['updatedAt'],
        const UTCDateTimeConverter().fromJson,
      ),
      isDeleted: json['isDeleted'] as bool?,
      deletedDate: _$JsonConverterFromJson<String, DateTime>(
        json['deletedDate'],
        const UTCDateTimeConverter().fromJson,
      ),
    )..uuid = json['uuid'] as String;

Map<String, dynamic> _$FileAttachmentToJson(FileAttachment instance) =>
    <String, dynamic>{
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
      'filePath': instance.filePath,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

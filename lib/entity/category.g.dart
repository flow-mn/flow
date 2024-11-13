// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      name: json['name'] as String,
      iconCode: json['iconCode'] as String,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
    )..uuid = json['uuid'] as String;

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'createdDate': instance.createdDate.toIso8601String(),
      'name': instance.name,
      'iconCode': instance.iconCode,
    };

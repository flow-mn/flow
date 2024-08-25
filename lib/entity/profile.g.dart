// GENERATED CODE - DO NOT MODIFY BY HAND

part of "profile.dart";

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      createdDate: json["createdDate"] == null
          ? null
          : DateTime.parse(json["createdDate"] as String),
      name: json["name"] as String,
    )..uuid = json["uuid"] as String;

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      "uuid": instance.uuid,
      "name": instance.name,
      "createdDate": instance.createdDate.toIso8601String(),
    };

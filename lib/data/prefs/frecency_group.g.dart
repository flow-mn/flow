// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frecency_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FrecencyGroup _$FrecencyGroupFromJson(Map<String, dynamic> json) =>
    FrecencyGroup(
      (json['data'] as List<dynamic>)
          .map((e) => FrecencyData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FrecencyGroupToJson(FrecencyGroup instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

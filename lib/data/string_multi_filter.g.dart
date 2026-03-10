// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'string_multi_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StringMultiFilter _$StringMultiFilterFromJson(Map<String, dynamic> json) =>
    StringMultiFilter(
      whitelist: json['whitelist'] as bool,
      items: (json['items'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$StringMultiFilterToJson(StringMultiFilter instance) =>
    <String, dynamic>{'whitelist': instance.whitelist, 'items': instance.items};

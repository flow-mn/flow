// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionSearchData _$TransactionSearchDataFromJson(
  Map<String, dynamic> json,
) => TransactionSearchData(
  keyword: json['keyword'] as String?,
  mode:
      $enumDecodeNullable(_$TransactionSearchModeEnumMap, json['mode']) ??
      TransactionSearchMode.smart,
  smartMatchThreshold:
      (json['smartMatchThreshold'] as num?)?.toDouble() ?? 80.0,
  includeDescription: json['includeDescription'] as bool? ?? true,
);

Map<String, dynamic> _$TransactionSearchDataToJson(
  TransactionSearchData instance,
) => <String, dynamic>{
  'keyword': instance.keyword,
  'mode': _$TransactionSearchModeEnumMap[instance.mode]!,
  'includeDescription': instance.includeDescription,
  'smartMatchThreshold': instance.smartMatchThreshold,
};

const _$TransactionSearchModeEnumMap = {
  TransactionSearchMode.smart: 'smart',
  TransactionSearchMode.substring: 'substring',
  TransactionSearchMode.exact: 'exact',
};

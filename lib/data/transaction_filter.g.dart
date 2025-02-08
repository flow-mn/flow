// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionFilter _$TransactionFilterFromJson(Map<String, dynamic> json) =>
    TransactionFilter(
      uuids:
          (json['uuids'] as List<dynamic>?)?.map((e) => e as String).toList(),
      categories: categoriesFromJson(json['categories'] as List<String>?),
      accounts: accountsFromJson(json['accounts'] as List<String>?),
      range: json['range'] == null
          ? null
          : TransactionFilterTimeRange.fromJson(json['range'] as String),
      types: (json['types'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$TransactionTypeEnumMap, e))
          .toList(),
      isPending: json['isPending'] as bool?,
      minAmount: (json['minAmount'] as num?)?.toDouble(),
      maxAmount: (json['maxAmount'] as num?)?.toDouble(),
      currencies: (json['currencies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      includeDeleted: json['includeDeleted'] as bool? ?? false,
      sortDescending: json['sortDescending'] as bool? ?? true,
      searchData: json['searchData'] == null
          ? const TransactionSearchData()
          : TransactionSearchData.fromJson(
              json['searchData'] as Map<String, dynamic>),
      sortBy:
          $enumDecodeNullable(_$TransactionSortFieldEnumMap, json['sortBy']) ??
              TransactionSortField.transactionDate,
      groupBy: $enumDecodeNullable(
              _$TransactionGroupRangeEnumMap, json['groupBy']) ??
          TransactionGroupRange.day,
    );

Map<String, dynamic> _$TransactionFilterToJson(TransactionFilter instance) =>
    <String, dynamic>{
      'range': instance.range?.toJson(),
      'uuids': instance.uuids,
      'searchData': instance.searchData.toJson(),
      'types': instance.types?.map((e) => e.toJson()).toList(),
      'categories': categoriesToJson(instance.categories),
      'accounts': accountsToJson(instance.accounts),
      'sortDescending': instance.sortDescending,
      'sortBy': _$TransactionSortFieldEnumMap[instance.sortBy]!,
      'groupBy': _$TransactionGroupRangeEnumMap[instance.groupBy]!,
      'isPending': instance.isPending,
      'minAmount': instance.minAmount,
      'maxAmount': instance.maxAmount,
      'currencies': instance.currencies,
      'includeDeleted': instance.includeDeleted,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.transfer: 'transfer',
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
};

const _$TransactionSortFieldEnumMap = {
  TransactionSortField.transactionDate: 'transactionDate',
  TransactionSortField.amount: 'amount',
  TransactionSortField.createdDate: 'createdDate',
};

const _$TransactionGroupRangeEnumMap = {
  TransactionGroupRange.hour: 'hour',
  TransactionGroupRange.day: 'day',
  TransactionGroupRange.week: 'week',
  TransactionGroupRange.month: 'month',
  TransactionGroupRange.year: 'year',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_v2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncModelV2 _$SyncModelV2FromJson(Map<String, dynamic> json) => SyncModelV2(
      versionCode: (json['versionCode'] as num).toInt(),
      exportDate: DateTime.parse(json['exportDate'] as String),
      username: json['username'] as String,
      appVersion: json['appVersion'] as String,
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      accounts: (json['accounts'] as List<dynamic>)
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      transactionFilterPresets:
          (json['transactionFilterPresets'] as List<dynamic>?)
              ?.map((e) =>
                  TransactionFilterPreset.fromJson(e as Map<String, dynamic>))
              .toList(),
      profile: json['profile'] == null
          ? null
          : Profile.fromJson(json['profile'] as Map<String, dynamic>),
      userPreferences: json['userPreferences'] == null
          ? null
          : UserPreferences.fromJson(
              json['userPreferences'] as Map<String, dynamic>),
      primaryCurrency: json['primaryCurrency'] as String?,
    );

Map<String, dynamic> _$SyncModelV2ToJson(SyncModelV2 instance) =>
    <String, dynamic>{
      'versionCode': instance.versionCode,
      'exportDate': instance.exportDate.toIso8601String(),
      'username': instance.username,
      'appVersion': instance.appVersion,
      'transactions': instance.transactions,
      'accounts': instance.accounts,
      'categories': instance.categories,
      'transactionFilterPresets': instance.transactionFilterPresets,
      'profile': instance.profile,
      'userPreferences': instance.userPreferences,
      'primaryCurrency': instance.primaryCurrency,
    };

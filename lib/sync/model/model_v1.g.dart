// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_v1.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncModelV1 _$SyncModelV1FromJson(Map<String, dynamic> json) => SyncModelV1(
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
    );

Map<String, dynamic> _$SyncModelV1ToJson(SyncModelV1 instance) =>
    <String, dynamic>{
      'versionCode': instance.versionCode,
      'exportDate': instance.exportDate.toIso8601String(),
      'username': instance.username,
      'appVersion': instance.appVersion,
      'transactions': instance.transactions,
      'accounts': instance.accounts,
      'categories': instance.categories,
    };

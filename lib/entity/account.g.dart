// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      name: json['name'] as String,
      currency: json['currency'] as String,
      iconCode: json['iconCode'] as String,
      creditLimit: (json['creditLimit'] as num?)?.toDouble(),
      excludeFromTotalBalance:
          json['excludeFromTotalBalance'] as bool? ?? false,
      archived: json['archived'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? -1,
      type: json['type'] as String? ?? AccountType.debitValue,
      showCreditLimit: json['showCreditLimit'] as bool? ?? true,
      createdDate: _$JsonConverterFromJson<String, DateTime>(
          json['createdDate'], const UTCDateTimeConverter().fromJson),
    )..uuid = json['uuid'] as String;

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'createdDate': const UTCDateTimeConverter().toJson(instance.createdDate),
      'name': instance.name,
      'currency': instance.currency,
      'creditLimit': instance.creditLimit,
      'showCreditLimit': instance.showCreditLimit,
      'sortOrder': instance.sortOrder,
      'type': instance.type,
      'iconCode': instance.iconCode,
      'excludeFromTotalBalance': instance.excludeFromTotalBalance,
      'archived': instance.archived,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

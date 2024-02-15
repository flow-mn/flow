// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transfer _$TransferTxnFromJson(Map<String, dynamic> json) => Transfer(
      fromAccountUuid: json['fromAccountUuid'] as String,
      toAccountUuid: json['toAccountUuid'] as String,
    );

Map<String, dynamic> _$TransferTxnToJson(Transfer instance) =>
    <String, dynamic>{
      'fromAccountUuid': instance.fromAccountUuid,
      'toAccountUuid': instance.toAccountUuid,
    };

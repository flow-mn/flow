// GENERATED CODE - DO NOT MODIFY BY HAND

part of "transfer.dart";

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transfer _$TransferFromJson(Map<String, dynamic> json) => Transfer(
      uuid: json["uuid"] as String,
      fromAccountUuid: json["fromAccountUuid"] as String,
      toAccountUuid: json["toAccountUuid"] as String,
      relatedTransactionUuid: json["relatedTransactionUuid"] as String,
    );

Map<String, dynamic> _$TransferToJson(Transfer instance) => <String, dynamic>{
      "key": instance.key,
      "fromAccountUuid": instance.fromAccountUuid,
      "toAccountUuid": instance.toAccountUuid,
      "relatedTransactionUuid": instance.relatedTransactionUuid,
      "uuid": instance.uuid,
    };

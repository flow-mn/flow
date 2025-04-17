// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flow_notification_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlowNotificationPayload _$FlowNotificationPayloadFromJson(
  Map<String, dynamic> json,
) => FlowNotificationPayload(
  itemType: $enumDecode(
    _$FlowNotificationPayloadItemTypeEnumMap,
    json['itemType'],
  ),
  id: json['id'] as String?,
  extra: json['extra'] as String?,
);

Map<String, dynamic> _$FlowNotificationPayloadToJson(
  FlowNotificationPayload instance,
) => <String, dynamic>{
  'itemType': _$FlowNotificationPayloadItemTypeEnumMap[instance.itemType]!,
  'id': instance.id,
  'extra': instance.extra,
};

const _$FlowNotificationPayloadItemTypeEnumMap = {
  FlowNotificationPayloadItemType.transaction: 'txn',
  FlowNotificationPayloadItemType.reminder: 'rmd',
};

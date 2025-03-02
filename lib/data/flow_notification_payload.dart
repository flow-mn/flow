import "dart:convert";

import "package:flow/utils/extensions.dart";
import "package:json_annotation/json_annotation.dart";

part "flow_notification_payload.g.dart";

@JsonEnum(valueField: "value")
enum FlowNotificationPayloadItemType {
  transaction("txn"),
  reminder("rmd");

  final String value;

  const FlowNotificationPayloadItemType(this.value);

  static FlowNotificationPayloadItemType? tryParse(String value) {
    return FlowNotificationPayloadItemType.values.firstWhereOrNull(
      (element) => element.value == value,
    );
  }

  static FlowNotificationPayloadItemType parse(String value) {
    final parsed = tryParse(value);

    if (parsed == null) {
      throw ArgumentError("Invalid value: $value");
    }

    return parsed;
  }
}

@JsonSerializable()
class FlowNotificationPayload {
  final FlowNotificationPayloadItemType itemType;

  /// The ID of the item, can be null depending on [itemType]
  final String? id;

  /// Extra data
  final String? extra;

  FlowNotificationPayload({
    required this.itemType,
    required this.id,
    this.extra,
  });

  String get serialized => jsonEncode(toJson());

  factory FlowNotificationPayload.parse(String serialized) {
    try {
      final json = jsonDecode(serialized);

      return FlowNotificationPayload.fromJson(json);
    } catch (e) {
      throw ArgumentError("Invalid serialized data: $serialized");
    }
  }

  factory FlowNotificationPayload.fromJson(Map<String, dynamic> json) =>
      _$FlowNotificationPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$FlowNotificationPayloadToJson(this);
}

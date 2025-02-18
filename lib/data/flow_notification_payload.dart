import "package:flow/utils/extensions.dart";

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

  String get serialized => "${itemType.value}|$id|${extra ?? ""}";

  static FlowNotificationPayload parse(String serialized) {
    try {
      final List<String> parts = serialized.split("|");

      return FlowNotificationPayload(
        itemType: FlowNotificationPayloadItemType.parse(parts[0]),
        id: parts[1].isNotEmpty ? parts[1] : null,
        extra: parts[2].isNotEmpty ? parts[2] : null,
      );
    } catch (e) {
      throw ArgumentError("Invalid serialized payload: $serialized");
    }
  }
}

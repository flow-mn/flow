import "package:flow/data/flow_notification_payload.dart";
import "package:flutter_test/flutter_test.dart";

/// So AI generated, please don't pay attention to the names lol

void main() {
  group(
    "FlowNotificationPayloadItemType serialization and deserialization",
    () {
      test("Transaction type", () {
        final payload = FlowNotificationPayload(
          id: "123",
          itemType: FlowNotificationPayloadItemType.transaction,
          extra: "data",
        );
        final parsed = FlowNotificationPayload.parse(payload.serialized);

        expect(parsed.itemType, payload.itemType);
        expect(parsed.id, payload.id);
        expect(parsed.extra, payload.extra);
      });

      test("Null id", () {
        final payload = FlowNotificationPayload(
          id: null,
          itemType: FlowNotificationPayloadItemType.reminder,
          extra: "test",
        );
        final parsed = FlowNotificationPayload.parse(payload.serialized);

        expect(parsed.itemType, payload.itemType);
        expect(parsed.id, payload.id);
        expect(parsed.extra, payload.extra);
      });

      test("Null extra", () {
        final payload = FlowNotificationPayload(
          id: "456",
          itemType: FlowNotificationPayloadItemType.transaction,
          extra: null,
        );
        final parsed = FlowNotificationPayload.parse(payload.serialized);

        expect(parsed.itemType, payload.itemType);
        expect(parsed.id, payload.id);
        expect(parsed.extra, payload.extra);
      });

      test("Both id and extra null", () {
        final payload = FlowNotificationPayload(
          id: null,
          itemType: FlowNotificationPayloadItemType.reminder,
          extra: null,
        );
        final parsed = FlowNotificationPayload.parse(payload.serialized);

        expect(parsed.itemType, payload.itemType);
        expect(parsed.id, payload.id);
        expect(parsed.extra, payload.extra);
      });

      test("Empty strings", () {
        final payload = FlowNotificationPayload(
          id: null,
          itemType: FlowNotificationPayloadItemType.transaction,
          extra: null,
        );
        final parsed = FlowNotificationPayload.parse(payload.serialized);

        expect(parsed.itemType, payload.itemType);
        expect(parsed.id, null);
        expect(parsed.extra, null);
      });

      test("Special characters in fields", () {
        final payload = FlowNotificationPayload(
          id: "user|123",
          itemType: FlowNotificationPayloadItemType.reminder,
          extra: "data with spaces & special chars!",
        );
        final parsed = FlowNotificationPayload.parse(payload.serialized);

        expect(parsed.itemType, payload.itemType);
        expect(parsed.id, payload.id);
        expect(parsed.extra, payload.extra);
      });

      test("Invalid format throws ArgumentError", () {
        expect(
          () => FlowNotificationPayload.parse("invalid"),
          throwsArgumentError,
        );
      });

      test("Invalid item type throws ArgumentError", () {
        expect(
          () => FlowNotificationPayload.parse("invalid|123|extra"),
          throwsArgumentError,
        );
      });

      test("Long strings", () {
        final longId = "a" * 100;
        final longExtra = "b" * 1000;
        final payload = FlowNotificationPayload(
          id: longId,
          itemType: FlowNotificationPayloadItemType.transaction,
          extra: longExtra,
        );
        final parsed = FlowNotificationPayload.parse(payload.serialized);

        expect(parsed.itemType, payload.itemType);
        expect(parsed.id, payload.id);
        expect(parsed.extra, payload.extra);
      });

      test("Multiple roundtrips", () {
        final original = FlowNotificationPayload(
          id: "789",
          itemType: FlowNotificationPayloadItemType.reminder,
          extra: "important",
        );

        var serialized = original.serialized;
        for (var i = 0; i < 5; i++) {
          final parsed = FlowNotificationPayload.parse(serialized);
          serialized = parsed.serialized;

          expect(parsed.itemType, original.itemType);
          expect(parsed.id, original.id);
          expect(parsed.extra, original.extra);
        }
      });
    },
  );
}

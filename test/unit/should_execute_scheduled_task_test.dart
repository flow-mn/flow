import "package:flow/widgets/utils/should_execute_scheduled_task.dart";
import "package:flutter_test/flutter_test.dart";
import "package:moment_dart/moment_dart.dart";

void main() {
  group("shouldExecuteScheduledTask", () {
    test("returns true if lastExecution is null", () {
      final result = shouldExecuteScheduledTask(Duration(hours: 1), null);
      expect(result, isTrue);
    });

    test("returns true if interval has passed since lastExecution", () {
      final lastExecution = Moment.now().subtract(Duration(hours: 2));
      final result = shouldExecuteScheduledTask(
        Duration(hours: 1),
        lastExecution,
      );
      expect(result, isTrue);
    });

    test("returns false if interval has not passed since lastExecution", () {
      final lastExecution = DateTime.now().subtract(Duration(minutes: 30));
      final result = shouldExecuteScheduledTask(
        Duration(hours: 1),
        lastExecution,
      );
      expect(result, isFalse);
    });

    test("returns true if anchor is used and interval has passed", () {
      final lastExecution = DateTime(2023, 1, 1, 10, 0, 0);
      final anchor = DateTime(2023, 1, 1, 12, 0, 0);
      final result = shouldExecuteScheduledTask(
        Duration(hours: 1),
        lastExecution,
        anchor: anchor,
      );
      expect(result, isTrue);
    });

    test("returns false if anchor is used and interval has not passed", () {
      final lastExecution = DateTime(2023, 1, 1, 11, 30, 0);
      final anchor = DateTime(2023, 1, 1, 12, 0, 0);
      final result = shouldExecuteScheduledTask(
        Duration(hours: 1),
        lastExecution,
        anchor: anchor,
      );
      expect(result, isFalse);
    });

    test("handles edge case where interval exactly matches the difference", () {
      final lastExecution = DateTime(2023, 1, 1, 11, 0, 0);
      final anchor = DateTime(2023, 1, 1, 12, 0, 0);
      final result = shouldExecuteScheduledTask(
        Duration(hours: 1),
        lastExecution,
        anchor: anchor,
      );
      expect(result, isTrue);
    });

    test("handles very large intervals", () {
      final lastExecution = DateTime(2000, 1, 1);
      final anchor = DateTime(3000, 1, 1);
      final result = shouldExecuteScheduledTask(
        Duration(days: 365 * 500),
        lastExecution,
        anchor: anchor,
      );
      expect(result, isTrue);
    });

    test("handles very small intervals", () {
      final lastExecution = DateTime.now().subtract(Duration(milliseconds: 1));
      final result = shouldExecuteScheduledTask(
        Duration(milliseconds: 1),
        lastExecution,
      );
      expect(result, isTrue);
    });

    test("handles negative intervals", () {
      final lastExecution = DateTime.now();
      final result = shouldExecuteScheduledTask(
        Duration(seconds: -1),
        lastExecution,
      );
      expect(result, isFalse);
    });

    test("handles anchor being before lastExecution", () {
      final lastExecution = DateTime(2023, 1, 1, 12, 0, 0);
      final anchor = DateTime(2023, 1, 1, 11, 0, 0);
      final result = shouldExecuteScheduledTask(
        Duration(hours: 1),
        lastExecution,
        anchor: anchor,
      );
      expect(result, isFalse);
    });
  });
}

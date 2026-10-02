import "package:flow/utils/extensions/recurrence.dart";
import "package:flutter_test/flutter_test.dart";
import "package:moment_dart/moment_dart.dart";
import "package:recurrence/recurrence.dart";

void main() {
  Recurrence startingOct2(RecurrenceRule rule, [DateTime? end]) => Recurrence(
    range: CustomTimeRange(DateTime(2026, 10, 2, 9), end ?? Moment.maxValue),
    rules: [rule],
  );

  final DateTime sep30 = DateTime(2026, 9, 30, 14, 30);

  test("startingAt moves the start, even earlier", () {
    final Recurrence moved = startingOct2(
      RecurrenceRule.monthly(2),
    ).startingAt(sep30);

    expect(moved.range.from, sep30);
    expect(moved.range.to, Moment.maxValue);
  });

  test("startingAt takes monthly, weekly and yearly rules along", () {
    expect(startingOct2(RecurrenceRule.monthly(2)).startingAt(sep30).rules, [
      RecurrenceRule.monthly(30),
    ]);
    expect(
      startingOct2(
        RecurrenceRule.weekly(DateTime.friday),
      ).startingAt(sep30).rules,
      [RecurrenceRule.weekly(DateTime.wednesday)],
    );
    expect(startingOct2(RecurrenceRule.yearly(10, 2)).startingAt(sep30).rules, [
      RecurrenceRule.yearly(9, 30),
    ]);
  });

  test("startingAt leaves intervals alone", () {
    final RecurrenceRule every2Weeks = RecurrenceRule.interval(
      const Duration(days: 14),
    );

    expect(startingOct2(every2Weeks).startingAt(sep30).rules, [every2Weeks]);
  });

  test("startingAt lists occurrences on the new day", () {
    final Recurrence moved = startingOct2(
      RecurrenceRule.monthly(2),
    ).startingAt(sep30);

    final List<DateTime> next = moved.occurrences(
      subrange: CustomTimeRange(sep30, DateTime(2027, 1, 1)),
    );

    expect(next.map((date) => date.day).toSet(), {30});
  });

  test("startingAt keeps an end that's still ahead", () {
    final DateTime end = DateTime(2027, 1, 2, 9);

    expect(
      startingOct2(RecurrenceRule.monthly(2), end).startingAt(sep30).range.to,
      end,
    );
  });

  test("startingAt past the end runs indefinitely", () {
    final Recurrence moved = startingOct2(
      RecurrenceRule.monthly(2),
      DateTime(2026, 10, 20),
    ).startingAt(DateTime(2026, 11, 5));

    expect(moved.range.to, Moment.maxValue);
  });
}

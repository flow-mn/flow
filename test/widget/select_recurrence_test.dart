import "package:flow/l10n/flow_localizations.dart";
import "package:flow/routes/transaction_page/select_recurrence.dart";
import "package:flow/theme/flow_custom_colors.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:moment_dart/moment_dart.dart";
import "package:recurrence/recurrence.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await FlowLocalizations(const Locale("en")).load();
  });

  Future<List<Recurrence>> pump(
    WidgetTester tester, {
    Recurrence? initialValue,
    DateTime? defaultStart,
    TimeRange? startBounds,
  }) async {
    final List<Recurrence> changes = [];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [_TestLocalizationsDelegate()],
        theme: ThemeData(
          extensions: const [
            FlowCustomColors(
              income: Color(0xFF32CC70),
              expense: Color(0xFFFF4040),
              semi: Color(0xFF888888),
            ),
          ],
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: SelectRecurrence(
              initialValue: initialValue,
              defaultStart: defaultStart,
              onChanged: changes.add,
              startBounds: startBounds,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    return changes;
  }

  testWidgets("reports the default, so saving it untouched works", (
    tester,
  ) async {
    final List<Recurrence> changes = await pump(tester);

    expect(changes, hasLength(1));
    expect(changes.single.rules.single, isA<MonthlyRecurrenceRule>());
  });

  testWidgets("doesn't report an initial value back", (tester) async {
    final List<Recurrence> changes = await pump(
      tester,
      initialValue: Recurrence.fromIndefinitely(
        rules: [MonthlyRecurrenceRule(day: 3)],
        start: DateTime(2026, 1, 3),
      ),
    );

    expect(changes, isEmpty);
  });

  /// Picks [day] of the shown month as the start, skipping the time
  Future<void> pickStart(WidgetTester tester, int day) async {
    await tester.tap(find.byType(ListTile).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text("$day"));
    await tester.tap(find.text("OK"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();
  }

  testWidgets("default starts at the given date, on its day", (tester) async {
    final List<Recurrence> changes = await pump(
      tester,
      defaultStart: DateTime(2026, 9, 30, 14, 30),
    );

    expect(changes.single.range.from, DateTime(2026, 9, 30, 14, 30));
    expect(changes.single.rules.single, MonthlyRecurrenceRule(day: 30));
  });

  testWidgets("moving the start moves the monthly day with it", (tester) async {
    final List<Recurrence> changes = await pump(
      tester,
      initialValue: Recurrence.fromIndefinitely(
        rules: [MonthlyRecurrenceRule(day: 2)],
        start: DateTime(2026, 10, 2),
      ),
      startBounds: TimeRange.allTime(),
    );

    await pickStart(tester, 30);

    expect(changes.last.range.from, DateTime(2026, 10, 30));
    expect(changes.last.rules.single, MonthlyRecurrenceRule(day: 30));
  });

  testWidgets("moving the start moves the weekday with it", (tester) async {
    final List<Recurrence> changes = await pump(
      tester,
      initialValue: Recurrence.fromIndefinitely(
        rules: [WeeklyRecurrenceRule(weekday: DateTime.friday)],
        start: DateTime(2026, 10, 2),
      ),
      startBounds: TimeRange.allTime(),
    );

    await pickStart(tester, 7);

    expect(
      changes.last.rules.single,
      WeeklyRecurrenceRule(weekday: DateTime.wednesday),
    );
  });

  testWidgets("moving the start moves the yearly date with it", (tester) async {
    final List<Recurrence> changes = await pump(
      tester,
      initialValue: Recurrence.fromIndefinitely(
        rules: [RecurrenceRule.yearly(10, 2)],
        start: DateTime(2026, 10, 2),
      ),
      startBounds: TimeRange.allTime(),
    );

    await pickStart(tester, 30);

    expect(changes.last.rules.single, RecurrenceRule.yearly(10, 30));
  });

  testWidgets("a start past the end drops the end", (tester) async {
    final List<Recurrence> changes = await pump(
      tester,
      initialValue: Recurrence(
        range: CustomTimeRange(DateTime(2026, 10, 2), DateTime(2026, 10, 20)),
        rules: [MonthlyRecurrenceRule(day: 2)],
      ),
      startBounds: TimeRange.allTime(),
    );

    await pickStart(tester, 30);

    expect(changes.last.range.to, Moment.maxValue);
  });

  testWidgets("start can't be moved without bounds", (tester) async {
    final List<Recurrence> changes = await pump(
      tester,
      initialValue: Recurrence.fromIndefinitely(
        rules: [MonthlyRecurrenceRule(day: 2)],
        start: DateTime(2026, 10, 2),
      ),
    );

    await tester.tap(find.byType(ListTile).at(1));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsNothing);
    expect(changes, isEmpty);
  });
}

/// [FlowLocalizations.delegate] also syncs home widgets over a platform
/// channel, which isn't there in widget tests.
class _TestLocalizationsDelegate
    extends LocalizationsDelegate<FlowLocalizations> {
  const _TestLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<FlowLocalizations> load(Locale locale) =>
      SynchronousFuture(FlowLocalizations(locale));

  @override
  bool shouldReload(_TestLocalizationsDelegate old) => false;
}

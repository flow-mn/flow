import "package:flow/l10n/flow_localizations.dart";
import "package:flow/routes/transaction_page/select_recurrence.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:recurrence/recurrence.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await FlowLocalizations(const Locale("en")).load();
  });

  Future<List<Recurrence>> pump(
    WidgetTester tester, {
    Recurrence? initialValue,
  }) async {
    final List<Recurrence> changes = [];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [_TestLocalizationsDelegate()],
        home: Scaffold(
          body: SingleChildScrollView(
            child: SelectRecurrence(
              initialValue: initialValue,
              onChanged: changes.add,
              startBounds: null,
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

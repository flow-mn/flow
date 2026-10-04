import "dart:io";

import "package:flow/entity/account.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/recurring.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/pending_transactions.dart";
import "package:flow/services/recurring_transactions.dart";
import "package:flutter_test/flutter_test.dart";
import "package:moment_dart/moment_dart.dart";
import "package:path/path.dart" as path;
import "package:recurrence/recurrence.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../objectbox_erase.dart";

void main() {
  late ObjectBox obx;
  late Account account;
  late Account other;

  final String directory = path.join(
    Directory.current.path,
    ".objectbox_test_recurring_schedule",
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    PendingTransactionsLocalPreferences.initialize(_MemoryPreferences());

    obx = await ObjectBox.initialize(
      customDirectory: directory,
      subdirectory: "recurring_schedule",
    );

    account = Account(name: "Card", currency: "USD", iconCode: "irrelevant");
    other = Account(name: "Savings", currency: "USD", iconCode: "irrelevant");
    obx.box<Account>().putMany([account, other]);
  });

  tearDownAll(() async {
    await testCleanupObject(
      instance: obx,
      directory: path.join(directory, "recurring_schedule"),
    );
  });

  setUp(() {
    obx.box<Transaction>().removeAll();
    obx.box<RecurringTransaction>().removeAll();
  });

  /// A series the way saving a transaction sets it up: the first transaction
  /// is logged at [start], and the rest is generated as of [now].
  Future<RecurringTransaction> series({
    required DateTime start,
    required DateTime now,
    required List<RecurrenceRule> rules,
    DateTime? end,
    Account? transferTo,
  }) async {
    final Recurrence recurrence = Recurrence(
      range: CustomTimeRange(start, end ?? Moment.maxValue),
      rules: rules,
    );

    final RecurringTransaction rule = RecurringTransaction(
      jsonTransactionTemplate: "",
      rules: recurrence.rules.map((rule) => rule.serialize()).toList(),
      range: recurrence.range.encodeShort(),
      transferToAccountUuid: transferTo?.uuid,
      lastGeneratedTransactionDate: start,
    );

    final Recurring extension = Recurring(
      uuid: rule.uuid,
      initialTransactionDate: start,
    );

    late final int id;

    if (transferTo == null) {
      id = account.createAndSaveTransaction(
        amount: -40.0,
        title: "Rent",
        transactionDate: start,
        extensions: [extension],
      );
    } else {
      (id, _) = account.transferTo(
        targetAccount: transferTo,
        amount: 40.0,
        transactionDate: start,
        extensions: [extension],
      );
    }

    rule.template = obx.box<Transaction>().get(id)!;
    obx.box<RecurringTransaction>().put(rule);

    await RecurringTransactionsService().synchronizeAll(anchor: now);

    return rule;
  }

  /// Dates of the transactions in [rule]'s series, one per occurrence
  List<DateTime> dates(RecurringTransaction rule) =>
      obx
          .box<Transaction>()
          .getAll()
          .where(
            (transaction) =>
                transaction.extensions.recurring?.uuid == rule.uuid &&
                !(transaction.isTransfer && transaction.amount > 0),
          )
          .map((transaction) => transaction.transactionDate.date)
          .toList()
        ..sort();

  test("Monthly keeps its day after a start in the past", () async {
    final RecurringTransaction rule = await series(
      start: DateTime(2026, 9, 30, 14, 30),
      now: DateTime(2026, 10, 2, 9),
      rules: [RecurrenceRule.monthly(30)],
    );

    expect(dates(rule), [DateTime(2026, 9, 30), DateTime(2026, 10, 30)]);
  });

  test("Only the one ahead is pending", () async {
    final RecurringTransaction rule = await series(
      start: DateTime(2026, 7, 30),
      now: DateTime(2026, 10, 2),
      rules: [RecurrenceRule.monthly(30)],
    );

    final Iterable<Transaction> pending = obx.box<Transaction>().getAll().where(
      (transaction) => transaction.isPending == true,
    );

    expect(dates(rule), hasLength(4));
    expect(pending.single.transactionDate.date, DateTime(2026, 10, 30));
  });

  test("Catches up on a start months ago, plus one ahead", () async {
    final RecurringTransaction rule = await series(
      start: DateTime(2026, 6, 15, 8),
      now: DateTime(2026, 10, 2),
      rules: [RecurrenceRule.monthly(15)],
    );

    expect(dates(rule), [
      DateTime(2026, 6, 15),
      DateTime(2026, 7, 15),
      DateTime(2026, 8, 15),
      DateTime(2026, 9, 15),
      DateTime(2026, 10, 15),
    ]);
  });

  test("Monthly on the 31st clamps to shorter months", () async {
    final RecurringTransaction rule = await series(
      start: DateTime(2026, 12, 31, 10),
      now: DateTime(2027, 4, 15),
      rules: [RecurrenceRule.monthly(31)],
    );

    expect(dates(rule), [
      DateTime(2026, 12, 31),
      DateTime(2027, 1, 31),
      DateTime(2027, 2, 28),
      DateTime(2027, 3, 31),
      DateTime(2027, 4, 30),
    ]);
  });

  test("Weekly keeps its weekday", () async {
    final DateTime start = DateTime(2026, 9, 16, 18);

    final RecurringTransaction rule = await series(
      start: start,
      now: DateTime(2026, 10, 2),
      rules: [RecurrenceRule.weekly(start.weekday)],
    );

    expect(dates(rule), [
      DateTime(2026, 9, 16),
      DateTime(2026, 9, 23),
      DateTime(2026, 9, 30),
      DateTime(2026, 10, 7),
    ]);
  });

  test("Every 2 weeks counts from the start", () async {
    final RecurringTransaction rule = await series(
      start: DateTime(2026, 9, 1, 12),
      now: DateTime(2026, 10, 2),
      rules: [RecurrenceRule.interval(const Duration(days: 14))],
    );

    expect(dates(rule), [
      DateTime(2026, 9, 1),
      DateTime(2026, 9, 15),
      DateTime(2026, 9, 29),
      DateTime(2026, 10, 13),
    ]);
  });

  test("Yearly keeps its date", () async {
    final RecurringTransaction rule = await series(
      start: DateTime(2024, 9, 30),
      now: DateTime(2026, 10, 2),
      rules: [RecurrenceRule.yearly(9, 30)],
    );

    expect(dates(rule), [
      DateTime(2024, 9, 30),
      DateTime(2025, 9, 30),
      DateTime(2026, 9, 30),
      DateTime(2027, 9, 30),
    ]);
  });

  test("Stops at the end of the range", () async {
    final RecurringTransaction rule = await series(
      start: DateTime(2026, 6, 30, 9),
      end: DateTime(2026, 8, 30, 9),
      now: DateTime(2026, 10, 2),
      rules: [RecurrenceRule.monthly(30)],
    );

    expect(dates(rule), [
      DateTime(2026, 6, 30),
      DateTime(2026, 7, 30),
      DateTime(2026, 8, 30),
    ]);
  });

  test("A start in the future generates nothing more yet", () async {
    final RecurringTransaction rule = await series(
      start: DateTime(2026, 10, 30),
      now: DateTime(2026, 10, 2),
      rules: [RecurrenceRule.monthly(30)],
    );

    expect(dates(rule), [DateTime(2026, 10, 30)]);
  });

  test("Synchronizing again doesn't duplicate", () async {
    final DateTime now = DateTime(2026, 10, 2);

    final RecurringTransaction rule = await series(
      start: DateTime(2026, 8, 30),
      now: now,
      rules: [RecurrenceRule.monthly(30)],
    );

    final List<DateTime> before = dates(rule);

    await RecurringTransactionsService().synchronizeAll(anchor: now);
    await RecurringTransactionsService().synchronizeAll(anchor: now);

    expect(before, hasLength(3));
    expect(dates(rule), before);
  });

  test("Generates the next one once time passes", () async {
    final RecurringTransaction rule = await series(
      start: DateTime(2026, 9, 30),
      now: DateTime(2026, 10, 2),
      rules: [RecurrenceRule.monthly(30)],
    );

    await RecurringTransactionsService().synchronizeAll(
      anchor: DateTime(2026, 10, 30, 12),
    );

    expect(dates(rule), [
      DateTime(2026, 9, 30),
      DateTime(2026, 10, 30),
      DateTime(2026, 11, 30),
    ]);
  });

  test("Transfers follow the schedule on both sides", () async {
    final RecurringTransaction rule = await series(
      start: DateTime(2026, 8, 30, 7),
      now: DateTime(2026, 10, 2),
      rules: [RecurrenceRule.monthly(30)],
      transferTo: other,
    );

    expect(dates(rule), [
      DateTime(2026, 8, 30),
      DateTime(2026, 9, 30),
      DateTime(2026, 10, 30),
    ]);
    expect(
      obx.box<Transaction>().getAll().where((x) => x.amount > 0),
      hasLength(3),
    );
  });
}

class _MemoryPreferences extends Fake implements SharedPreferencesWithCache {
  final Map<String, Object> _values = {};

  @override
  bool containsKey(String key) => _values.containsKey(key);

  @override
  Object? get(String key) => _values[key];

  @override
  bool? getBool(String key) => _values[key] as bool?;

  @override
  int? getInt(String key) => _values[key] as int?;

  @override
  Future<void> setBool(String key, bool value) async => _values[key] = value;

  @override
  Future<void> setInt(String key, int value) async => _values[key] = value;
}

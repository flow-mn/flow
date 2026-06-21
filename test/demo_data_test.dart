import "dart:io";

import "package:flow/entity/account.dart";
import "package:flow/entity/budget.dart";
import "package:flow/entity/goal.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/objectbox.dart";
import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as path;

import "objectbox_erase.dart";

/// Exercises the full demo-data seeding (`createAndPutDebugData`) end to end and
/// asserts the generated history is rich and internally consistent.
void main() {
  late ObjectBox obx;

  final String directory = path.join(
    Directory.current.path,
    ".objectbox_test_demo",
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Account/category presets are localized; load English so their (unique)
    // names aren't all empty strings.
    await FlowLocalizations(const Locale("en")).load();

    obx = await ObjectBox.initialize(
      customDirectory: directory,
      subdirectory: "demo",
    );

    await obx.createAndPutDebugData();
  });

  tearDownAll(() async {
    await testCleanupObject(
      instance: obx,
      directory: path.join(directory, "demo"),
    );
  });

  test("creates the four demo accounts", () {
    final List<Account> accounts = obx.box<Account>().getAll();
    expect(accounts.length, 4);
    expect(
      accounts.where((a) => a.accountType == AccountType.creditLine).length,
      1,
    );
  });

  test("generates a rich, multi-year transaction history", () {
    final List<Transaction> txns = obx.box<Transaction>().getAll();

    expect(
      txns.length,
      greaterThan(1500),
      reason: "expected a dense history, got ${txns.length}",
    );

    final List<DateTime> dates =
        txns.map((t) => t.transactionDate).toList()..sort();
    final int spanDays = dates.last.difference(dates.first).inDays;

    expect(
      spanDays,
      greaterThan(365 * 3 - 45),
      reason: "history should span ~3 years, spanned $spanDays days",
    );
    // Nothing in the future.
    expect(dates.last.isAfter(DateTime.now().add(const Duration(minutes: 1))),
        isFalse);
  });

  test("never leaves a debit/savings account negative", () {
    for (final Account account in obx.box<Account>().getAll()) {
      final double balance = account.balance.amount;

      if (account.accountType == AccountType.creditLine) {
        expect(balance, lessThanOrEqualTo(0.01), reason: account.name);
        expect(
          balance,
          greaterThanOrEqualTo(-(account.creditLimit ?? 0)),
          reason: account.name,
        );
      } else {
        expect(
          balance,
          greaterThanOrEqualTo(-0.01),
          reason: "${account.name} went negative: $balance",
        );
      }
    }
  });

  test("savings grows beyond its starting balance", () {
    final Account savings = obx
        .box<Account>()
        .getAll()
        .firstWhere((a) => a.excludeFromTotalBalance);

    // Started at 8,500 and receives monthly contributions + interest.
    expect(savings.balance.amount, greaterThan(9000));
  });

  test("transactions are mostly categorized and meaningfully tagged", () {
    final List<Transaction> txns = obx.box<Transaction>().getAll();

    final int categorized =
        txns.where((t) => t.category.target != null).length;
    expect(categorized, greaterThan(txns.length ~/ 2));

    final int tagged = txns.where((t) => t.tags.isNotEmpty).length;
    expect(tagged, greaterThan(100));
  });

  test("populates budgets and goals", () {
    expect(obx.box<Budget>().getAll().length, greaterThanOrEqualTo(3));

    final List<Goal> goals = obx.box<Goal>().getAll();
    expect(goals.length, greaterThanOrEqualTo(2));
    expect(goals.every((g) => g.account.target != null), isTrue);
  });

  test("running it again is a no-op (guarded)", () async {
    final int before = obx.box<Transaction>().count();
    await obx.createAndPutDebugData();
    expect(obx.box<Transaction>().count(), before);
  });
}

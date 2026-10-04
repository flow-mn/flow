import "dart:io";

import "package:flow/entity/account.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/services/recurring_transactions.dart";
import "package:flow/services/transactions.dart";
import "package:flow/utils/extensions/recurring_transaction.dart";
import "package:flow/utils/extensions/transaction.dart";
import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as path;
import "package:recurrence/recurrence.dart";

import "../objectbox_erase.dart";

void main() {
  late ObjectBox obx;
  late Account account;
  late Account other;

  final String directory = path.join(
    Directory.current.path,
    ".objectbox_test_variable_recurring",
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    obx = await ObjectBox.initialize(
      customDirectory: directory,
      subdirectory: "variable_recurring",
    );

    account = Account(name: "Card", currency: "USD", iconCode: "irrelevant");
    other = Account(name: "Savings", currency: "EUR", iconCode: "irrelevant");
    obx.box<Account>().putMany([account, other]);
  });

  tearDownAll(() async {
    await testCleanupObject(
      instance: obx,
      directory: path.join(directory, "variable_recurring"),
    );
  });

  setUp(() {
    obx.box<Transaction>().removeAll();
    obx.box<RecurringTransaction>().removeAll();
  });

  /// A monthly rule that started 3 months ago, created from a -40 charge.
  Future<RecurringTransaction> monthlyRule({required bool variable}) async {
    final DateTime start = DateTime.now().subtract(const Duration(days: 90));

    final int id = account.createAndSaveTransaction(
      amount: -40.0,
      title: "Electricity",
      transactionDate: start,
    );
    final Transaction first = obx.box<Transaction>().get(id)!;

    final Recurrence recurrence = Recurrence.fromIndefinitely(
      rules: [RecurrenceRule.monthly(start.day)],
      start: start,
    );

    final RecurringTransaction rule = RecurringTransaction(
      jsonTransactionTemplate: "",
      rules: recurrence.rules.map((rule) => rule.serialize()).toList(),
      range: recurrence.range.encodeShort(),
      variableAmount: variable,
      lastGeneratedTransactionDate: start,
    )..template = first;

    obx.box<RecurringTransaction>().put(rule);

    await RecurringTransactionsService().synchronizeAll();

    return rule;
  }

  List<Transaction> generated(RecurringTransaction rule) =>
      obx.box<Transaction>().getAll().where((transaction) {
          return transaction.extensions.recurring?.uuid == rule.uuid;
        }).toList()
        ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

  test("Variable amounts are generated as pending estimates", () async {
    final RecurringTransaction rule = await monthlyRule(variable: true);
    final List<Transaction> items = generated(rule);

    expect(items, isNotEmpty);
    for (final Transaction item in items) {
      expect(item.isPending, isTrue);
      expect(item.amount, -40.0);
      expect(item.isAmountEstimate, isTrue);
    }
  });

  test("Fixed amounts aren't estimates", () async {
    final RecurringTransaction rule = await monthlyRule(variable: false);
    final List<Transaction> items = generated(rule);

    expect(items, isNotEmpty);
    expect(items.where((item) => item.isAmountEstimate), isEmpty);
  });

  test(
    "Confirming takes the actual amount, and it's the next estimate",
    () async {
      final RecurringTransaction rule = await monthlyRule(variable: true);
      final Transaction first = generated(rule).first;

      expect(first.confirmWithAmount(55.0, false), isTrue);

      final Transaction confirmed = TransactionsService().getOneSync(first.id)!;
      expect(confirmed.amount, -55.0);
      expect(confirmed.isPending, isFalse);
      expect(confirmed.isAmountEstimate, isFalse);

      expect(rule.estimateAmount(rule.template, generated(rule)), -55.0);
    },
  );

  test("Estimate ignores pending ones and falls back to the template", () {
    final RecurringTransaction rule = RecurringTransaction(
      jsonTransactionTemplate: "{}",
      rules: [],
      range: "",
      variableAmount: true,
    );
    final Transaction template = Transaction(
      uuid: "t",
      amount: -40.0,
      currency: "USD",
    );

    expect(
      rule.estimateAmount(template, [
        Transaction(uuid: "t", amount: -99.0, currency: "USD", isPending: true),
      ]),
      -40.0,
    );

    rule.variableAmount = false;
    expect(
      rule.estimateAmount(template, [
        Transaction(uuid: "t", amount: -99.0, currency: "USD"),
      ]),
      -40.0,
    );
  });

  test("Confirming a transfer updates both sides", () {
    final (int fromId, int toId) = account.transferTo(
      targetAccount: other,
      amount: 100.0,
      conversionRate: 0.5,
      isPending: true,
    );

    final Transaction from = TransactionsService().getOneSync(fromId)!;
    expect(from.confirmWithAmount(120.0, false), isTrue);

    final Transaction fromAfter = TransactionsService().getOneSync(fromId)!;
    final Transaction toAfter = TransactionsService().getOneSync(toId)!;

    expect(fromAfter.amount, -120.0);
    expect(toAfter.amount, 60.0);
    expect(fromAfter.isPending, isFalse);
    expect(toAfter.isPending, isFalse);
  });
}

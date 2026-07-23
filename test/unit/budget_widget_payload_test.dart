import "dart:convert";
import "dart:io";

import "package:flow/entity/account.dart";
import "package:flow/entity/budget.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/services/budget_widget_sync.dart";
import "package:flutter_test/flutter_test.dart";
import "package:moment_dart/moment_dart.dart";
import "package:path/path.dart" as path;
import "package:uuid/uuid.dart";

import "../objectbox_erase.dart";

/// Guards the JSON contract that the iOS and Android home-screen widgets
/// decode (`scratchpad/budget-widget-contract.md`).
///
/// Nothing in Dart consumes this payload, so a renamed key or a changed type
/// breaks no build and fails no other test — it surfaces as a widget quietly
/// rendering placeholder text on someone's home screen, weeks later, with the
/// two native decoders failing silently in separate processes.
///
/// The privacy tests matter most. "Hide amounts" is implemented on the platform
/// side by omitting the money fields, which only works if the percentage-only
/// fields are genuinely sufficient to render the widget. If `percent`/`ratio`/
/// `status` ever stopped being populated, the private variant would degrade to
/// showing nothing — or worse, tempt a future implementer to fall back to the
/// amounts.
void main() {
  late ObjectBox obx;

  final String directory = path.join(
    Directory.current.path,
    ".objectbox_test_budget_widget",
  );

  final MonthTimeRange thisMonth = MonthTimeRange.fromDateTime(DateTime.now());
  final DateTime insideThisMonth = thisMonth.from.add(const Duration(hours: 1));

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    obx = await ObjectBox.initialize(
      customDirectory: directory,
      subdirectory: "budget_widget",
    );
  });

  tearDownAll(() async {
    await testCleanupObject(
      instance: obx,
      directory: path.join(directory, "budget_widget"),
    );
  });

  setUp(() {
    obx.box<Transaction>().removeAll();
    obx.box<Budget>().removeAll();
    obx.box<Category>().removeAll();
    obx.box<Account>().removeAll();
  });

  Account makeAccount() {
    final Account account = Account(
      name: "Checking",
      currency: "USD",
      iconCode: "",
    );
    obx.box<Account>().put(account);
    return account;
  }

  void spend(Account account, double amount) {
    final Transaction transaction = Transaction(
      amount: -amount.abs(),
      currency: "USD",
      uuid: const Uuid().v4(),
      transactionDate: insideThisMonth,
    );
    transaction.account.target = account;
    obx.box<Transaction>().put(transaction);
  }

  Budget makeBudget(String name, double amount) {
    final Budget budget = Budget(
      name: name,
      amount: amount,
      currency: "USD",
      range: thisMonth.toString(),
    );
    obx.box<Budget>().put(budget);
    return budget;
  }

  test("payload is JSON-encodable", () async {
    makeBudget("Groceries", 100.0);
    spend(makeAccount(), 40.0);

    final Map<String, dynamic> payload = await BudgetWidgetSync.buildPayload();

    // The widgets receive a string, so anything non-encodable here is a crash
    // at sync time, in production, inside a catch-all.
    expect(() => jsonEncode(payload), returnsNormally);
  });

  test("declares its version so an older extension can bail out", () async {
    final Map<String, dynamic> payload = await BudgetWidgetSync.buildPayload();

    expect(payload["version"], BudgetWidgetSync.payloadVersion);
    expect(payload["version"], 1);
  });

  test("no budgets yields an empty list, not a missing key", () async {
    final Map<String, dynamic> payload = await BudgetWidgetSync.buildPayload();

    expect(payload["budgets"], isEmpty);
    expect((payload["summary"] as Map)["budgetCount"], 0);
    expect((payload["summary"] as Map)["worstId"], isNull);
    expect(payload["labels"], isA<Map<String, String>>());
  });

  test(
    "every documented budget field is present with its documented type",
    () async {
      makeBudget("Groceries", 100.0);
      spend(makeAccount(), 40.0);

      final Map<String, dynamic> payload =
          await BudgetWidgetSync.buildPayload();

      final Map<String, dynamic> budget =
          (payload["budgets"] as List).single as Map<String, dynamic>;

      expect(budget["id"], isA<int>());
      expect(budget["name"], "Groceries");
      expect(budget["spent"], isA<String>());
      expect(budget["limit"], isA<String>());
      expect(budget["remaining"], isA<String>());
      expect(budget["overBy"], isA<String>());
      expect(budget["percent"], isA<int>());
      expect(budget["percentLabel"], isA<String>());
      expect(budget["percentLabel"], isNotEmpty);
      expect(budget["ratio"], isA<double>());
      expect(budget["status"], "healthy");
      expect(budget["daysLeft"], isA<int>());
      // May be absent when translations aren't loaded — see the labels test.
      expect(budget["periodLabel"], isA<String>());
      expect(budget["hasMissingData"], isA<bool>());
    },
  );

  test(
    "the privacy variant has everything it needs without any amount",
    () async {
      makeBudget("Groceries", 100.0);
      spend(makeAccount(), 92.0);

      final Map<String, dynamic> payload =
          await BudgetWidgetSync.buildPayload();

      final Map<String, dynamic> budget =
          (payload["budgets"] as List).single as Map<String, dynamic>;

      // Everything the amount-free rendering draws from, none of it monetary.
      expect(budget["percent"], 92);
      expect(budget["ratio"], moreOrLessEquals(0.92));
      expect(budget["status"], "warning");
      expect(budget["periodLabel"], isNotEmpty);
      expect(budget["name"], isNotEmpty);
    },
  );

  test("ratio is left unclamped so an overrun is representable", () async {
    makeBudget("Groceries", 100.0);
    spend(makeAccount(), 150.0);

    final Map<String, dynamic> payload = await BudgetWidgetSync.buildPayload();

    final Map<String, dynamic> budget =
        (payload["budgets"] as List).single as Map<String, dynamic>;

    expect(budget["ratio"], greaterThan(1.0));
    expect(budget["percent"], 150);
    expect(budget["status"], "over");
  });

  test("summary counts statuses and names the worst budget by id", () async {
    final Account account = makeAccount();

    final Budget over = makeBudget("Over", 10.0);
    makeBudget("Healthy", 100000.0);

    spend(account, 500.0);

    final Map<String, dynamic> payload = await BudgetWidgetSync.buildPayload();

    final Map<String, dynamic> summary =
        payload["summary"] as Map<String, dynamic>;

    expect(summary["budgetCount"], 2);
    expect(summary["overCount"], 1);
    // worstId must resolve against an entry actually present in `budgets`,
    // or the roll-up widget renders a name it can't find.
    expect(summary["worstId"], over.id);
    expect(
      (payload["budgets"] as List).cast<Map<String, dynamic>>().map(
        (budget) => budget["id"],
      ),
      contains(summary["worstId"]),
    );
  });

  test("budgets arrive most-urgent first", () async {
    final Account account = makeAccount();

    makeBudget("Healthy", 100000.0);
    makeBudget("Over", 10.0);

    spend(account, 500.0);

    final Map<String, dynamic> payload = await BudgetWidgetSync.buildPayload();

    final List<String> names = (payload["budgets"] as List)
        .cast<Map<String, dynamic>>()
        .map((budget) => budget["name"] as String)
        .toList();

    expect(names.first, "Over");
  });

  test("labels are never published empty", () async {
    makeBudget("Groceries", 100.0);
    spend(makeAccount(), 40.0);

    final Map<String, dynamic> payload = await BudgetWidgetSync.buildPayload();

    final Map<String, dynamic> labels =
        payload["labels"] as Map<String, dynamic>;

    // A sync can happen before FlowLocalizations loads, in which case a lookup
    // yields "". Those keys must be omitted, not published blank — a widget
    // can fall back to its own default word, but it cannot tell an
    // intentionally-empty label from a missing translation.
    for (final MapEntry<String, dynamic> entry in labels.entries) {
      expect(entry.value, isA<String>());
      expect(
        entry.value,
        isNotEmpty,
        reason: "labels.\${entry.key} was published as an empty string",
      );
    }

    for (final Map<String, dynamic> budget
        in (payload["budgets"] as List).cast<Map<String, dynamic>>()) {
      for (final String key in const ["daysLeftLabel", "statusLabel"]) {
        if (budget.containsKey(key)) expect(budget[key], isNotEmpty);
      }
    }

    // Only keys the contract documents may appear.
    expect(
      labels.keys,
      everyElement(
        isIn(const [
          "title",
          "empty",
          "onTrack",
          "over",
          "nearing",
          "tracked",
          "missingBudget",
        ]),
      ),
    );
  });
}

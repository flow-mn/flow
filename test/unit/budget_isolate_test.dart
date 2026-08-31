import "dart:io";

import "package:flow/data/budget_progress.dart";
import "package:flow/data/budget_spec.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/budget.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/services/budget.dart";
import "package:flutter_test/flutter_test.dart";
import "package:moment_dart/moment_dart.dart";
import "package:path/path.dart" as path;
import "package:uuid/uuid.dart";

import "../objectbox_erase.dart";

/// Exercises `BudgetService.computeAllProgressAsync` against a real spawned
/// isolate.
///
/// Static analysis cannot catch what breaks here. Statics are per-isolate, so
/// every singleton the scan reaches — `ObjectBox`, `CategoriesService`,
/// `CurrencyRegistryService` — starts uninitialized in the spawned isolate.
///
/// The failure mode is nasty: a runtime throw inside the isolate is caught and
/// degraded to the synchronous fallback, which produces *identical numbers*.
/// So the correctness tests below cannot, on their own, tell you the isolate
/// ever ran. That's what "the isolate really runs" is for — it calls
/// [computeBudgetSpends] through [Isolate.run] directly, with no fallback to
/// hide behind. If the singleton chain breaks, that test fails loudly while the
/// others keep passing.
void main() {
  late ObjectBox obx;

  final String directory = path.join(
    Directory.current.path,
    ".objectbox_test_budget_isolate",
  );

  final MonthTimeRange thisMonth = MonthTimeRange.fromDateTime(DateTime.now());

  /// A moment safely inside the current month, whatever day the suite runs.
  final DateTime insideThisMonth = thisMonth.from.add(const Duration(hours: 1));

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    obx = await ObjectBox.initialize(
      customDirectory: directory,
      subdirectory: "budget_isolate",
    );
  });

  tearDownAll(() async {
    await testCleanupObject(
      instance: obx,
      directory: path.join(directory, "budget_isolate"),
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

  Category makeCategory(String name) {
    final Category category = Category(name: name, iconCode: "");
    obx.box<Category>().put(category);
    return category;
  }

  void spend(
    Account account,
    double amount, {
    Category? category,
    String currency = "USD",
    DateTime? on,
  }) {
    final Transaction transaction = Transaction(
      amount: -amount.abs(),
      currency: currency,
      uuid: const Uuid().v4(),
      transactionDate: on ?? insideThisMonth,
    );
    transaction.account.target = account;
    transaction.category.target = category;
    obx.box<Transaction>().put(transaction);
  }

  Budget makeBudget({
    required String name,
    double amount = 100.0,
    String currency = "USD",
    List<Category> categories = const [],
  }) {
    final Budget budget = Budget(
      name: name,
      amount: amount,
      currency: currency,
      range: thisMonth.toString(),
    )..setCategories(categories);
    obx.box<Budget>().put(budget);
    return budget;
  }

  BudgetProgress forName(List<BudgetProgress> progresses, String name) =>
      progresses.firstWhere((progress) => progress.budget.name == name);

  test("an uncategorized budget sums every expense in the period", () async {
    final Account account = makeAccount();
    spend(account, 30.0);
    spend(account, 12.5);

    makeBudget(name: "Everything");

    final List<BudgetProgress> progresses = await BudgetService()
        .computeAllProgressAsync();

    expect(progresses.length, 1);
    expect(
      forName(progresses, "Everything").spent.amount,
      moreOrLessEquals(42.5),
    );
  });

  test("a categorized budget only counts its own categories", () async {
    final Account account = makeAccount();
    final Category groceries = makeCategory("Groceries");
    final Category transport = makeCategory("Transport");

    spend(account, 40.0, category: groceries);
    spend(account, 25.0, category: transport);
    spend(account, 10.0);

    makeBudget(name: "Groceries", categories: [groceries]);

    final List<BudgetProgress> progresses = await BudgetService()
        .computeAllProgressAsync();

    // 40, not 75 and not 85 — this is the assertion that proves the isolate
    // resolved the category relation through CategoriesService.
    expect(
      forName(progresses, "Groceries").spent.amount,
      moreOrLessEquals(40.0),
    );
  });

  test("spend outside the period is excluded", () async {
    final Account account = makeAccount();

    spend(account, 50.0);
    spend(
      account,
      999.0,
      on: thisMonth.last.from.add(const Duration(hours: 1)),
    );

    makeBudget(name: "This month");

    final List<BudgetProgress> progresses = await BudgetService()
        .computeAllProgressAsync();

    expect(
      forName(progresses, "This month").spent.amount,
      moreOrLessEquals(50.0),
    );
  });

  test("pending transactions count, and stay separable", () async {
    final Account account = makeAccount();
    spend(account, 20.0);

    final Transaction pending = Transaction(
      amount: -500.0,
      currency: "USD",
      uuid: const Uuid().v4(),
      transactionDate: insideThisMonth,
      isPending: true,
    );
    pending.account.target = account;
    obx.box<Transaction>().put(pending);

    makeBudget(name: "Everything");

    final List<BudgetProgress> progresses = await BudgetService()
        .computeAllProgressAsync();

    final BudgetProgress progress = forName(progresses, "Everything");

    // Scheduled spending is spending the period is already committed to, so it
    // counts against the limit...
    expect(progress.spent.amount, moreOrLessEquals(520.0));
    expect(progress.pendingSpent.amount, moreOrLessEquals(500.0));
    // ...while staying recoverable, so the bar can draw it as a ghost tail
    // rather than as money that has already gone.
    expect(progress.confirmedSpent.amount, moreOrLessEquals(20.0));
  });

  test("a budget with nothing pending reports none", () async {
    final Account account = makeAccount();
    spend(account, 20.0);

    makeBudget(name: "Nothing pending");

    final List<BudgetProgress> progresses = await BudgetService()
        .computeAllProgressAsync();

    final BudgetProgress progress = forName(progresses, "Nothing pending");

    expect(progress.spent.amount, moreOrLessEquals(20.0));
    expect(progress.pendingSpent.amount, moreOrLessEquals(0.0));
    expect(progress.hasPending, isFalse);
  });

  test(
    "foreign spend with no rates is flagged rather than silently dropped",
    () async {
      final Account account = makeAccount();
      spend(account, 20.0);
      spend(account, 15.0, currency: "EUR");

      makeBudget(name: "Everything");

      final List<BudgetProgress> progresses = await BudgetService()
          .computeAllProgressAsync();

      final BudgetProgress progress = forName(progresses, "Everything");

      // The EUR spend is unconvertible without rates. It must not be counted as
      // if it were USD, and the undercount must be advertised — this is the path
      // through CurrencyRegistryService inside the isolate.
      expect(progress.spent.amount, moreOrLessEquals(20.0));
      expect(progress.hasMissingData, isTrue);
    },
  );

  test(
    "the isolate agrees with the synchronous path, budget for budget",
    () async {
      final Account account = makeAccount();
      final Category groceries = makeCategory("Groceries");
      final Category transport = makeCategory("Transport");

      for (int i = 1; i <= 12; i++) {
        spend(account, i * 3.0, category: i.isEven ? groceries : transport);
      }

      makeBudget(name: "Everything", amount: 500.0);
      makeBudget(name: "Groceries", amount: 60.0, categories: [groceries]);
      makeBudget(name: "Commute", amount: 40.0, categories: [transport]);

      final DateTime asOf = DateTime.now();

      final List<BudgetProgress> asynchronous = await BudgetService()
          .computeAllProgressAsync(asOf: asOf);
      final List<BudgetProgress> synchronous = BudgetService()
          .computeAllProgress(asOf: asOf);

      expect(asynchronous.length, 3);
      expect(synchronous.length, 3);

      for (final BudgetProgress expected in synchronous) {
        final BudgetProgress actual = forName(
          asynchronous,
          expected.budget.name,
        );

        expect(actual.spent.amount, moreOrLessEquals(expected.spent.amount));
        expect(actual.limit.amount, expected.limit.amount);
        expect(actual.range.toString(), expected.range.toString());
        expect(actual.status, expected.status);
        expect(actual.hasMissingData, expected.hasMissingData);
      }

      // Sorted most-urgent first, same as the synchronous path.
      expect(
        asynchronous.map((progress) => progress.budget.name).toList(),
        synchronous.map((progress) => progress.budget.name).toList(),
      );
    },
  );

  test("no budgets returns empty without spawning anything", () async {
    expect(await BudgetService().computeAllProgressAsync(), isEmpty);
  });

  test("the isolate really runs — no fallback to hide behind", () async {
    final Account account = makeAccount();
    final Category groceries = makeCategory("Groceries");

    spend(account, 40.0, category: groceries);
    spend(account, 25.0);

    // Deliberately bypasses computeAllProgressAsync, whose try/catch would
    // mask an isolate failure as a successful synchronous result. If anything
    // in the chain — Store.fromReference, CategoriesService,
    // CurrencyRegistryService — is not isolate-safe, this throws.
    final BudgetSpendRequest request = BudgetSpendRequest(
      storeReference: ObjectBox().store.reference,
      specs: [
        BudgetSpec(
          correlationId: 1,
          currency: "USD",
          categoryUuids: [groceries.uuid],
          from: thisMonth.from,
          to: thisMonth.to,
        ),
        BudgetSpec(
          correlationId: 2,
          currency: "USD",
          categoryUuids: const [],
          from: thisMonth.from,
          to: thisMonth.to,
        ),
      ],
      rates: null,
    );

    final List<BudgetSpend> spends = await runBudgetSpendsInIsolate(request);

    expect(spends.length, 2);
    expect(
      spends.firstWhere((spend) => spend.correlationId == 1).spent,
      moreOrLessEquals(40.0),
    );
    expect(
      spends.firstWhere((spend) => spend.correlationId == 2).spent,
      moreOrLessEquals(65.0),
    );
  });
}

import "dart:io";

import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as path;

import "objectbox_erase.dart";

/// Tier-1 behavioral suggestion tests for [MainActions.suggestCategoryForTitle].
///
/// Builds a small history of past transactions and asserts that the
/// deterministic majority-vote (with 30-day recency half-life) produces the
/// expected category — or no suggestion when the signal isn't strong enough.
void main() {
  final Directory testDir = Directory(
    path.join(Directory.current.path, ".objectbox_test_category_suggest"),
  );

  late int accountId;
  late int coffeeId;
  late int groceriesId;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    await ObjectBox.initialize(
      customDirectory: testDir.path,
      subdirectory: "main",
    );

    accountId = await ObjectBox().box<Account>().putAsync(
      Account(
        name: "Test Account",
        currency: "MNT",
        iconCode: "@@@@@irrelevant@@@@@",
      ),
    );

    final List<int> categoryIds = await ObjectBox().box<Category>().putManyAsync([
      Category(name: "Coffee", iconCode: "@@@@@irrelevant@@@@@"),
      Category(name: "Groceries", iconCode: "@@@@@irrelevant@@@@@"),
    ]);
    coffeeId = categoryIds[0];
    groceriesId = categoryIds[1];
  });

  tearDownAll(() async {
    await testCleanupObject(
      instance: ObjectBox(),
      directory: ObjectBox.appDataDirectory,
      cleanUp: true,
    );
  });

  tearDown(() async {
    // Clear transactions between cases so signals don't bleed across tests.
    await ObjectBox().box<Transaction>().removeAllAsync();
  });

  void seed({
    required String title,
    required int categoryId,
    required int daysAgo,
    double amount = -5000,
  }) {
    final Account account = ObjectBox().box<Account>().get(accountId)!;
    final Category category = ObjectBox().box<Category>().get(categoryId)!;
    account.createAndSaveTransaction(
      amount: amount,
      title: title,
      category: category,
      transactionDate: DateTime.now().subtract(Duration(days: daysAgo)),
    );
  }

  test("majority vote returns dominant category", () async {
    for (int i = 0; i < 5; i++) {
      seed(title: "Coffee Lab", categoryId: coffeeId, daysAgo: i * 3);
    }

    final SuggestedCategory? result = await ObjectBox()
        .suggestCategoryForTitle(
          title: "Coffee Lab",
          type: TransactionType.expense,
        );

    expect(result, isNotNull);
    expect(result!.category.id, equals(coffeeId));
    expect(result.matchCount, equals(5));
    expect(result.confidence, equals(1.0));
  });

  test("returns null when below minOccurrences", () async {
    seed(title: "Coffee Lab", categoryId: coffeeId, daysAgo: 1);

    final SuggestedCategory? result = await ObjectBox()
        .suggestCategoryForTitle(
          title: "Coffee Lab",
          type: TransactionType.expense,
        );

    expect(result, isNull);
  });

  test("returns null when confidence is below threshold", () async {
    // 3 coffee vs 3 groceries with the same title — 50/50 split, no winner.
    for (int i = 0; i < 3; i++) {
      seed(title: "Mixed Place", categoryId: coffeeId, daysAgo: i + 1);
      seed(title: "Mixed Place", categoryId: groceriesId, daysAgo: i + 1);
    }

    final SuggestedCategory? result = await ObjectBox()
        .suggestCategoryForTitle(
          title: "Mixed Place",
          type: TransactionType.expense,
        );

    expect(result, isNull);
  });

  test("recency flips the decision when habits shifted recently", () async {
    // Old behavior: 4 transactions ~6 months ago categorized as groceries.
    for (int i = 0; i < 4; i++) {
      seed(title: "Corner Shop", categoryId: groceriesId, daysAgo: 180 + i);
    }
    // Recent behavior: 3 transactions in the last week categorized as coffee.
    for (int i = 0; i < 3; i++) {
      seed(title: "Corner Shop", categoryId: coffeeId, daysAgo: i);
    }

    final SuggestedCategory? result = await ObjectBox()
        .suggestCategoryForTitle(
          title: "Corner Shop",
          type: TransactionType.expense,
        );

    expect(result, isNotNull);
    expect(
      result!.category.id,
      equals(coffeeId),
      reason:
          "30-day half-life should make 3 recent transactions outweigh 4 old ones",
    );
  });

  test("returns null when title has no history", () async {
    seed(title: "Coffee Lab", categoryId: coffeeId, daysAgo: 1);
    seed(title: "Coffee Lab", categoryId: coffeeId, daysAgo: 2);

    final SuggestedCategory? result = await ObjectBox()
        .suggestCategoryForTitle(
          title: "Unknown Store",
          type: TransactionType.expense,
        );

    expect(result, isNull);
  });

  test("title matching is case-insensitive", () async {
    for (int i = 0; i < 3; i++) {
      seed(title: "Coffee Lab", categoryId: coffeeId, daysAgo: i);
    }

    final SuggestedCategory? result = await ObjectBox()
        .suggestCategoryForTitle(
          title: "COFFEE LAB",
          type: TransactionType.expense,
        );

    expect(result, isNotNull);
    expect(result!.category.id, equals(coffeeId));
  });

  test("empty title returns null", () async {
    for (int i = 0; i < 3; i++) {
      seed(title: "Coffee Lab", categoryId: coffeeId, daysAgo: i);
    }

    final SuggestedCategory? blank = await ObjectBox()
        .suggestCategoryForTitle(title: "   ");
    expect(blank, isNull);
  });
}

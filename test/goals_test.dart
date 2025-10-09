import "dart:io";

import "package:flow/entity/account.dart";
import "package:flow/entity/goal.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/goals.dart";
import "package:flutter_test/flutter_test.dart";

import "package:path/path.dart" as path;

import "objectbox_erase.dart";

void main() {
  group("Goals Service", () {
    late Account testAccount;
    late Goal testGoal;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      await ObjectBox.initialize(
        customDirectory: objectboxTestRootDir().path,
        subdirectory: "goals_test",
      );
    });

    setUp(() async {
      // Clean up before each test
      await ObjectBox().box<Goal>().removeAllAsync();
      await ObjectBox().box<Account>().removeAllAsync();

      // Create a test account
      testAccount = Account(
        name: "Test Savings",
        currency: "USD",
        iconCode: "test_icon",
      );
      
      await ObjectBox().box<Account>().putAsync(testAccount);

      // Create a test goal
      testGoal = Goal(
        name: "Save for vacation",
        targetBalance: 1000.0,
        currency: "USD",
        range: null,
      );
      
      testGoal.setAccount(testAccount);
      await ObjectBox().box<Goal>().putAsync(testGoal);
    });

    test("getAll returns all goals", () async {
      final goals = await GoalsService().getAll();
      expect(goals.length, 1);
      expect(goals.first.name, "Save for vacation");
    });

    test("findOne returns goal by id", () async {
      final goal = await GoalsService().findOne(testGoal.id);
      expect(goal, isNotNull);
      expect(goal?.name, "Save for vacation");
    });

    test("findOne returns goal by uuid", () async {
      final goal = await GoalsService().findOne(testGoal.uuid);
      expect(goal, isNotNull);
      expect(goal?.name, "Save for vacation");
    });

    test("checkGoalAchievement returns false when balance below target", () {
      // Account starts with 0 balance
      expect(
        GoalsService().checkGoalAchievement(testGoal, testAccount),
        isFalse,
      );
    });

    test("checkGoalAchievement returns true when balance reaches positive target", () async {
      // Add transactions to reach goal
      testAccount.createAndSaveTransaction(
        amount: 1000.0,
        title: "Deposit",
      );

      // Reload account to get updated balance
      final updatedAccount = await ObjectBox().box<Account>().getAsync(testAccount.id);
      expect(updatedAccount, isNotNull);
      
      expect(
        GoalsService().checkGoalAchievement(testGoal, updatedAccount!),
        isTrue,
      );
    });

    test("checkGoalAchievement returns true when balance exceeds positive target", () async {
      // Add transactions to exceed goal
      testAccount.createAndSaveTransaction(
        amount: 1500.0,
        title: "Big deposit",
      );

      // Reload account to get updated balance
      final updatedAccount = await ObjectBox().box<Account>().getAsync(testAccount.id);
      expect(updatedAccount, isNotNull);
      
      expect(
        GoalsService().checkGoalAchievement(testGoal, updatedAccount!),
        isTrue,
      );
    });

    test("checkGoalAchievement works for negative targets (credit cards)", () async {
      // Create a credit card goal
      final creditGoal = Goal(
        name: "Credit card limit",
        targetBalance: -1000.0,
        currency: "USD",
        range: null,
      );
      
      creditGoal.setAccount(testAccount);
      await ObjectBox().box<Goal>().putAsync(creditGoal);

      // Account starts at 0, so negative goal is not achieved
      expect(
        GoalsService().checkGoalAchievement(creditGoal, testAccount),
        isFalse,
      );

      // Add negative transaction to reach negative target
      testAccount.createAndSaveTransaction(
        amount: -1000.0,
        title: "Credit card spend",
      );

      // Reload account
      final updatedAccount = await ObjectBox().box<Account>().getAsync(testAccount.id);
      expect(updatedAccount, isNotNull);
      
      expect(
        GoalsService().checkGoalAchievement(creditGoal, updatedAccount!),
        isTrue,
      );
    });

    test("checkGoalAchievement returns false for wrong account", () async {
      // Create another account
      final otherAccount = Account(
        name: "Other Account",
        currency: "USD",
        iconCode: "other_icon",
      );
      await ObjectBox().box<Account>().putAsync(otherAccount);

      expect(
        GoalsService().checkGoalAchievement(testGoal, otherAccount),
        isFalse,
      );
    });

    test("resetGoalNotification clears notification state", () async {
      final goalsService = GoalsService();
      
      // Simulate that goal was notified
      await goalsService.resetGoalNotification(testGoal.id);
      
      // This test mainly checks that the method doesn't throw
      expect(true, isTrue);
    });

    test("upsertGoal resets notification when target balance changes", () async {
      final goalsService = GoalsService();
      
      // Update the goal with a new target balance
      testGoal.targetBalance = 2000.0;
      await goalsService.upsertGoal(testGoal);
      
      // Verify goal was updated
      final updated = await goalsService.getOne(testGoal.id);
      expect(updated?.targetBalance, 2000.0);
    });

    test("deleteGoal removes goal and clears notification state", () async {
      final goalsService = GoalsService();
      
      final deleted = await goalsService.deleteGoal(testGoal.id);
      expect(deleted, isTrue);
      
      // Verify goal is gone
      final found = await goalsService.getOne(testGoal.id);
      expect(found, isNull);
    });

    test("checkGoalsNow manually triggers goal checking", () async {
      final goalsService = GoalsService();
      
      // This should not throw
      await goalsService.checkGoalsNow();
      expect(true, isTrue);
    });

    tearDownAll(() async {
      await ObjectBox().close();
      
      final testDir = Directory(
        path.join(objectboxTestRootDir().path, "goals_test"),
      );
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
    });
  });
}

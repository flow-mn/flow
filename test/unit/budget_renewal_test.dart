import "dart:io";

import "package:flow/entity/budget.dart";
import "package:flow/objectbox.dart";
import "package:flow/services/budget.dart";
import "package:flutter_test/flutter_test.dart";
import "package:moment_dart/moment_dart.dart";
import "package:path/path.dart" as path;

import "../objectbox_erase.dart";

/// Exercises `BudgetService.renewDueBudgets`: expired auto-renewing budgets
/// must advance in place to the period containing "now" (catching up over
/// multiple missed periods), while opted-out, custom-range, and current
/// budgets stay untouched.
void main() {
  late ObjectBox obx;

  final String directory = path.join(
    Directory.current.path,
    ".objectbox_test_budget_renewal",
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    obx = await ObjectBox.initialize(
      customDirectory: directory,
      subdirectory: "budget_renewal",
    );
  });

  tearDownAll(() async {
    await testCleanupObject(
      instance: obx,
      directory: path.join(directory, "budget_renewal"),
    );
  });

  Budget put(Budget budget) {
    obx.box<Budget>().put(budget);
    return budget;
  }

  String rangeOf(Budget budget) => obx.box<Budget>().get(budget.id)!.range;

  test("expired budgets advance to the current period", () async {
    final MonthTimeRange currentMonth = MonthTimeRange.fromDateTime(
      DateTime.now(),
    );

    final Budget lastMonth = put(
      Budget(
        name: "Last month",
        amount: 100.0,
        currency: "USD",
        range: currentMonth.last.toString(),
      ),
    );

    // Catch-up isn't one step: several missed periods must fast-forward
    // to the current one.
    final Budget manyMonthsAgo = put(
      Budget(
        name: "Many months ago",
        amount: 100.0,
        currency: "USD",
        range: currentMonth.last.last.last.last.toString(),
      ),
    );

    final int renewedCount = await BudgetService().renewDueBudgets();

    expect(renewedCount, 2);
    expect(rangeOf(lastMonth), currentMonth.toString());
    expect(rangeOf(manyMonthsAgo), currentMonth.toString());
  });

  test("opted-out, custom-range, and current budgets stay untouched", () async {
    final MonthTimeRange currentMonth = MonthTimeRange.fromDateTime(
      DateTime.now(),
    );

    final Budget optedOut = put(
      Budget(
        name: "Opted out",
        amount: 100.0,
        currency: "USD",
        range: currentMonth.last.toString(),
        renewAutomatically: false,
      ),
    );

    final Budget customRange = put(
      Budget(
        name: "Custom range",
        amount: 100.0,
        currency: "USD",
        range: CustomTimeRange(
          DateTime(2020, 1, 1),
          DateTime(2020, 3, 1),
        ).toString(),
      ),
    );

    final Budget current = put(
      Budget(
        name: "Current",
        amount: 100.0,
        currency: "USD",
        range: currentMonth.toString(),
      ),
    );

    final int renewedCount = await BudgetService().renewDueBudgets();

    expect(renewedCount, 0);
    expect(rangeOf(optedOut), currentMonth.last.toString());
    expect(
      rangeOf(customRange),
      CustomTimeRange(DateTime(2020, 1, 1), DateTime(2020, 3, 1)).toString(),
    );
    expect(rangeOf(current), currentMonth.toString());
  });
}

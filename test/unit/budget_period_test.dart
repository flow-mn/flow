import "dart:io";

import "package:flow/data/budget_progress.dart";
import "package:flow/entity/budget.dart";
import "package:flow/objectbox.dart";
import "package:flow/services/budget.dart";
import "package:flutter_test/flutter_test.dart";
import "package:moment_dart/moment_dart.dart";
import "package:path/path.dart" as path;

import "../objectbox_erase.dart";

/// Exercises `BudgetService.currentPeriod`, which derives the period a budget
/// is tracking from its stored anchor and the current moment.
///
/// The load-bearing property is that **nothing is written**: a budget whose
/// period rolled over months ago reports the right period today, and its
/// anchor in the database is byte-for-byte what it always was. That's what
/// makes past periods recoverable — the anchor still points at the series, so
/// any period can be paged back to.
void main() {
  late ObjectBox obx;

  final String directory = path.join(
    Directory.current.path,
    ".objectbox_test_budget_period",
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    obx = await ObjectBox.initialize(
      customDirectory: directory,
      subdirectory: "budget_period",
    );
  });

  tearDownAll(() async {
    await testCleanupObject(
      instance: obx,
      directory: path.join(directory, "budget_period"),
    );
  });

  setUp(() => obx.box<Budget>().removeAll());

  Budget put(Budget budget) {
    obx.box<Budget>().put(budget);
    return budget;
  }

  /// The anchor as it is persisted, not as the in-memory object reports it.
  String storedAnchorOf(Budget budget) =>
      obx.box<Budget>().get(budget.id)!.range;

  final MonthTimeRange thisMonth = MonthTimeRange.fromDateTime(DateTime.now());

  group("currentPeriod derives without writing", () {
    test("an anchor one period behind resolves to the current period", () {
      final Budget budget = put(
        Budget(
          name: "Last month",
          amount: 100.0,
          currency: "USD",
          range: thisMonth.last.toString(),
        ),
      );

      expect(
        BudgetService().currentPeriod(budget).toString(),
        thisMonth.toString(),
      );
      expect(storedAnchorOf(budget), thisMonth.last.toString());
    });

    test("catch-up spans many missed periods in one go", () {
      final MonthTimeRange fourMonthsAgo = thisMonth.last.last.last.last;

      final Budget budget = put(
        Budget(
          name: "Many months ago",
          amount: 100.0,
          currency: "USD",
          range: fourMonthsAgo.toString(),
        ),
      );

      expect(
        BudgetService().currentPeriod(budget).toString(),
        thisMonth.toString(),
      );
      expect(storedAnchorOf(budget), fourMonthsAgo.toString());
    });

    test("an anchor set in the future has not started yet", () {
      final MonthTimeRange nextMonth = thisMonth.next;

      final Budget budget = put(
        Budget(
          name: "Next month",
          amount: 100.0,
          currency: "USD",
          range: nextMonth.toString(),
        ),
      );

      // Deliberately scheduled for next month. Paging backward to "now" would
      // silently start it early and count spending it was never meant to cover.
      expect(
        BudgetService().currentPeriod(budget).toString(),
        nextMonth.toString(),
      );

      // An explicit [asOf] is a historical lookup and still pages back — that
      // is what the history strip is built on.
      expect(
        BudgetService().currentPeriod(budget, asOf: thisMonth.from).toString(),
        thisMonth.toString(),
      );

      expect(storedAnchorOf(budget), nextMonth.toString());
    });

    test("an anchor already containing now is returned unchanged", () {
      final Budget budget = put(
        Budget(
          name: "Current",
          amount: 100.0,
          currency: "USD",
          range: thisMonth.toString(),
        ),
      );

      expect(
        BudgetService().currentPeriod(budget).toString(),
        thisMonth.toString(),
      );
    });

    test("a yearly budget derives its year, not a month", () {
      final YearTimeRange thisYear = YearTimeRange.fromDateTime(DateTime.now());

      final Budget budget = put(
        Budget(
          name: "Travel",
          amount: 5000.0,
          currency: "USD",
          range: thisYear.last.last.toString(),
        ),
      );

      expect(
        BudgetService().currentPeriod(budget).toString(),
        thisYear.toString(),
      );
    });
  });

  group("one-off budgets stay on their anchor", () {
    test("renewAutomatically: false never advances", () {
      final Budget budget = put(
        Budget(
          name: "Opted out",
          amount: 100.0,
          currency: "USD",
          range: thisMonth.last.toString(),
          renewAutomatically: false,
        ),
      );

      expect(
        BudgetService().currentPeriod(budget).toString(),
        thisMonth.last.toString(),
      );
    });

    test("a custom (non-pageable) range never advances", () {
      final CustomTimeRange holiday = CustomTimeRange(
        DateTime(2020, 1, 1),
        DateTime(2020, 3, 1),
      );

      final Budget budget = put(
        Budget(
          name: "Holiday",
          amount: 100.0,
          currency: "USD",
          range: holiday.toString(),
        ),
      );

      expect(
        BudgetService().currentPeriod(budget).toString(),
        holiday.toString(),
      );
    });
  });

  group("history is recoverable", () {
    test("a past period is just currentPeriod at an earlier moment", () {
      final Budget budget = put(
        Budget(
          name: "Groceries",
          amount: 100.0,
          currency: "USD",
          range: thisMonth.toString(),
        ),
      );

      final MonthTimeRange twoMonthsAgo = thisMonth.last.last;

      expect(
        BudgetService()
            .currentPeriod(budget, asOf: twoMonthsAgo.from)
            .toString(),
        twoMonthsAgo.toString(),
      );
    });

    test("computeHistory returns N periods, oldest first, ending at now", () {
      final Budget budget = put(
        Budget(
          name: "Groceries",
          amount: 100.0,
          currency: "USD",
          range: thisMonth.toString(),
          // History is clamped to the budget's creation, so a budget that has
          // genuinely existed for three periods is what this asserts about.
          createdDate: thisMonth.last.last.from,
        ),
      );

      final List<BudgetProgress> history = BudgetService().computeHistory(
        budget,
        count: 3,
      );

      expect(history.length, 3);
      expect(history.map((progress) => progress.range.toString()).toList(), [
        thisMonth.last.last.toString(),
        thisMonth.last.toString(),
        thisMonth.toString(),
      ]);
      expect(history.last.isCurrent, isTrue);
      expect(history.first.isCurrent, isFalse);
    });

    test("history never predates the budget's creation", () {
      final Budget budget = put(
        Budget(
          name: "Just created",
          amount: 100.0,
          currency: "USD",
          range: thisMonth.toString(),
        ),
      );

      // The categories this budget watches have spend going back years. None
      // of it is *this budget's* history — it did not exist to be exceeded.
      final List<TimeRange> periods = BudgetService().historyPeriods(
        budget,
        count: 6,
      );

      expect(periods.length, 1);
      expect(periods.single.toString(), thisMonth.toString());
    });

    test("history is clamped to the periods the budget actually spans", () {
      final Budget budget = put(
        Budget(
          name: "Two months old",
          amount: 100.0,
          currency: "USD",
          range: thisMonth.toString(),
          createdDate: thisMonth.last.from,
        ),
      );

      final List<TimeRange> periods = BudgetService().historyPeriods(
        budget,
        count: 6,
      );

      expect(periods.map((period) => period.toString()).toList(), [
        thisMonth.last.toString(),
        thisMonth.toString(),
      ]);
    });

    test("a one-off budget has exactly one period of history", () {
      final Budget budget = put(
        Budget(
          name: "Opted out",
          amount: 100.0,
          currency: "USD",
          range: thisMonth.toString(),
          renewAutomatically: false,
        ),
      );

      expect(BudgetService().computeHistory(budget, count: 6).length, 1);
    });
  });
}

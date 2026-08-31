import "package:flow/data/budget_progress.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/budget.dart";
import "package:flow/services/budget.dart";
import "package:flutter_test/flutter_test.dart";
import "package:moment_dart/moment_dart.dart";

/// Pure math over [BudgetProgress] — no database, no widgets.
///
/// These rules are not internal bookkeeping: [BudgetProgress.primaryInsight]
/// picks which sentence the user reads on the overview, and [severity] decides
/// which budget the bento tile and the alert notification single out. A wrong
/// threshold here is a wrong sentence in the UI, silently.
void main() {
  /// June 2026 — a 30-day month, so "half elapsed" is easy to reason about.
  final MonthTimeRange june = MonthTimeRange(2026, 6);

  Budget budgetOf({double amount = 100.0, bool renewAutomatically = true}) =>
      Budget(
        name: "Groceries",
        amount: amount,
        currency: "USD",
        range: june.toString(),
        renewAutomatically: renewAutomatically,
      );

  BudgetProgress progressOf({
    required double spent,
    double pending = 0.0,
    double limit = 100.0,
    DateTime? asOf,
    TimeRange? range,
    bool hasMissingData = false,
  }) => BudgetProgress(
    budget: budgetOf(amount: limit),
    range: range ?? june,
    spent: Money(spent, "USD"),
    pendingSpent: Money(pending, "USD"),
    limit: Money(limit, "USD"),
    asOf: asOf ?? DateTime(2026, 6, 21),
    hasMissingData: hasMissingData,
  );

  group("ratio and remainder", () {
    test("ratio and percent track spend against the limit", () {
      final BudgetProgress p = progressOf(spent: 84.0);

      expect(p.ratio, moreOrLessEquals(0.84));
      expect(p.percent, 84);
    });

    test(
      "a non-positive limit reads as ratio 0 rather than dividing by it",
      () {
        expect(progressOf(spent: 50.0, limit: 0.0).ratio, 0.0);
        expect(
          progressOf(spent: 50.0, limit: 0.0).status,
          BudgetStatus.healthy,
        );
      },
    );

    test("remaining goes negative once over; overBy clamps at zero", () {
      final BudgetProgress under = progressOf(spent: 84.0);
      expect(under.remaining.amount, moreOrLessEquals(16.0));
      expect(under.overBy.amount, 0.0);

      final BudgetProgress over = progressOf(spent: 120.0);
      expect(over.remaining.amount, moreOrLessEquals(-20.0));
      expect(over.overBy.amount, moreOrLessEquals(20.0));
    });
  });

  group("the pending split", () {
    test("pending is part of spent, not something added to it", () {
      final BudgetProgress p = progressOf(spent: 60.0, pending: 25.0);

      expect(p.spent.amount, moreOrLessEquals(60.0));
      expect(p.confirmedSpent.amount, moreOrLessEquals(35.0));
      expect(p.ratio, moreOrLessEquals(0.6));
      expect(p.confirmedRatio, moreOrLessEquals(0.35));
    });

    test("a scheduled payment can be what tips a budget over", () {
      // The whole point of counting pending: 80 spent with 30 more already
      // committed is not a healthy budget, however little has cleared.
      final BudgetProgress p = progressOf(spent: 110.0, pending: 30.0);

      expect(p.status, BudgetStatus.over);
      expect(p.primaryInsight, BudgetInsightType.over);
      expect(p.confirmedSpent.amount, moreOrLessEquals(80.0));
    });

    test("no pending leaves the confirmed figures identical to spent", () {
      final BudgetProgress p = progressOf(spent: 84.0);

      expect(p.hasPending, isFalse);
      expect(p.confirmedSpent.amount, moreOrLessEquals(p.spent.amount));
      expect(p.confirmedRatio, moreOrLessEquals(p.ratio));
    });

    test("an all-pending budget has nothing confirmed to draw", () {
      final BudgetProgress p = progressOf(spent: 40.0, pending: 40.0);

      expect(p.hasPending, isTrue);
      expect(p.confirmedSpent.amount, moreOrLessEquals(0.0));
      expect(p.confirmedRatio, moreOrLessEquals(0.0));
    });

    test("a scheduled lump sum is not extrapolated as a run rate", () {
      // 2 of 30 days elapsed, nothing actually spent, one 30.0 payment already
      // scheduled for later in the month. Running that through the rate would
      // project a 4.5x overshoot and cry "overpacing" about a healthy budget.
      final BudgetProgress p = progressOf(
        spent: 30.0,
        pending: 30.0,
        asOf: DateTime(2026, 6, 3),
      );

      expect(p.projectedRatio, moreOrLessEquals(0.3));
      expect(p.pace, BudgetPace.under);
      expect(p.primaryInsight, isNot(BudgetInsightType.overpacing));
    });

    test("confirmed spend is still extrapolated normally", () {
      // Same period position, but the 30.0 actually cleared — two days in and
      // already 30% down really is on course to overshoot.
      final BudgetProgress p = progressOf(
        spent: 30.0,
        asOf: DateTime(2026, 6, 3),
      );

      expect(p.projectedRatio, greaterThan(1.0));
      expect(p.pace, BudgetPace.over);
    });

    test("a non-positive limit zeroes confirmedRatio too, not just ratio", () {
      final BudgetProgress p = progressOf(
        spent: 50.0,
        pending: 20.0,
        limit: 0.0,
      );

      expect(p.ratio, 0.0);
      expect(p.confirmedRatio, 0.0);
    });
  });

  group("status thresholds", () {
    test("healthy below the warning threshold", () {
      expect(progressOf(spent: 89.0).status, BudgetStatus.healthy);
    });

    test("warning at exactly the threshold, not just past it", () {
      expect(progressOf(spent: 90.0).status, BudgetStatus.warning);
      expect(progressOf(spent: 99.99).status, BudgetStatus.warning);
    });

    test("over at exactly the limit, not just past it", () {
      expect(progressOf(spent: 100.0).status, BudgetStatus.over);
      expect(progressOf(spent: 100.01).status, BudgetStatus.over);
    });
  });

  group("period position", () {
    test("periodElapsed clamps outside the range", () {
      expect(
        progressOf(spent: 0.0, asOf: DateTime(2026, 5, 1)).periodElapsed,
        0.0,
      );
      expect(
        progressOf(spent: 0.0, asOf: DateTime(2026, 7, 15)).periodElapsed,
        1.0,
      );
    });

    test("periodElapsed is about half at mid-month", () {
      expect(
        progressOf(spent: 0.0, asOf: DateTime(2026, 6, 16)).periodElapsed,
        closeTo(0.5, 0.01),
      );
    });

    test("daysLeft counts whole days and floors at zero", () {
      expect(progressOf(spent: 0.0, asOf: DateTime(2026, 6, 21)).daysLeft, 9);
      expect(progressOf(spent: 0.0, asOf: DateTime(2026, 7, 5)).daysLeft, 0);
    });

    test("isCurrent is false for a period that has ended", () {
      final BudgetProgress past = progressOf(
        spent: 200.0,
        asOf: DateTime(2026, 8, 1),
      );

      expect(past.isCurrent, isFalse);
      // Over budget, but months ago — it must not nag.
      expect(past.status, BudgetStatus.over);
      expect(past.needsAttention, isFalse);
    });
  });

  group("pace", () {
    // At 2026-06-21 roughly two thirds of June has elapsed.
    test("spending in line with the period reads as on pace", () {
      expect(progressOf(spent: 55.0).pace, BudgetPace.on);
    });

    test("spending ahead of the period reads as over pace", () {
      expect(progressOf(spent: 80.0).pace, BudgetPace.over);
    });

    test("spending behind the period reads as under pace", () {
      expect(progressOf(spent: 30.0).pace, BudgetPace.under);
    });

    test("projectedRatio falls back to ratio before the period starts", () {
      final BudgetProgress p = progressOf(
        spent: 40.0,
        asOf: DateTime(2026, 5, 1),
      );

      expect(p.periodElapsed, 0.0);
      expect(p.projectedRatio, moreOrLessEquals(p.ratio));
    });
  });

  group("primaryInsight", () {
    test("over budget outranks everything", () {
      expect(progressOf(spent: 130.0).primaryInsight, BudgetInsightType.over);
    });

    test("nearing the limit outranks pace", () {
      expect(
        progressOf(spent: 92.0).primaryInsight,
        BudgetInsightType.nearingLimit,
      );
    });

    test("healthy but pacing hot reads as overpacing", () {
      expect(
        progressOf(spent: 80.0).primaryInsight,
        BudgetInsightType.overpacing,
      );
    });

    test("an early burst does not project an alarming overrun", () {
      // 2 days into June, 20% spent — extrapolates to 3x the limit, which is
      // noise, not a signal. The <20%-elapsed guard must suppress it.
      final BudgetProgress p = progressOf(
        spent: 20.0,
        asOf: DateTime(2026, 6, 3),
      );

      expect(p.pace, BudgetPace.over);
      expect(p.primaryInsight, BudgetInsightType.onTrack);
    });

    test("well under with most of the period gone reads as underspending", () {
      expect(
        progressOf(spent: 30.0).primaryInsight,
        BudgetInsightType.underspending,
      );
    });

    test("comfortably in line reads as on track", () {
      expect(progressOf(spent: 55.0).primaryInsight, BudgetInsightType.onTrack);
    });
  });

  group("severity ordering", () {
    test("over outranks warning outranks healthy, ties break by ratio", () {
      final BudgetProgress over = progressOf(spent: 101.0);
      final BudgetProgress worseOver = progressOf(spent: 150.0);
      final BudgetProgress warning = progressOf(spent: 95.0);
      final BudgetProgress healthy = progressOf(spent: 10.0);

      final List<BudgetProgress> sorted = [healthy, over, warning, worseOver]
        ..sort((a, b) => b.severity.compareTo(a.severity));

      expect(sorted, [worseOver, over, warning, healthy]);
    });
  });

  group("computeSummary", () {
    test("counts statuses and singles out the worst", () {
      final BudgetProgress over = progressOf(spent: 110.0);
      final BudgetProgress warning = progressOf(spent: 95.0);
      final BudgetProgress healthy = progressOf(spent: 20.0);

      final BudgetsSummary summary = BudgetService().computeSummary([
        healthy,
        warning,
        over,
      ]);

      expect(summary.budgetCount, 3);
      expect(summary.overCount, 1);
      expect(summary.warningCount, 1);
      expect(summary.worst, same(over));
      expect(summary.allHealthy, isFalse);
      expect(summary.isEmpty, isFalse);
    });

    test("all healthy is reported as such", () {
      final BudgetsSummary summary = BudgetService().computeSummary([
        progressOf(spent: 10.0),
        progressOf(spent: 20.0),
      ]);

      expect(summary.allHealthy, isTrue);
      expect(summary.hasMissingData, isFalse);
    });

    test("one budget with unconvertible spend flags the whole summary", () {
      final BudgetsSummary summary = BudgetService().computeSummary([
        progressOf(spent: 10.0),
        progressOf(spent: 20.0, hasMissingData: true),
      ]);

      expect(summary.hasMissingData, isTrue);
    });

    test("no budgets is empty, with no worst", () {
      final BudgetsSummary summary = BudgetService().computeSummary([]);

      expect(summary.isEmpty, isTrue);
      expect(summary.worst, isNull);
      expect(summary.allHealthy, isTrue);
    });
  });
}

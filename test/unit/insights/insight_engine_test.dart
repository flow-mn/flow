import "dart:math" as math;

import "package:flow/data/insights/insight_engine.dart";
import "package:flutter/foundation.dart";
import "package:flutter_test/flutter_test.dart";

import "insight_test_data.dart";

/// Closed-month scenarios analyze August 2026 as seen from late September.
final DateTime august = DateTime(2026, 8);
final DateTime september = DateTime(2026, 9);
final DateTime lateSeptember = DateTime(2026, 9, 25, 18);

/// For suggestions, which only show while their month is in progress.
final DateTime lateAugust = DateTime(2026, 8, 25, 18);

/// Feb..Jul 2026, the baseline of August.
const List<int> augustBaseline = [2, 3, 4, 5, 6, 7];

/// Mar..Aug 2026, the baseline of September.
const List<int> septemberBaseline = [3, 4, 5, 6, 7, 8];

List<T> only<T extends Insight>(InsightReport report) =>
    report.insights.whereType<T>().toList();

void main() {
  group("personas", () {
    test("a steady spender only hears about an untracked subscription", () {
      final math.Random random = math.Random(7);
      final TestLedger ledger = TestLedger();

      for (int month = 1; month <= 8; month++) {
        ledger.steadyMonth(2026, month, random);
      }
      ledger.steadyMonth(2026, 9, random, throughDay: 25);

      final InsightReport closed = ledger.analyze(august, now: lateSeptember);
      expect(closed.status, InsightReportStatus.ready);
      expect(closed.insights, isEmpty);

      final InsightReport report = ledger.analyze(
        september,
        now: lateSeptember,
      );
      expect(report.status, InsightReportStatus.ready);
      expect(report.insights, hasLength(1));

      final RecurringChargeInsight insight =
          report.insights.single as RecurringChargeInsight;
      expect(insight.series.title, "Spotify");
      expect(insight.series.anchorDay, 3);
      expect(insight.series.cadence, RecurringCadence.monthly);
    });

    test("a traveler's flight is named, and the month is fine without it", () {
      final math.Random random = math.Random(3);
      final TestLedger ledger = TestLedger();

      for (int month = 1; month <= 8; month++) {
        ledger.steadyMonth(2026, month, random);
      }
      ledger.steadyMonth(2026, 9, random, throughDay: 25);
      final InsightTransaction flight = ledger.spend(
        DateTime(2026, 9, 12, 8),
        1500.0,
        title: "Flight to Tokyo",
        category: "travel",
      );

      final InsightReport report = ledger.analyze(
        september,
        now: lateSeptember,
      );

      final MonthPaceInsight pace = report.insights.first as MonthPaceInsight;

      expect(pace.direction, InsightDirection.above);
      expect(pace.throughDay, 25);
      expect(pace.ratio, greaterThan(1.7));
      expect(pace.attribution?.transactionUuid, flight.uuid);
      expect(pace.attribution?.title, "Flight to Tokyo");
      expect(pace.ratioWithoutAttribution, lessThan(1.1));
      expect(pace.dominantDriver?.categoryUuid, "travel");
      expect(pace.transactionUuids.first, flight.uuid);
      expect(pace.history, hasLength(6));
      expect(pace.history.first.month, DateTime(2026, 3));

      // "First travel spend" would only repeat the same flight.
      expect(only<NewCategoryInsight>(report), isEmpty);
    });

    test("a freelancer's irregular income changes nothing", () {
      final math.Random random = math.Random(11);
      final TestLedger ledger = TestLedger();

      for (int month = 1; month <= 9; month++) {
        ledger.steadyMonth(2026, month, random, throughDay: 25);
        for (int i = 0; i < random.nextInt(4); i++) {
          ledger.earn(
            DateTime(2026, month, 1 + random.nextInt(25)),
            500.0 + random.nextDouble() * 6000,
            title: "Client ${random.nextInt(5)}",
            category: "freelance",
          );
        }
      }

      final InsightReport report = ledger.analyze(
        september,
        now: lateSeptember,
      );

      expect(report.status, InsightReportStatus.ready);
      expect(
        report.insights.where((insight) => insight is! RecurringChargeInsight),
        isEmpty,
      );
    });

    test("a new user with two months hears nothing", () {
      final math.Random random = math.Random(5);
      final TestLedger ledger = TestLedger();

      ledger.steadyMonth(2026, 7, random);
      ledger.steadyMonth(2026, 8, random);
      ledger.steadyMonth(2026, 9, random, throughDay: 25);
      ledger.spend(DateTime(2026, 9, 12), 5000.0, title: "Laptop");

      final InsightReport report = ledger.analyze(
        september,
        now: lateSeptember,
      );

      expect(report.status, InsightReportStatus.notEnoughHistory);
      expect(report.insights, isEmpty);
      expect(report.usualMonthTotal, isNull);
    });

    test("three good months are enough", () {
      final TestLedger ledger = TestLedger();

      for (final int month in [5, 6, 7]) {
        ledger.flatMonth(2026, month);
      }
      ledger.flatMonth(2026, 8);
      ledger.spend(DateTime(2026, 8, 20), 2000.0);

      expect(
        ledger.analyze(august, now: lateSeptember).status,
        InsightReportStatus.ready,
      );
    });

    test("sparse months don't count toward history", () {
      final TestLedger ledger = TestLedger();

      ledger.flatMonth(2026, 5);
      ledger.flatMonth(2026, 6);
      ledger.flatMonth(2026, 7, count: 9, each: 111.0);
      ledger.flatMonth(2026, 8);

      expect(
        ledger.analyze(august, now: lateSeptember).status,
        InsightReportStatus.notEnoughHistory,
      );
    });

    test("a subscription paid abroad, converted at drifting rates, "
        "isn't a price change", () {
      final TestLedger ledger = TestLedger();

      for (int month = 1; month <= 8; month++) {
        ledger.flatMonth(2026, month, count: 30, each: 30.0);
        final double rate = 1.08 + 0.03 * math.sin(month.toDouble());
        ledger.spend(
          DateTime(2026, month, 15),
          12.99 * rate,
          title: "Netflix",
          category: "subscriptions",
        );
      }

      final InsightReport report = ledger.analyze(august, now: lateAugust);

      expect(only<PriceChangeInsight>(report), isEmpty);
      expect(
        only<RecurringChargeInsight>(report).single.series.isFixedPrice,
        isTrue,
      );
    });
  });

  group("month pace thresholds", () {
    /// 20 × 50 a month: usual 1000, floor max(50, 150) = 150.
    TestLedger smallFloor() {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month, count: 20, each: 50.0);
      }
      return ledger;
    }

    /// 10 × 100 a month: usual 1000, floor max(50, 300) = 300.
    TestLedger bigFloor() {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month);
      }
      return ledger;
    }

    test("just under 1.25× stays quiet", () {
      final TestLedger ledger = smallFloor()
        ..flatMonth(2026, 8, count: 20, each: 50.0)
        ..spend(DateTime(2026, 8, 20), 249.0);

      expect(ledger.analyze(august, now: lateSeptember).insights, isEmpty);
    });

    test("1.25× fires", () {
      final TestLedger ledger = smallFloor()
        ..flatMonth(2026, 8, count: 20, each: 50.0)
        ..spend(DateTime(2026, 8, 20), 250.0);

      final InsightReport report = ledger.analyze(august, now: lateSeptember);
      final MonthPaceInsight pace = only<MonthPaceInsight>(report).single;

      expect(report.usualMonthTotal, 1000.0);
      expect(pace.direction, InsightDirection.above);
      expect(pace.ratio, 1.25);
      expect(pace.stake, 250.0);
      expect(pace.score, 0.25);
      expect(pace.throughDay, isNull);
    });

    test("0.80× fires as below, 0.801× doesn't", () {
      final TestLedger below = smallFloor()
        ..flatMonth(2026, 8, count: 16, each: 50.0);
      final TestLedger almost = smallFloor()
        ..flatMonth(2026, 8, count: 16, each: 50.0)
        ..spend(DateTime(2026, 8, 30), 1.0);

      final MonthPaceInsight pace = only<MonthPaceInsight>(
        below.analyze(august, now: lateSeptember),
      ).single;

      expect(pace.direction, InsightDirection.below);
      expect(pace.attribution, isNull);
      expect(pace.drivers.single.categoryUuid, "misc");
      expect(pace.drivers.single.delta, -200.0);
      expect(almost.analyze(august, now: lateSeptember).insights, isEmpty);
    });

    test("a ratio over 1.25 still needs the absolute floor", () {
      final TestLedger under = bigFloor()
        ..flatMonth(2026, 8)
        ..spend(DateTime(2026, 8, 20), 299.0);
      final TestLedger over = bigFloor()
        ..flatMonth(2026, 8)
        ..spend(DateTime(2026, 8, 20), 300.0);

      expect(under.analyze(august, now: lateSeptember).insights, isEmpty);
      expect(
        only<MonthPaceInsight>(over.analyze(august, now: lateSeptember)),
        hasLength(1),
      );
    });

    test("nothing fires before the 7th", () {
      final TestLedger ledger = TestLedger();
      for (final int month in septemberBaseline) {
        ledger.flatMonth(2026, month);
      }
      ledger.flatMonth(2026, 9, throughDay: 6);
      ledger.spend(DateTime(2026, 9, 2), 2000.0, title: "Sofa");

      final InsightReport early = ledger.analyze(
        september,
        now: DateTime(2026, 9, 6, 23, 59),
      );
      final InsightReport onTime = ledger.analyze(
        september,
        now: DateTime(2026, 9, 7, 0, 1),
      );

      expect(early.status, InsightReportStatus.tooEarly);
      expect(early.insights, isEmpty);
      expect(onTime.status, InsightReportStatus.ready);
      expect(only<MonthPaceInsight>(onTime).single.throughDay, 7);
    });

    test("an in-progress month is compared with the same day before", () {
      final TestLedger ledger = TestLedger();
      for (final int month in septemberBaseline) {
        ledger.flatMonth(2026, month);
      }
      // Days 1, 4, 7, 10, 13 so far: exactly the usual pace.
      ledger.flatMonth(2026, 9, throughDay: 15);

      final InsightReport report = ledger.analyze(
        september,
        now: DateTime(2026, 9, 15, 12),
      );

      expect(report.insights, isEmpty);
      expect(report.throughDay, 15);
      expect(report.isInProgress, isTrue);
    });

    test("a spike explained by one purchase says what it'd be without it", () {
      final TestLedger ledger = bigFloor()..flatMonth(2026, 8);
      final InsightTransaction tv = ledger.spend(
        DateTime(2026, 8, 9),
        900.0,
        title: "TV",
      );

      final MonthPaceInsight pace = only<MonthPaceInsight>(
        ledger.analyze(august, now: lateSeptember),
      ).single;

      expect(pace.attribution?.transactionUuid, tv.uuid);
      expect(pace.attribution?.amount, 900.0);
      expect(pace.currentWithoutAttribution, 1000.0);
      expect(pace.ratioWithoutAttribution, 1.0);
    });

    test("many small increases aren't pinned on one purchase", () {
      final TestLedger ledger = bigFloor()
        ..flatMonth(2026, 8, count: 18, each: 100.0);

      final MonthPaceInsight pace = only<MonthPaceInsight>(
        ledger.analyze(august, now: lateSeptember),
      ).single;

      expect(pace.attribution, isNull);
      expect(pace.ratioWithoutAttribution, isNull);
    });
  });

  group("categories", () {
    /// misc 30 × 30 plus dining [diningEach] × [diningCount] each month.
    TestLedger withDining({int diningCount = 4, double diningEach = 50.0}) {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month, count: 30, each: 30.0);
        ledger.flatMonth(
          2026,
          month,
          count: diningCount,
          each: diningEach,
          category: "dining",
        );
      }
      ledger.flatMonth(2026, 8, count: 30, each: 30.0);
      return ledger;
    }

    test("1.5× the usual fires, just under doesn't", () {
      final TestLedger spiking = withDining()
        ..flatMonth(2026, 8, count: 6, each: 50.0, category: "dining");
      final TestLedger almost = withDining()
        ..flatMonth(2026, 8, count: 5, each: 50.0, category: "dining")
        ..spend(DateTime(2026, 8, 30), 49.0, category: "dining");

      final CategorySpikeInsight spike = only<CategorySpikeInsight>(
        spiking.analyze(august, now: lateSeptember),
      ).single;

      expect(spike.categoryUuid, "dining");
      expect(spike.ratio, 1.5);
      expect(spike.usual, 200.0);
      expect(spike.entryCount, 6);
      expect(spike.history.map((value) => value.amount), everyElement(200.0));
      expect(almost.analyze(august, now: lateSeptember).insights, isEmpty);
    });

    test("the absolute floor applies to categories too", () {
      // Usual month 1000, median expense 30: floor 90.
      final TestLedger under = withDining(diningCount: 2)
        ..flatMonth(2026, 8, count: 2, each: 60.0, category: "dining")
        ..spend(DateTime(2026, 8, 30), 69.0, category: "dining");
      final TestLedger over = withDining(diningCount: 2)
        ..flatMonth(2026, 8, count: 2, each: 60.0, category: "dining")
        ..spend(DateTime(2026, 8, 30), 70.0, category: "dining");

      expect(
        only<CategorySpikeInsight>(under.analyze(august, now: lateSeptember)),
        isEmpty,
      );
      expect(
        only<CategorySpikeInsight>(over.analyze(august, now: lateSeptember)),
        hasLength(1),
      );
    });

    test("fewer than three entries can't spike", () {
      final TestLedger ledger = withDining()
        ..flatMonth(2026, 8, count: 2, each: 250.0, category: "dining");

      expect(
        only<CategorySpikeInsight>(ledger.analyze(august, now: lateSeptember)),
        isEmpty,
      );
    });

    test("a category seen in only two months has no usual", () {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month, count: 30, each: 30.0);
      }
      ledger.flatMonth(2026, 3, count: 3, each: 20.0, category: "gifts");
      ledger.flatMonth(2026, 6, count: 3, each: 20.0, category: "gifts");
      ledger.flatMonth(2026, 8, count: 30, each: 30.0);
      ledger.flatMonth(2026, 8, count: 4, each: 60.0, category: "gifts");

      expect(
        only<CategorySpikeInsight>(ledger.analyze(august, now: lateSeptember)),
        isEmpty,
      );
    });

    test("months without the category don't drag its usual down", () {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month, count: 30, each: 30.0);
      }
      for (final int month in [3, 5, 7]) {
        ledger.flatMonth(2026, month, count: 3, each: 60.0, category: "hobby");
      }
      ledger.flatMonth(2026, 8, count: 30, each: 30.0);
      ledger.flatMonth(2026, 8, count: 3, each: 60.0, category: "hobby");

      expect(ledger.analyze(august, now: lateSeptember).insights, isEmpty);
    });

    test("uncategorized spend never spikes", () {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month, count: 30, each: 30.0);
        for (int i = 0; i < 3; i++) {
          ledger.spend(DateTime(2026, month, 3 + i), 20.0, category: null);
        }
      }
      ledger.flatMonth(2026, 8, count: 30, each: 30.0);
      for (int i = 0; i < 3; i++) {
        ledger.spend(DateTime(2026, 8, 3 + i), 60.0, category: null);
      }

      final InsightReport report = ledger.analyze(august, now: lateSeptember);

      expect(only<CategorySpikeInsight>(report), isEmpty);
      expect(only<NewCategoryInsight>(report), isEmpty);
    });

    test("at most two category spikes, ties broken by key", () {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month, count: 30, each: 30.0);
        for (final String category in ["c", "b", "a"]) {
          ledger.flatMonth(
            2026,
            month,
            count: 3,
            each: 20.0,
            category: category,
          );
        }
      }
      ledger.flatMonth(2026, 8, count: 30, each: 30.0);
      for (final String category in ["c", "b", "a"]) {
        ledger.flatMonth(2026, 8, count: 3, each: 70.0, category: category);
      }

      final InsightReport report = ledger.analyze(
        august,
        now: lateSeptember,
        limit: 10,
      );

      expect(report.insights.map((insight) => insight.key), [
        "monthPace:above",
        "categorySpike:a",
        "categorySpike:b",
      ]);
    });

    group("drops", () {
      /// misc 30 × 20 and groceries 4 × 100: usual 1000, floor 60.
      TestLedger withGroceries() {
        final TestLedger ledger = TestLedger();
        for (final int month in augustBaseline) {
          ledger.flatMonth(2026, month, count: 30, each: 20.0);
          ledger.flatMonth(
            2026,
            month,
            count: 4,
            each: 100.0,
            category: "groceries",
          );
        }
        return ledger;
      }

      test("0.6× of a regular category fires", () {
        final TestLedger ledger = withGroceries()
          ..flatMonth(2026, 8, count: 40, each: 20.0)
          ..flatMonth(2026, 8, count: 2, each: 100.0, category: "groceries")
          ..spend(DateTime(2026, 8, 28), 40.0, category: "groceries");

        final CategoryDropInsight drop = only<CategoryDropInsight>(
          ledger.analyze(august, now: lateSeptember),
        ).single;

        expect(drop.categoryUuid, "groceries");
        expect(drop.ratio, 0.6);
        expect(drop.stake, 160.0);
      });

      test("just above 0.6× doesn't", () {
        final TestLedger ledger = withGroceries()
          ..flatMonth(2026, 8, count: 40, each: 20.0)
          ..flatMonth(2026, 8, count: 2, each: 100.0, category: "groceries")
          ..spend(DateTime(2026, 8, 28), 41.0, category: "groceries");

        expect(
          only<CategoryDropInsight>(ledger.analyze(august, now: lateSeptember)),
          isEmpty,
        );
      });

      test("waits until the 20th in a month in progress", () {
        final TestLedger ledger = TestLedger();
        for (final int month in septemberBaseline) {
          ledger.flatMonth(2026, month, count: 30, each: 20.0);
          ledger.flatMonth(
            2026,
            month,
            count: 4,
            each: 100.0,
            category: "groceries",
          );
        }
        // Twice the usual misc so the month as a whole isn't low.
        ledger.flatMonth(2026, 9, count: 60, each: 20.0, throughDay: 20);

        final InsightReport early = ledger.analyze(
          september,
          now: DateTime(2026, 9, 19, 20),
        );
        final InsightReport late = ledger.analyze(
          september,
          now: DateTime(2026, 9, 20, 20),
        );

        expect(only<CategoryDropInsight>(early), isEmpty);

        final CategoryDropInsight drop = only<CategoryDropInsight>(late).single;
        expect(drop.current, 0.0);
        expect(drop.throughDay, 20);
        // Days 1, 8 and 16 of earlier months, not the full month.
        expect(drop.usual, 300.0);
      });

      test("a small category can't drop", () {
        final TestLedger ledger = TestLedger();
        for (final int month in augustBaseline) {
          ledger.flatMonth(2026, month, count: 30, each: 30.0);
          ledger.flatMonth(2026, month, count: 2, each: 20.0, category: "tea");
        }
        ledger.flatMonth(2026, 8, count: 30, each: 30.0);

        expect(
          only<CategoryDropInsight>(ledger.analyze(august, now: lateSeptember)),
          isEmpty,
        );
      });
    });

    test("spend in a brand-new category above the floor", () {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month, count: 30, each: 30.0);
      }
      ledger.flatMonth(2026, 8, count: 30, each: 30.0);
      ledger.flatMonth(2026, 8, count: 3, each: 40.0, category: "pets");

      final NewCategoryInsight insight = only<NewCategoryInsight>(
        ledger.analyze(august, now: lateSeptember),
      ).single;

      expect(insight.categoryUuid, "pets");
      expect(insight.current, 120.0);
      expect(insight.entryCount, 3);
    });

    test("a brand-new category under the floor stays quiet", () {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month, count: 30, each: 30.0);
      }
      ledger.flatMonth(2026, 8, count: 30, each: 30.0);
      ledger.flatMonth(2026, 8, count: 2, each: 40.0, category: "pets");

      expect(ledger.analyze(august, now: lateSeptember).insights, isEmpty);
    });
  });

  group("dates", () {
    test("comparisons cap at the end of shorter months", () {
      final TestLedger ledger = TestLedger();
      for (int month = 9; month <= 14; month++) {
        ledger.flatMonth(2025, month);
      }
      ledger.flatMonth(2026, 3);
      ledger.spend(DateTime(2026, 3, 20), 1000.0, title: "Bike");

      final MonthPaceInsight pace = only<MonthPaceInsight>(
        ledger.analyze(DateTime(2026, 3), now: DateTime(2026, 3, 31, 22)),
      ).single;

      expect(pace.history.map((value) => value.month), [
        DateTime(2025, 9),
        DateTime(2025, 10),
        DateTime(2025, 11),
        DateTime(2025, 12),
        DateTime(2026, 1),
        DateTime(2026, 2),
      ]);
      // Through the 31st: every month counts in full, February included.
      expect(pace.history.map((value) => value.amount), everyElement(1000.0));
      expect(pace.throughDay, 31);
    });

    test("mid-month, earlier months count up to the same day", () {
      final TestLedger ledger = TestLedger();
      for (int month = 9; month <= 14; month++) {
        ledger.flatMonth(2025, month);
      }
      ledger.flatMonth(2026, 3, throughDay: 15);
      ledger.spend(DateTime(2026, 3, 14), 1000.0, title: "Bike");

      final MonthPaceInsight pace = only<MonthPaceInsight>(
        ledger.analyze(DateTime(2026, 3), now: DateTime(2026, 3, 15, 9)),
      ).single;

      expect(pace.usual, 500.0);
      expect(pace.current, 1500.0);
    });

    test("an expense late on the last evening belongs to that month", () {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month);
      }
      ledger.flatMonth(2026, 8);
      ledger.spend(DateTime(2026, 8, 31, 23, 59, 59), 900.0);

      expect(
        only<MonthPaceInsight>(
          ledger.analyze(august, now: lateSeptember),
        ).single.current,
        1900.0,
      );
    });

    test("rent paid a day early doesn't make months look odd", () {
      final TestLedger ledger = TestLedger();
      for (int month = 7; month <= 15; month++) {
        ledger.flatMonth(2025, month);
      }
      for (int month = 7; month <= 15; month++) {
        // February's rent goes out on January 31st.
        final DateTime date = month == 14
            ? DateTime(2026, 1, 31)
            : DateTime(2025, month, 1);
        ledger.spend(date, 1200.0, title: "Rent", category: "housing");
      }

      final DateTime now = DateTime(2026, 4, 10);

      for (final DateTime month in [DateTime(2026, 1), DateTime(2026, 2)]) {
        expect(
          only<MonthPaceInsight>(ledger.analyze(month, now: now)),
          isEmpty,
          reason: "$month",
        );
      }
    });

    test("rent paid earlier than usual this month isn't overspending", () {
      TestLedger build({required String title}) {
        final TestLedger ledger = TestLedger();
        for (final int month in septemberBaseline) {
          ledger.flatMonth(2026, month);
          ledger.spend(
            DateTime(2026, month, 28),
            1200.0,
            title: "Rent",
            category: "housing",
          );
        }
        ledger.flatMonth(2026, 9, throughDay: 25);
        ledger.spend(DateTime(2026, 9, 20), 1200.0, title: title);
        return ledger;
      }

      expect(
        only<MonthPaceInsight>(
          build(title: "Rent").analyze(september, now: lateSeptember),
        ),
        isEmpty,
      );

      // The same amount as a one-off is real overspending.
      expect(
        only<MonthPaceInsight>(
          build(title: "Sofa").analyze(september, now: lateSeptember),
        ).single.direction,
        InsightDirection.above,
      );
    });

    test("rent that isn't due yet doesn't make the month look low", () {
      final TestLedger ledger = TestLedger();
      for (final int month in septemberBaseline) {
        ledger.flatMonth(2026, month, count: 6, each: 50.0);
        ledger.flatMonth(2026, month, count: 6, each: 50.0, category: "food");
        ledger.spend(
          DateTime(2026, month, 28),
          1200.0,
          title: "Rent",
          category: "housing",
        );
      }
      ledger.flatMonth(2026, 9, count: 6, each: 50.0, throughDay: 25);
      ledger.flatMonth(
        2026,
        9,
        count: 6,
        each: 50.0,
        category: "food",
        throughDay: 25,
      );

      expect(ledger.analyze(september, now: lateSeptember).insights, isEmpty);
    });

    test("a yearly charge seen last year isn't unusual", () {
      TestLedger build({required bool paidLastYear}) {
        final TestLedger ledger = TestLedger();
        for (int month = 1; month <= 20; month++) {
          ledger.flatMonth(2025, month);
        }
        if (paidLastYear) {
          ledger.spend(
            DateTime(2025, 8, 14),
            1500.0,
            title: "Car insurance",
            category: "insurance",
          );
        }
        ledger.spend(
          DateTime(2026, 8, 14),
          1500.0,
          title: "Car insurance",
          category: "insurance",
        );
        return ledger;
      }

      final InsightReport repeated = build(
        paidLastYear: true,
      ).analyze(august, now: lateAugust);

      expect(only<MonthPaceInsight>(repeated), isEmpty);
      expect(only<NewCategoryInsight>(repeated), isEmpty);
      expect(
        only<RecurringChargeInsight>(repeated).single.series.cadence,
        RecurringCadence.yearly,
      );
      expect(
        only<MonthPaceInsight>(
          build(paidLastYear: false).analyze(august, now: lateAugust),
        ),
        hasLength(1),
      );
    });
  });

  group("robustness", () {
    test("runs through compute(), on another isolate", () async {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month);
      }
      ledger.flatMonth(2026, 8);
      ledger.spend(DateTime(2026, 8, 10), 1000.0, title: "Sofa");

      final InsightReport report = await compute(
        computeInsights,
        InsightRequest(
          transactions: ledger.transactions,
          month: august,
          now: lateSeptember,
          hiddenTypes: const {InsightType.priceChange},
        ),
      );

      expect(report.insights.single, isA<MonthPaceInsight>());
    });

    test("no data at all", () {
      final InsightReport report = TestLedger().analyze(
        september,
        now: lateSeptember,
      );

      expect(report.status, InsightReportStatus.notEnoughHistory);
      expect(report.insights, isEmpty);
      expect(report.month, september);
    });

    test("only income", () {
      final TestLedger ledger = TestLedger();
      for (int month = 1; month <= 9; month++) {
        for (int i = 0; i < 12; i++) {
          ledger.earn(DateTime(2026, month, 1 + i), 1000.0);
        }
      }

      expect(
        ledger.analyze(september, now: lateSeptember).status,
        InsightReportStatus.notEnoughHistory,
      );
    });

    test("a future month says so", () {
      expect(
        TestLedger().analyze(DateTime(2026, 10), now: lateSeptember).status,
        InsightReportStatus.futureMonth,
      );
    });

    test("transfers, pending and zero amounts are ignored", () {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month);
      }
      ledger.flatMonth(2026, 8);
      ledger.spend(DateTime(2026, 8, 5), 5000.0, isTransfer: true);
      ledger.spend(DateTime(2026, 8, 6), 5000.0, isPending: true);
      ledger.spend(DateTime(2026, 8, 7), 0.0);

      expect(ledger.analyze(august, now: lateSeptember).insights, isEmpty);
    });

    test("a refunded purchase isn't spend", () {
      TestLedger build({double? refund}) {
        final TestLedger ledger = TestLedger();
        for (final int month in augustBaseline) {
          ledger.flatMonth(2026, month);
        }
        ledger.flatMonth(2026, 8);
        ledger.spend(DateTime(2026, 8, 3), 600.0, title: "Jacket");
        if (refund != null) {
          ledger.earn(
            DateTime(2026, 8, 12),
            refund,
            title: "JACKET",
            category: "misc",
          );
        }
        return ledger;
      }

      expect(
        build(refund: 600.0).analyze(august, now: lateSeptember).insights,
        isEmpty,
      );
      expect(
        only<MonthPaceInsight>(
          build().analyze(august, now: lateSeptember),
        ).single.current,
        1600.0,
      );
      expect(
        only<MonthPaceInsight>(
          build(refund: 300.0).analyze(august, now: lateSeptember),
        ),
        hasLength(1),
      );
    });

    test("a refund before the purchase doesn't cancel it", () {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month);
      }
      ledger.flatMonth(2026, 8);
      ledger.earn(DateTime(2026, 8, 1), 600.0, title: "Jacket");
      ledger.spend(DateTime(2026, 8, 3), 600.0, title: "Jacket");

      expect(
        only<MonthPaceInsight>(ledger.analyze(august, now: lateSeptember)),
        hasLength(1),
      );
    });

    test("a huge outlier in the baseline doesn't make a normal month low", () {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month);
      }
      ledger.spend(DateTime(2026, 4, 10), 50000.0, title: "Car");
      ledger.flatMonth(2026, 8);

      final InsightReport report = ledger.analyze(august, now: lateSeptember);

      expect(report.usualMonthTotal, 1000.0);
      expect(report.insights, isEmpty);
    });

    test("a huge outlier this month is named, with finite numbers", () {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month);
      }
      ledger.flatMonth(2026, 8);
      ledger.spend(DateTime(2026, 8, 10), 1e9, title: "Yacht");

      final MonthPaceInsight pace =
          ledger.analyze(august, now: lateSeptember).insights.first
              as MonthPaceInsight;

      expect(pace.attribution?.title, "Yacht");
      expect(pace.ratioWithoutAttribution, 1.0);
      expect(numbersOf(pace).every((number) => number.isFinite), isTrue);
    });

    test("non-finite amounts are skipped", () {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month);
      }
      ledger.flatMonth(2026, 8);
      ledger.spend(DateTime(2026, 8, 10), double.infinity);
      ledger.spend(DateTime(2026, 8, 11), double.nan);

      expect(ledger.analyze(august, now: lateSeptember).insights, isEmpty);
    });
  });

  group("recurring charges", () {
    /// 30 × 30 a month (floor 90) plus [title] on the [day]th.
    TestLedger withCharge(
      String title,
      List<double> amounts, {
      int day = 15,
      String? recurringUuid,
    }) {
      final TestLedger ledger = TestLedger();
      for (int i = 0; i < amounts.length; i++) {
        final int month = 9 - amounts.length + i;
        ledger.flatMonth(2026, month, count: 30, each: 30.0);
        ledger.spend(
          DateTime(2026, month, day),
          amounts[i],
          title: title,
          category: "subscriptions",
          recurringUuid: recurringUuid,
        );
      }
      return ledger;
    }

    test("an untracked monthly charge is suggested once charged", () {
      final TestLedger ledger = withCharge("Netflix", List.filled(6, 15.49));

      final RecurringChargeInsight insight = only<RecurringChargeInsight>(
        ledger.analyze(august, now: lateAugust),
      ).single;

      expect(insight.key, "recurringCharge:title:netflix");
      expect(insight.stake, moreOrLessEquals(15.49 * 12));
      expect(insight.series.occurrences, hasLength(6));
      expect(insight.series.categoryUuid, "subscriptions");
      expect(insight.transactionUuids, hasLength(6));
    });

    test("not before this month's charge", () {
      final TestLedger ledger = withCharge("Netflix", List.filled(6, 15.49));
      ledger.flatMonth(2026, 9, count: 30, each: 30.0, throughDay: 10);

      expect(
        only<RecurringChargeInsight>(
          ledger.analyze(september, now: DateTime(2026, 9, 10)),
        ),
        isEmpty,
      );
    });

    test("already tracked charges aren't suggested", () {
      final TestLedger generated = withCharge(
        "Netflix",
        List.filled(6, 15.49),
        recurringUuid: "r-netflix",
      );
      final TestLedger manual = withCharge("Netflix", List.filled(6, 15.49));

      expect(generated.analyze(august, now: lateAugust).insights, isEmpty);
      expect(
        manual
            .analyze(
              august,
              now: lateAugust,
              templates: const [
                InsightRecurringTemplate(title: "Netflix", amount: 15.49),
              ],
            )
            .insights,
        isEmpty,
      );
    });

    test("cheap charges under the floor aren't suggested", () {
      final TestLedger ledger = withCharge("App", List.filled(6, 2.99));

      expect(ledger.analyze(august, now: lateAugust).insights, isEmpty);
    });

    test("a variable bill isn't suggested", () {
      final TestLedger ledger = withCharge("Electricity", [
        82.0,
        140.0,
        95.0,
        61.0,
        120.0,
        88.0,
      ]);

      expect(ledger.analyze(august, now: lateAugust).insights, isEmpty);
    });

    test("only the biggest suggestion per month", () {
      final TestLedger ledger = withCharge("Netflix", List.filled(6, 15.49));
      for (int month = 3; month <= 8; month++) {
        ledger.spend(DateTime(2026, month, 3), 11.99, title: "Spotify");
      }

      final List<RecurringChargeInsight> suggestions =
          only<RecurringChargeInsight>(
            ledger.analyze(august, now: lateAugust, limit: 10),
          );

      expect(suggestions.single.series.title, "Netflix");
    });

    test("a price change shows in its month, then the suggestion returns", () {
      final TestLedger ledger = withCharge("Netflix", [
        15.49,
        15.49,
        15.49,
        15.49,
        15.49,
        17.99,
      ]);

      final InsightReport changed = ledger.analyze(august, now: lateSeptember);
      final PriceChangeInsight change = only<PriceChangeInsight>(
        changed,
      ).single;

      expect(change.previousAmount, 15.49);
      expect(change.currentAmount, 17.99);
      expect(change.stake, moreOrLessEquals(2.5 * 12));
      expect(change.changedOn, DateTime(2026, 8, 15));
      expect(only<RecurringChargeInsight>(changed), isEmpty);

      ledger.flatMonth(2026, 9, count: 30, each: 30.0, throughDay: 25);
      ledger.spend(DateTime(2026, 9, 15), 17.99, title: "Netflix");

      final InsightReport next = ledger.analyze(september, now: lateSeptember);
      expect(only<PriceChangeInsight>(next), isEmpty);
      expect(only<RecurringChargeInsight>(next), hasLength(1));
    });

    test("tracked series still report price changes", () {
      final TestLedger ledger = withCharge("Netflix", [
        15.49,
        15.49,
        15.49,
        17.99,
      ], recurringUuid: "r-netflix");

      expect(
        only<PriceChangeInsight>(ledger.analyze(august, now: lateSeptember)),
        hasLength(1),
      );
    });

    test("tiny price moves aren't changes", () {
      // 6% but only 0.60, and 2% of 100.
      for (final List<double> amounts in [
        [10.0, 10.0, 10.0, 10.6],
        [100.0, 100.0, 100.0, 102.0],
      ]) {
        expect(
          only<PriceChangeInsight>(
            withCharge("Gym", amounts).analyze(august, now: lateSeptember),
          ),
          isEmpty,
          reason: "$amounts",
        );
      }
    });

    test("a charge at the old price once isn't enough history", () {
      final TestLedger ledger = withCharge("Gym", [30.0, 30.0, 35.0]);

      expect(
        only<PriceChangeInsight>(ledger.analyze(august, now: lateSeptember)),
        isEmpty,
      );
    });

    test("a yearly subscription is suggested in its month", () {
      final TestLedger ledger = TestLedger();
      for (int month = 1; month <= 20; month++) {
        ledger.flatMonth(2025, month, count: 30, each: 30.0);
      }
      ledger.spend(DateTime(2025, 8, 20), 139.0, title: "Prime");
      ledger.spend(DateTime(2026, 8, 20), 139.0, title: "Prime");

      final InsightReport report = ledger.analyze(august, now: lateAugust);
      final RecurringChargeInsight insight =
          report.insights.single as RecurringChargeInsight;

      expect(insight.series.cadence, RecurringCadence.yearly);
      expect(insight.stake, 139.0);
    });

    test("suggestions still show before the 7th", () {
      final TestLedger ledger = withCharge(
        "Netflix",
        List.filled(6, 15.49),
        day: 3,
      );
      ledger.flatMonth(2026, 9, count: 30, each: 30.0, throughDay: 4);
      ledger.spend(DateTime(2026, 9, 3), 15.49, title: "Netflix");

      final InsightReport report = ledger.analyze(
        september,
        now: DateTime(2026, 9, 4),
      );

      expect(report.status, InsightReportStatus.tooEarly);
      expect(only<RecurringChargeInsight>(report), hasLength(1));
    });
  });

  group("ranking", () {
    /// Dining makes up the whole month's jump.
    TestLedger diningExplainsMonth() {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month, count: 30, each: 30.0);
        ledger.flatMonth(2026, month, count: 4, each: 25.0, category: "dining");
      }
      ledger.flatMonth(2026, 8, count: 30, each: 30.0);
      ledger.flatMonth(2026, 8, count: 4, each: 25.0, category: "dining");
      ledger.flatMonth(2026, 8, count: 5, each: 80.0, category: "dining");
      return ledger;
    }

    test("a category spike that explains the month folds into it", () {
      final InsightReport report = diningExplainsMonth().analyze(
        august,
        now: lateSeptember,
      );

      final MonthPaceInsight pace = report.insights.single as MonthPaceInsight;
      expect(pace.dominantDriver?.categoryUuid, "dining");
      expect(pace.dominantDriver?.delta, 400.0);
    });

    test("hiding a type lets the next one through", () {
      final InsightReport report = diningExplainsMonth().analyze(
        august,
        now: lateSeptember,
        hiddenTypes: {InsightType.monthPace},
      );

      expect(report.insights.single, isA<CategorySpikeInsight>());
    });

    test("never more than the limit, highest stake first", () {
      final TestLedger ledger = TestLedger();
      for (final int month in augustBaseline) {
        ledger.flatMonth(2026, month, count: 30, each: 30.0);
        for (final String category in ["a", "b", "c", "d"]) {
          ledger.flatMonth(
            2026,
            month,
            count: 3,
            each: 20.0,
            category: category,
          );
        }
        ledger.spend(DateTime(2026, month, 3), 30.0, title: "Gym");
      }
      ledger.flatMonth(2026, 8, count: 30, each: 30.0);
      ledger.flatMonth(2026, 8, count: 3, each: 90.0, category: "a");
      ledger.flatMonth(2026, 8, count: 3, each: 70.0, category: "b");
      ledger.flatMonth(2026, 8, count: 3, each: 60.0, category: "c");
      ledger.flatMonth(2026, 8, count: 3, each: 20.0, category: "d");
      ledger.flatMonth(2026, 8, count: 3, each: 50.0, category: "pets");
      ledger.spend(DateTime(2026, 8, 3), 30.0, title: "Gym");

      final InsightReport report = ledger.analyze(august, now: lateSeptember);
      final List<double> scores = report.insights
          .map((insight) => insight.score)
          .toList();

      expect(report.insights, hasLength(3));
      expect(
        scores,
        orderedEquals([...scores]..sort((a, b) => b.compareTo(a))),
      );
      expect(report.insights.first, isA<MonthPaceInsight>());

      final InsightReport all = ledger.analyze(
        august,
        now: lateSeptember,
        limit: 10,
      );
      expect(all.insights.length, greaterThan(3));
      expect(all.insights.take(3).map((insight) => insight.key), [
        for (final Insight insight in report.insights) insight.key,
      ]);
    });

    test("the same input in any order gives the same output", () {
      final math.Random random = math.Random(42);
      final TestLedger ledger = TestLedger();
      for (int month = 1; month <= 8; month++) {
        ledger.steadyMonth(2026, month, random);
      }
      ledger.steadyMonth(2026, 9, random, throughDay: 25);
      ledger.spend(DateTime(2026, 9, 12), 1500.0, title: "Flight");
      ledger.flatMonth(2026, 9, count: 4, each: 90.0, category: "dining");

      String fingerprint(List<InsightTransaction> transactions) =>
          computeInsights(
                InsightRequest(
                  transactions: transactions,
                  month: september,
                  now: lateSeptember,
                  limit: 10,
                ),
              ).insights
              .map((insight) => "${insight.key}@${insight.score}")
              .join(",");

      final String expected = fingerprint(ledger.transactions);

      for (int seed = 0; seed < 5; seed++) {
        expect(
          fingerprint([...ledger.transactions]..shuffle(math.Random(seed))),
          expected,
        );
      }
    });

    group("cooldown", () {
      TestLedger overspending() {
        final TestLedger ledger = TestLedger();
        for (final int month in septemberBaseline) {
          ledger.flatMonth(2026, month);
        }
        ledger.flatMonth(2026, 9, throughDay: 20);
        ledger.spend(DateTime(2026, 9, 10), 1000.0, title: "Sofa");
        return ledger;
      }

      final DateTime now = DateTime(2026, 9, 20);

      List<Insight> seen(DateTime shownAt, double stake) => overspending()
          .analyze(
            september,
            now: now,
            sightings: [
              InsightSighting(
                key: "monthPace:above",
                shownAt: shownAt,
                stake: stake,
              ),
            ],
          )
          .insights;

      test("shown last month, recently: suppressed", () {
        expect(seen(DateTime(2026, 8, 28), 900.0), isEmpty);
      });

      test("unless it grew by half", () {
        expect(seen(DateTime(2026, 8, 28), 600.0), hasLength(1));
      });

      test("shown this month: stays, so the card is stable", () {
        expect(seen(DateTime(2026, 9, 12), 900.0), hasLength(1));
      });

      test("shown over 28 days ago: back", () {
        expect(seen(DateTime(2026, 8, 22), 900.0), hasLength(1));
      });

      test("closed months ignore it", () {
        final TestLedger ledger = TestLedger();
        for (final int month in augustBaseline) {
          ledger.flatMonth(2026, month);
        }
        ledger.flatMonth(2026, 8);
        ledger.spend(DateTime(2026, 8, 10), 1000.0);

        expect(
          ledger
              .analyze(
                august,
                now: DateTime(2026, 9, 3),
                sightings: [
                  InsightSighting(
                    key: "monthPace:above",
                    shownAt: DateTime(2026, 7, 30),
                    stake: 1000.0,
                  ),
                ],
              )
              .insights,
          hasLength(1),
        );
      });
    });
  });

  group("demo-like ledger", () {
    /// Jul 2024 through [now], rent paid at a different hour each month
    /// unless [rentHour] is given. Rent goes from 1,590 to 1,690 in
    /// [raisedIn], if any.
    TestLedger demo(DateTime now, {int? rentHour, DateTime? raisedIn}) {
      final math.Random random = math.Random(11);
      final TestLedger ledger = TestLedger();
      const List<int> hours = [7, 12, 19, 21, 23];

      for (int i = 0; ; i++) {
        final DateTime month = DateTime(2024, 7 + i);
        if (month.isAfter(now)) break;

        final bool current = month.year == now.year && month.month == now.month;

        ledger.demoMonth(
          month.year,
          month.month,
          random,
          rentHour: rentHour ?? hours[i % hours.length],
          rent: raisedIn == null || !month.isBefore(raisedIn) ? 1690.0 : 1590.0,
          throughDay: current ? now.day : 31,
        );
      }

      return ledger;
    }

    void trip(TestLedger ledger, int month) {
      ledger.spend(DateTime(2026, month, 10, 8), 320.0, title: "Flight");
      for (int day = 10; day < 14; day++) {
        ledger.spend(DateTime(2026, month, day, 22), 210.0, title: "Hotel");
      }
      ledger.spend(DateTime(2026, month, 14, 18), 320.0, title: "Flight");
    }

    test("suggestions only show while their month is in progress", () {
      final TestLedger ledger = demo(lateSeptember);

      for (int month = 10; month <= 20; month++) {
        expect(
          only<RecurringChargeInsight>(
            ledger.analyze(DateTime(2025, month), now: lateSeptember),
          ),
          isEmpty,
          reason: "${DateTime(2025, month)}",
        );
      }

      expect(
        only<RecurringChargeInsight>(
          ledger.analyze(september, now: lateSeptember),
        ).single.series.title,
        "Rent",
      );
    });

    test("this month's charge is in its series, whatever time it was paid", () {
      for (final int hour in [0, 7, 19, 23]) {
        for (final DateTime now in [
          lateSeptember,
          DateTime(2026, 9, 1, 23, 59, 59),
        ]) {
          final TestLedger ledger = demo(now, rentHour: hour);
          final InsightTransaction rent = ledger.transactions.lastWhere(
            (transaction) => transaction.title == "Rent",
          );

          final RecurringChargeInsight insight = only<RecurringChargeInsight>(
            ledger.analyze(september, now: now),
          ).single;

          expect(rent.date, DateTime(2026, 9, 1, hour, 59), reason: "$now");
          expect(insight.series.occurrences, hasLength(27), reason: "$now");
          expect(
            insight.series.occurrences.last.transactionUuid,
            rent.uuid,
            reason: "$hour:59, $now",
          );
          expect(insight.transactionUuids.first, rent.uuid);
        }
      }
    });

    test("a closed month's series ends with that month", () {
      final TestLedger ledger = demo(lateSeptember, raisedIn: august);

      final PriceChangeInsight change = only<PriceChangeInsight>(
        ledger.analyze(august, now: lateSeptember),
      ).single;

      expect(change.previousAmount, 1590.0);
      expect(change.currentAmount, 1690.0);
      expect(change.series.occurrences, hasLength(26));
      expect(change.changedOn.month, 8);
    });

    test("a yearly rent raise shows, even after an earlier one", () {
      final TestLedger ledger = TestLedger();
      final math.Random random = math.Random(5);

      for (int i = 0; i < 27; i++) {
        final DateTime month = DateTime(2024, 7 + i);
        ledger.demoMonth(
          month.year,
          month.month,
          random,
          rent: i < 3
              ? 1480.0
              : i < 15
              ? 1590.0
              : 1690.0,
          throughDay: i == 26 ? 25 : 31,
        );
      }

      final PriceChangeInsight change = only<PriceChangeInsight>(
        ledger.analyze(DateTime(2025, 10), now: lateSeptember),
      ).single;
      expect(change.previousAmount, 1590.0);
      expect(change.currentAmount, 1690.0);

      expect(
        only<RecurringChargeInsight>(
          ledger.analyze(september, now: lateSeptember),
        ).single.series.typicalAmount,
        1690.0,
      );
    });

    test("rent never explains an unusual month", () {
      for (final DateTime month in [DateTime(2026, 7), september]) {
        final TestLedger ledger = demo(lateSeptember);
        trip(ledger, month.month);

        final MonthPaceInsight pace = only<MonthPaceInsight>(
          ledger.analyze(month, now: lateSeptember),
        ).single;

        expect(pace.direction, InsightDirection.above, reason: "$month");
        expect(pace.attribution, isNull, reason: "$month");
        expect(pace.dominantDriver?.categoryUuid, isNot("rent"));
      }
    });

    test("a big one-off purchase still explains it", () {
      final TestLedger ledger = demo(lateSeptember);
      ledger.spend(DateTime(2026, 7, 12, 20), 1500.0, title: "Laptop");

      expect(
        only<MonthPaceInsight>(
          ledger.analyze(DateTime(2026, 7), now: lateSeptember),
        ).single.attribution?.title,
        "Laptop",
      );
    });
  });
}

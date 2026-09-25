import "package:flow/data/insights/insight_engine.dart";
import "package:flow/data/insights/insight_math.dart";
import "package:flutter_test/flutter_test.dart";

import "insight_test_data.dart";

void main() {
  List<RecurringSeries> detect(
    TestLedger ledger, {
    List<InsightRecurringTemplate> templates = const [],
  }) => detectRecurringSeries(ledger.transactions, templates: templates);

  /// Charges [title] on each of [dates].
  TestLedger charges(
    List<DateTime> dates, {
    String title = "Spotify",
    double amount = 11.99,
    List<double>? amounts,
  }) {
    final TestLedger ledger = TestLedger();

    for (int i = 0; i < dates.length; i++) {
      ledger.spend(dates[i], amounts?[i] ?? amount, title: title);
    }

    return ledger;
  }

  List<DateTime> monthly(int day, {int from = 1, int count = 6}) => [
    for (int i = 0; i < count; i++) DateTime(2026, from + i, day, 9),
  ];

  group("monthly", () {
    test("exact monthly charges", () {
      final List<RecurringSeries> found = detect(charges(monthly(3)));

      expect(found, hasLength(1));
      expect(found.single.cadence, RecurringCadence.monthly);
      expect(found.single.anchorDay, 3);
      expect(found.single.isFixedPrice, isTrue);
      expect(found.single.priceChangeIndex, isNull);
      expect(found.single.typicalAmount, 11.99);
      expect(found.single.annualCost, moreOrLessEquals(143.88));
      expect(found.single.key, "title:spotify");
    });

    test("up to 3 days of jitter, like weekends", () {
      final List<RecurringSeries> found = detect(
        charges([
          DateTime(2026, 1, 3),
          DateTime(2026, 2, 5),
          DateTime(2026, 3, 2),
          DateTime(2026, 4, 6),
          DateTime(2026, 5, 3),
        ]),
      );

      expect(found.single.cadence, RecurringCadence.monthly);
    });

    test("wraps around month starts (30th, 1st, 2nd, 31st)", () {
      final List<RecurringSeries> found = detect(
        charges([
          DateTime(2025, 12, 30),
          DateTime(2026, 2, 1),
          DateTime(2026, 3, 2),
          DateTime(2026, 3, 31),
          DateTime(2026, 5, 1),
        ]),
      );

      expect(found.single.cadence, RecurringCadence.monthly);
    });

    test("too much jitter isn't monthly", () {
      expect(
        detect(
          charges([
            DateTime(2026, 1, 3),
            DateTime(2026, 2, 11),
            DateTime(2026, 3, 1),
            DateTime(2026, 4, 12),
          ]),
        ),
        isEmpty,
      );
    });

    test("month ends: Jan 31 -> Feb 28 -> Mar 31 -> Apr 30", () {
      final List<RecurringSeries> found = detect(
        charges([
          DateTime(2026, 1, 31),
          DateTime(2026, 2, 28),
          DateTime(2026, 3, 31),
          DateTime(2026, 4, 30),
          DateTime(2026, 5, 31),
        ]),
      );

      expect(found.single.cadence, RecurringCadence.monthly);
      expect(found.single.anchorDay, 31);
    });

    test("leap years: Jan 31 -> Feb 29 -> Mar 31", () {
      final List<RecurringSeries> found = detect(
        charges([
          DateTime(2024, 1, 31),
          DateTime(2024, 2, 29),
          DateTime(2024, 3, 31),
        ]),
      );

      expect(found.single.cadence, RecurringCadence.monthly);
    });

    test("one charge paid ten days early in a long series is tolerated", () {
      final List<RecurringSeries> found = detect(
        charges([...monthly(28, count: 5), DateTime(2026, 6, 18)]),
      );

      expect(found.single.cadence, RecurringCadence.monthly);
      expect(found.single.anchorDay, 28);
      expect(
        monthStartOf(found.single.periodOf(found.single.occurrences.last)),
        DateTime(2026, 6),
      );
    });

    test("but not in a short one", () {
      expect(
        detect(charges([...monthly(28, count: 2), DateTime(2026, 3, 18)])),
        isEmpty,
      );
    });

    test("a skipped month is fine", () {
      final List<RecurringSeries> found = detect(
        charges([
          DateTime(2026, 1, 3),
          DateTime(2026, 2, 3),
          DateTime(2026, 4, 3),
          DateTime(2026, 5, 3),
          DateTime(2026, 6, 3),
        ]),
      );

      expect(found.single.cadence, RecurringCadence.monthly);
    });

    test("every other month isn't monthly", () {
      expect(
        detect(
          charges([for (int i = 0; i < 5; i++) DateTime(2026, 1 + i * 2, 3)]),
        ),
        isEmpty,
      );
    });

    test("every 28 days isn't monthly", () {
      expect(
        detect(
          charges([
            for (int i = 0; i < 8; i++)
              DateTime(2026, 1, 1).add(Duration(days: 28 * i)),
          ]),
        ),
        isEmpty,
      );
    });

    test("two charges needed at least three times", () {
      expect(detect(charges(monthly(3, count: 2))), isEmpty);
    });

    test("a price increase is one series with a change at the end", () {
      final List<RecurringSeries> found = detect(
        charges(
          monthly(15),
          amounts: [15.49, 15.49, 15.49, 15.49, 15.49, 17.99],
        ),
      );

      expect(found.single.isFixedPrice, isTrue);
      expect(found.single.priceChangeIndex, 5);
      expect(found.single.previousAmount, 15.49);
      expect(found.single.typicalAmount, 17.99);
    });

    test("an older price change settles on the new price", () {
      final List<RecurringSeries> found = detect(
        charges(
          monthly(15),
          amounts: [15.49, 15.49, 15.49, 17.99, 17.99, 17.99],
        ),
      );

      expect(found.single.priceChangeIndex, 3);
      expect(found.single.typicalAmount, 17.99);
    });

    test("small currency wobble is still one fixed price", () {
      final List<RecurringSeries> found = detect(
        charges(
          monthly(15),
          amounts: [14.02, 14.31, 13.87, 14.12, 14.40, 13.95],
        ),
      );

      expect(found.single.isFixedPrice, isTrue);
      expect(found.single.priceChangeIndex, isNull);
    });

    test("a variable bill is monthly but not fixed price", () {
      final List<RecurringSeries> found = detect(
        charges(
          monthly(20),
          title: "Electricity",
          amounts: [82.0, 140.0, 95.0, 61.0, 120.0, 88.0],
        ),
      );

      expect(found.single.cadence, RecurringCadence.monthly);
      expect(found.single.isFixedPrice, isFalse);
    });

    test("wildly different amounts aren't a series", () {
      expect(
        detect(
          charges(
            monthly(20),
            title: "Amazon",
            amounts: [5.0, 300.0, 18.0, 90.0, 2.0, 700.0],
          ),
        ),
        isEmpty,
      );
    });

    test("a double charge in one month breaks the pattern", () {
      expect(
        detect(
          charges([
            DateTime(2026, 1, 3),
            DateTime(2026, 2, 3),
            DateTime(2026, 2, 4),
            DateTime(2026, 3, 3),
          ]),
        ),
        isEmpty,
      );
    });
  });

  group("weekly and yearly", () {
    test("weekly isn't mislabeled as monthly", () {
      final List<RecurringSeries> found = detect(
        charges([
          for (int i = 0; i < 8; i++) DateTime(2026, 3, 2 + i * 7, 18),
        ], title: "Yoga class"),
      );

      expect(found.single.cadence, RecurringCadence.weekly);
      expect(found.single.annualCost, moreOrLessEquals(11.99 * 52));
    });

    test("weekly across daylight saving still reads 7-day gaps", () {
      final List<RecurringSeries> found = detect(
        charges([
          for (int i = 0; i < 4; i++) DateTime(2026, 3, 22 + i * 7, 0, 30),
        ], title: "Yoga class"),
      );

      expect(found.single.cadence, RecurringCadence.weekly);
    });

    test("every two weeks is neither weekly nor monthly", () {
      expect(
        detect(
          charges([for (int i = 0; i < 8; i++) DateTime(2026, 1, 5 + i * 14)]),
        ),
        isEmpty,
      );
    });

    test("yearly isn't mislabeled as monthly", () {
      final List<RecurringSeries> found = detect(
        charges(
          [DateTime(2024, 8, 14), DateTime(2025, 8, 14), DateTime(2026, 8, 13)],
          title: "Prime",
          amount: 139.0,
        ),
      );

      expect(found.single.cadence, RecurringCadence.yearly);
      expect(found.single.annualCost, 139.0);
    });

    test("two yearly charges are enough when the amount holds", () {
      final List<RecurringSeries> found = detect(
        charges(
          [DateTime(2025, 8, 14), DateTime(2026, 8, 14)],
          title: "Prime",
          amount: 139.0,
        ),
      );

      expect(found.single.cadence, RecurringCadence.yearly);
    });

    test("two yearly charges with different amounts aren't a series", () {
      expect(
        detect(
          charges(
            [DateTime(2025, 8, 14), DateTime(2026, 8, 14)],
            title: "Dentist",
            amounts: [120.0, 480.0],
          ),
        ),
        isEmpty,
      );
    });
  });

  group("grouping", () {
    test("two merchants with the same amount stay apart", () {
      final TestLedger ledger = TestLedger();

      for (final DateTime date in monthly(5)) {
        ledger.spend(date, 9.99, title: "Netflix");
        ledger.spend(date, 9.99, title: "Hulu");
      }

      final List<RecurringSeries> found = detect(ledger);

      expect(found.map((series) => series.key), [
        "title:hulu",
        "title:netflix",
      ]);
    });

    test("one title with two plans splits into two series", () {
      final TestLedger ledger = TestLedger();

      for (int i = 0; i < 5; i++) {
        ledger.spend(DateTime(2026, 1 + i, 5), 2.99, title: "Apple");
        ledger.spend(DateTime(2026, 1 + i, 12), 10.99, title: "Apple");
      }

      final List<RecurringSeries> found = detect(ledger);

      expect(found, hasLength(2));
      expect(
        found.map((series) => series.typicalAmount),
        containsAll([2.99, 10.99]),
      );
      expect(found.map((series) => series.anchorDay), containsAll([5, 12]));
    });

    test("titles group after normalization", () {
      final TestLedger ledger = charges(monthly(3, count: 2));
      ledger.spend(DateTime(2026, 3, 3), 11.99, title: "SPOTIFY #88213");

      expect(detect(ledger).single.occurrences, hasLength(3));
    });

    test("untitled charges are never grouped", () {
      final TestLedger ledger = TestLedger();
      for (final DateTime date in monthly(3)) {
        ledger.spend(date, 11.99);
      }

      expect(detect(ledger), isEmpty);
    });

    test("Flow recurring transactions are tracked", () {
      final TestLedger ledger = TestLedger();
      for (final DateTime date in monthly(1)) {
        ledger.spend(date, 1200.0, title: "Rent", recurringUuid: "r-1");
      }

      final RecurringSeries series = detect(ledger).single;

      expect(series.key, "recurring:r-1");
      expect(series.isTracked, isTrue);
    });

    test("a matching recurring template marks the series as tracked", () {
      final List<RecurringSeries> found = detect(
        charges(monthly(3)),
        templates: const [
          InsightRecurringTemplate(title: "spotify", amount: -11.99),
        ],
      );

      expect(found.single.isTracked, isTrue);
    });

    test("a template with another title or amount doesn't match", () {
      final List<RecurringSeries> found = detect(
        charges(monthly(3)),
        templates: const [
          InsightRecurringTemplate(title: "Spotify", amount: 49.99),
          InsightRecurringTemplate(title: "Netflix", amount: 11.99),
        ],
      );

      expect(found.single.isTracked, isFalse);
    });

    test("the most common category and account win", () {
      final TestLedger ledger = TestLedger();
      final List<DateTime> dates = monthly(3);

      for (int i = 0; i < dates.length; i++) {
        ledger.spend(
          dates[i],
          11.99,
          title: "Spotify",
          category: i == 0 ? "fun" : "subscriptions",
          account: i < 4 ? "card" : "checking",
        );
      }

      final RecurringSeries series = detect(ledger).single;

      expect(series.categoryUuid, "subscriptions");
      expect(series.accountUuid, "card");
    });
  });
}

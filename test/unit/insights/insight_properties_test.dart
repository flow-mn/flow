import "dart:math" as math;

import "package:flow/data/insights/insight_engine.dart";
import "package:flutter_test/flutter_test.dart";

import "insight_test_data.dart";

/// Seeded random ledgers: the engine must stay sane whatever it's fed.
void main() {
  const List<String?> titles = [
    null,
    "Coffee",
    "Grocer",
    "Spotify",
    "Rent",
    "Uber",
    "Amazon",
    "Gym",
  ];
  const List<String?> categories = [null, "food", "fun", "bills", "travel"];

  TestLedger randomLedger(math.Random random, DateTime now) {
    final TestLedger ledger = TestLedger();
    final int months = random.nextInt(16);

    for (int back = months; back >= 0; back--) {
      final int count = random.nextInt(60);

      for (int i = 0; i < count; i++) {
        final DateTime date = DateTime(
          now.year,
          now.month - back,
          1 + random.nextInt(31),
          random.nextInt(24),
          random.nextInt(60),
        );
        if (date.isAfter(now)) continue;

        final double roll = random.nextDouble();
        final double amount = switch (roll) {
          < 0.01 => random.nextDouble() * 1e7,
          < 0.03 => 0.0,
          _ => math.exp(random.nextDouble() * 7),
        };

        if (random.nextDouble() < 0.1) {
          ledger.earn(
            date,
            amount,
            title: titles[random.nextInt(titles.length)],
            category: categories[random.nextInt(categories.length)],
          );
        } else {
          ledger.spend(
            date,
            amount,
            title: titles[random.nextInt(titles.length)],
            category: categories[random.nextInt(categories.length)],
            isTransfer: random.nextDouble() < 0.03,
            isPending: random.nextDouble() < 0.03,
          );
        }
      }
    }

    return ledger;
  }

  test("random ledgers: finite numbers, at most 3, ranked, unique", () {
    int produced = 0;

    for (int seed = 0; seed < 300; seed++) {
      final math.Random random = math.Random(seed);
      final DateTime now = DateTime(
        2024 + random.nextInt(3),
        1 + random.nextInt(12),
        1 + random.nextInt(28),
        random.nextInt(24),
      );
      final TestLedger ledger = randomLedger(random, now);
      final DateTime month = DateTime(now.year, now.month - random.nextInt(3));

      final InsightReport report = ledger.analyze(month, now: now);

      expect(report.insights.length, lessThanOrEqualTo(3), reason: "$seed");
      produced += report.insights.length;

      final Set<String> keys = {};
      double previous = double.infinity;

      for (final Insight insight in report.insights) {
        expect(
          numbersOf(insight).every((number) => number.isFinite),
          isTrue,
          reason: "seed $seed: ${insight.key}",
        );
        expect(insight.stake, greaterThanOrEqualTo(0.0), reason: "$seed");
        expect(insight.score, lessThanOrEqualTo(previous), reason: "$seed");
        expect(keys.add(insight.key), isTrue, reason: "$seed");
        previous = insight.score;
      }

      final double? usual = report.usualMonthTotal;
      if (usual != null) expect(usual.isFinite && usual > 0, isTrue);
    }

    // Otherwise the checks above prove nothing.
    expect(produced, greaterThan(50));
  });

  test("identical months never trigger a comparison", () {
    for (int seed = 0; seed < 100; seed++) {
      final math.Random random = math.Random(seed);
      final int count = 10 + random.nextInt(40);
      final List<({int day, double amount, String? category})> pattern = [
        for (int i = 0; i < count; i++)
          (
            day: 1 + random.nextInt(28),
            amount: math.exp(random.nextDouble() * 6),
            category: categories[random.nextInt(categories.length)],
          ),
      ];

      final DateTime now = DateTime(2026, 9, 1 + random.nextInt(28), 23);
      final TestLedger ledger = TestLedger();

      for (int month = 1; month <= 9; month++) {
        for (final entry in pattern) {
          if (month == 9 && entry.day > now.day) continue;

          ledger.spend(
            DateTime(2026, month, entry.day, 12),
            entry.amount,
            category: entry.category,
          );
        }
      }

      for (final DateTime month in [DateTime(2026, 8), DateTime(2026, 9)]) {
        expect(
          ledger.analyze(month, now: now).insights,
          isEmpty,
          reason: "seed $seed, $month",
        );
      }
    }
  });

  test("a limit of zero returns nothing", () {
    final TestLedger ledger = TestLedger();
    for (int month = 2; month <= 8; month++) {
      ledger.flatMonth(2026, month);
    }
    ledger.spend(DateTime(2026, 8, 3), 5000.0);

    expect(
      ledger
          .analyze(DateTime(2026, 8), now: DateTime(2026, 9, 2), limit: 0)
          .insights,
      isEmpty,
    );
  });
}

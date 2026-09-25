import "dart:math" as math;

import "package:flow/data/insights/insight_engine.dart";
import "package:flutter_test/flutter_test.dart";

import "insight_test_data.dart";

void main() {
  final DateTime now = DateTime(2026, 9, 25, 15, 30);

  /// USD to EUR, so nothing is a round number.
  const double rate = 0.8537;

  const List<String> places = [
    "Corner bakery",
    "Green grocer",
    "Noodle house",
    "Book nook",
    "Hardware store",
    "Pharmacy",
    "Taxi",
    "Cinema",
    "Florist",
    "Pet shop",
    "Deli",
    "Bike repair",
    "Laundromat",
    "Tea room",
    "Bistro",
    "Kiosk",
    "Butcher",
    "Stationery",
    "Car wash",
    "Market stall",
  ];

  /// Three years of converted daily spend over many titles, each with its
  /// own price range, so most of it goes through recurring detection.
  TestLedger heavyLedger() {
    final math.Random random = math.Random(7);
    final TestLedger ledger = TestLedger();

    for (
      DateTime day = DateTime(2023, 9, 1);
      day.isBefore(now);
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      DateTime at() => DateTime(
        day.year,
        day.month,
        day.day,
        7 + random.nextInt(15),
        random.nextInt(60),
      );

      if (day.day == 1) {
        ledger.spend(at(), 1690.0 * rate, title: "Rent", category: "rent");
      }
      if (day.day == 9) {
        ledger.spend(at(), 11.99 * rate, title: "Spotify", category: "subs");
      }

      for (int i = 0; i < 8; i++) {
        final int place = random.nextInt(places.length);

        ledger.spend(
          at(),
          (5.0 + place * 4) * (0.5 + random.nextDouble() * 1.5) * rate,
          title: places[place],
          category: "category ${place % 6}",
        );
      }
    }

    return ledger;
  }

  // Took over a second while recurring detection built local DateTimes,
  // each a time zone lookup (and ten seconds on an iOS simulator).
  test("a heavy ledger computes quickly", () {
    final TestLedger ledger = heavyLedger();

    // Warm up, so JIT compilation isn't measured.
    ledger.analyze(DateTime(2026, 8), now: now);

    final Stopwatch stopwatch = Stopwatch()..start();
    final InsightReport complete = ledger.analyze(DateTime(2026, 8), now: now);
    final InsightReport inProgress = ledger.analyze(
      DateTime(2026, 9),
      now: now,
    );
    stopwatch.stop();

    expect(complete.status, InsightReportStatus.ready);
    expect(inProgress.status, InsightReportStatus.ready);
    expect(stopwatch.elapsedMilliseconds, lessThan(500));
  });
}

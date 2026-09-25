import "package:flow/data/insights/insight_math.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("median", () {
    test("odd, even and empty", () {
      expect(median([3.0, 1.0, 2.0]), 2.0);
      expect(median([4.0, 1.0, 3.0, 2.0]), 2.5);
      expect(median(<double>[]), 0.0);
    });

    test("one huge value doesn't move it", () {
      expect(median([100.0, 110.0, 90.0, 105.0, 50000.0]), 105.0);
    });
  });

  group("coefficientOfVariation", () {
    test("constant values have none", () {
      expect(coefficientOfVariation([9.99, 9.99, 9.99]), 0.0);
    });

    test("fewer than two values, or a zero mean, read as 0", () {
      expect(coefficientOfVariation([5.0]), 0.0);
      expect(coefficientOfVariation([0.0, 0.0]), 0.0);
    });

    test("measures spread relative to the mean", () {
      expect(coefficientOfVariation([90.0, 110.0]), moreOrLessEquals(0.1));
    });
  });

  group("months", () {
    test("index round-trips across year boundaries", () {
      final int december = monthIndexOf(DateTime(2025, 12, 31, 23, 59));

      expect(monthStartOf(december), DateTime(2025, 12));
      expect(monthStartOf(december + 1), DateTime(2026, 1));
      expect(monthStartOf(december - 12), DateTime(2024, 12));
    });

    test("days in month know about leap years", () {
      expect(daysInMonth(monthIndexOf(DateTime(2026, 2))), 28);
      expect(daysInMonth(monthIndexOf(DateTime(2024, 2))), 29);
      expect(daysInMonth(monthIndexOf(DateTime(2100, 2))), 28);
      expect(daysInMonth(monthIndexOf(DateTime(2000, 2))), 29);
      expect(daysInMonth(monthIndexOf(DateTime(2026, 4))), 30);
      expect(daysInMonth(monthIndexOf(DateTime(2026, 12))), 31);
    });

    test("charge day clamps to short months", () {
      expect(chargeDayOf(monthIndexOf(DateTime(2026, 2)), 31).day, 28);
      expect(chargeDayOf(monthIndexOf(DateTime(2024, 2)), 31).day, 29);
      expect(chargeDayOf(monthIndexOf(DateTime(2026, 4)), 31).day, 30);
      expect(chargeDayOf(monthIndexOf(DateTime(2026, 5)), 31).day, 31);
    });
  });

  group("dayDifference", () {
    test("ignores time of day", () {
      expect(
        dayDifference(DateTime(2026, 3, 1, 23, 59), DateTime(2026, 3, 2)),
        1,
      );
      expect(
        dayDifference(DateTime(2026, 3, 2), DateTime(2026, 3, 1, 23, 59)),
        -1,
      );
    });

    test("isn't fooled by daylight saving transitions", () {
      // US and EU spring-forward and fall-back weekends of 2026.
      expect(dayDifference(DateTime(2026, 3, 7), DateTime(2026, 3, 9)), 2);
      expect(dayDifference(DateTime(2026, 3, 28), DateTime(2026, 3, 30)), 2);
      expect(dayDifference(DateTime(2026, 10, 24), DateTime(2026, 10, 26)), 2);
      expect(dayDifference(DateTime(2026, 10, 31), DateTime(2026, 11, 2)), 2);
      expect(dayDifference(DateTime(2026, 1, 1), DateTime(2027, 1, 1)), 365);
    });

    test("treats UTC and local dates by their calendar fields", () {
      expect(
        dayDifference(DateTime.utc(2026, 3, 29), DateTime(2026, 3, 30)),
        1,
      );
    });
  });

  group("nearestSlot", () {
    test(
      "a charge on the 28th of February belongs to February for the 31st",
      () {
        final ({int slot, int offset}) result = nearestSlot(
          DateTime(2026, 2, 28),
          31,
        );

        expect(monthStartOf(result.slot), DateTime(2026, 2));
        expect(result.offset, 0);
      },
    );

    test("a charge paid a day early belongs to the next month", () {
      final ({int slot, int offset}) result = nearestSlot(
        DateTime(2026, 1, 31),
        1,
      );

      expect(monthStartOf(result.slot), DateTime(2026, 2));
      expect(result.offset, -1);
    });

    test("a charge slipping into the next month stays with its own", () {
      final ({int slot, int offset}) result = nearestSlot(
        DateTime(2026, 3, 2),
        31,
      );

      expect(monthStartOf(result.slot), DateTime(2026, 2));
      expect(result.offset, 2);
    });
  });

  group("normalizeTitle", () {
    test("lowercases, trims and drops punctuation", () {
      expect(normalizeTitle("  Spotify  "), "spotify");
      expect(normalizeTitle("SPOTIFY*Premium"), "spotify premium");
    });

    test("drops tokens with digits, like references and dates", () {
      expect(normalizeTitle("NETFLIX #1234"), "netflix");
      expect(normalizeTitle("Rent 2026-09"), "rent");
    });

    test("keeps non-Latin letters", () {
      expect(normalizeTitle("Түрээс"), "түрээс");
    });

    test("is null when nothing is left", () {
      expect(normalizeTitle(null), isNull);
      expect(normalizeTitle(""), isNull);
      expect(normalizeTitle("12345"), isNull);
      expect(normalizeTitle(" -- "), isNull);
    });
  });
}

import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/prefs/custom_cycles.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("TransactionFilterTimeRange", () {
    test("current cycle resolves relative to the active billing window", () {
      final DateTime anchor = DateTime(2025, 5, 15);

      final range = TransactionFilterTimeRange.resolveMonthCycle(
        anchor: anchor,
        value: "cycle:month:21:20:current",
      );

      expect(range.from, DateTime(2025, 4, 21));
      expect(
        range.to,
        DateTime(2025, 5, 20, 23, 59, 59, 999, 999),
      );
    });

    test("current cycle moves into the next month after the cycle day", () {
      final DateTime anchor = DateTime(2025, 5, 25);

      final range = TransactionFilterTimeRange.resolveMonthCycle(
        anchor: anchor,
        value: "cycle:month:21:20:current",
      );

      expect(range.from, DateTime(2025, 5, 21));
      expect(
        range.to,
        DateTime(2025, 6, 20, 23, 59, 59, 999, 999),
      );
    });

    test("selected month custom cycle resolves from the prior month to the selected month end", () {
      final CustomCycle cycle = CustomCycle(
        id: "cycle-1",
        name: "Main cycle",
        startDay: 21,
        endDay: 20,
      );

      final range = TransactionFilterTimeRange.resolveCustomCycleMonth(
        month: DateTime(2026, 10, 1),
        cycle: cycle,
      );

      expect(range.from, DateTime(2026, 9, 21));
      expect(
        range.to,
        DateTime(2026, 10, 20, 23, 59, 59, 999, 999),
      );
    });
  });
}

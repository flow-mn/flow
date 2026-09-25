import "dart:math" as math;

import "package:flow/data/insights/insight_engine.dart";

/// Builds [InsightTransaction]s with predictable, sortable uuids.
class TestLedger {
  final List<InsightTransaction> transactions = [];

  int _counter = 0;

  String _nextUuid() => "t${(_counter++).toString().padLeft(6, "0")}";

  InsightTransaction spend(
    DateTime date,
    double amount, {
    String? title,
    String? category = "misc",
    String? account = "checking",
    String? recurringUuid,
    bool isTransfer = false,
    bool isPending = false,
  }) => _add(
    InsightTransaction(
      uuid: _nextUuid(),
      date: date,
      amount: -amount.abs(),
      title: title,
      categoryUuid: category,
      accountUuid: account,
      recurringUuid: recurringUuid,
      isTransfer: isTransfer,
      isPending: isPending,
    ),
  );

  InsightTransaction earn(
    DateTime date,
    double amount, {
    String? title,
    String? category = "salary",
  }) => _add(
    InsightTransaction(
      uuid: _nextUuid(),
      date: date,
      amount: amount.abs(),
      title: title,
      categoryUuid: category,
      accountUuid: "checking",
    ),
  );

  InsightTransaction _add(InsightTransaction transaction) {
    transactions.add(transaction);
    return transaction;
  }

  /// [count] untitled expenses of [each], spread over the month.
  void flatMonth(
    int year,
    int month, {
    int count = 10,
    double each = 100.0,
    String category = "misc",
    int throughDay = 31,
  }) {
    final int days = DateTime(year, month + 1, 0).day;

    for (int i = 0; i < count; i++) {
      final int day = 1 + (i * days) ~/ count;
      if (day > throughDay) continue;

      spend(DateTime(year, month, day, 12), each, category: category);
    }
  }

  /// A realistic month: tracked rent, Spotify, groceries, dining, transport
  /// and coffee, with seeded noise.
  void steadyMonth(
    int year,
    int month,
    math.Random random, {
    int throughDay = 31,
  }) {
    final int days = DateTime(year, month + 1, 0).day;

    void add(
      int day,
      double amount,
      String title,
      String category, {
      String? recurringUuid,
    }) {
      if (day > throughDay) return;

      spend(
        DateTime(year, month, math.min(day, days), 12),
        amount,
        title: title,
        category: category,
        recurringUuid: recurringUuid,
      );
    }

    add(1, 1200.0, "Rent", "housing", recurringUuid: "rent");
    add(3, 11.99, "Spotify", "subscriptions");

    for (int i = 0; i < 4; i++) {
      add(2 + i * 7, 70.0 + random.nextDouble() * 20, "Grocer", "groceries");
    }

    const List<String> diners = ["Noodle bar", "Pizzeria", "Taqueria", "Cafe"];
    for (int i = 0; i < 5; i++) {
      add(
        4 + i * 6,
        25.0 + random.nextDouble() * 15,
        diners[random.nextInt(diners.length)],
        "dining",
      );
    }

    for (int i = 0; i < 6; i++) {
      add(2 + i * 5, 12.0 + random.nextDouble() * 6, "Metro", "transport");
    }

    for (int i = 0; i < 10; i++) {
      add(1 + i * 3, 4.5, "Coffee", "coffee");
    }
  }

  InsightReport analyze(
    DateTime month, {
    required DateTime now,
    List<InsightRecurringTemplate> templates = const [],
    Set<InsightType> hiddenTypes = const {},
    List<InsightSighting> sightings = const [],
    int limit = 3,
  }) => computeInsights(
    InsightRequest(
      transactions: transactions,
      month: month,
      now: now,
      recurringTemplates: templates,
      hiddenTypes: hiddenTypes,
      sightings: sightings,
      limit: limit,
    ),
  );
}

/// Every number an insight carries, for NaN/infinity checks.
List<double> numbersOf(Insight insight) => [
  insight.score,
  insight.stake,
  ...switch (insight) {
    MonthPaceInsight() => [
      insight.current,
      insight.usual,
      insight.ratio,
      ?insight.ratioWithoutAttribution,
      ...insight.history.map((value) => value.amount),
      ...insight.drivers.expand((d) => [d.current, d.usual]),
    ],
    CategorySpikeInsight() => [
      insight.current,
      insight.usual,
      insight.ratio,
      ...insight.history.map((value) => value.amount),
    ],
    CategoryDropInsight() => [
      insight.current,
      insight.usual,
      insight.ratio,
      ...insight.history.map((value) => value.amount),
    ],
    NewCategoryInsight() => [insight.current],
    RecurringChargeInsight() => [
      insight.series.typicalAmount,
      insight.series.annualCost,
    ],
    PriceChangeInsight() => [
      insight.previousAmount,
      insight.currentAmount,
      insight.ratio,
    ],
  },
];

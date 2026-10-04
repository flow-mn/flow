import "dart:io";
import "dart:math";

import "package:flow/data/insights/insight_adapter.dart";
import "package:flow/data/insights/insight_engine.dart";
import "package:flow/data/setup/default_accounts.dart";
import "package:flow/data/setup/default_categories.dart";
import "package:flow/data/setup/demo_data.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/objectbox.dart";
import "package:flow/services/insights.dart";
import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as path;

import "objectbox_erase.dart";

/// Runs the insight engine over the demo data, month by month, the way the
/// Stats tab would. Worth running under a few `TZ`s.
void main() {
  late ObjectBox obx;
  late List<Category> categories;
  late List<Account> accounts;

  final String directory = path.join(
    Directory.current.path,
    ".objectbox_test_insights",
  );

  final DateTime now = DateTime(2026, 9, 25, 15, 30);

  const List<String> monthlyBills = [
    "Rent",
    "Gym membership",
    "iCloud+",
    "Netflix",
    "Internet",
    "Spotify",
    "ChatGPT Plus",
  ];

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    await FlowLocalizations(const Locale("en")).load();

    obx = await ObjectBox.initialize(
      customDirectory: directory,
      subdirectory: "insights",
    );

    categories = await obx.box<Category>().putAndGetManyAsync(
      getCategoryPresets().map((category) => category..id = 0).toList(),
    );
    accounts = await obx.box<Account>().putAndGetManyAsync([
      ...getAccountPresets("USD").map((account) => account..id = 0),
      Account.preset(
        name: "Credit Card",
        currency: "USD",
        iconCode: "credit_card",
        uuid: "credit-card",
        type: AccountType.creditLineValue,
        creditLimit: 5000,
        excludeFromTotalBalance: true,
      )..id = 0,
    ]);
  });

  tearDownAll(() async {
    await testCleanupObject(
      instance: obx,
      directory: path.join(directory, "insights"),
    );
  });

  List<Transaction> generate(int seed) {
    final [main, cash, savings, creditCard] = accounts;

    return DemoDataGenerator(
      main: main,
      cash: cash,
      savings: savings,
      creditCard: creditCard,
      categories: categories,
      tags: const {},
      random: Random(seed),
      now: now,
    ).generate();
  }

  /// The last 12 months, each with the history the Stats tab would load.
  Map<DateTime, InsightReport> reports(List<Transaction> transactions) {
    final List<InsightTransaction> all = insightTransactionsOf(
      transactions,
      primaryCurrency: "USD",
      rates: null,
    ).transactions;

    return {
      for (int back = 0; back < 12; back++)
        DateTime(now.year, now.month - back): computeInsights(
          InsightRequest(
            transactions: all.where((transaction) {
              final DateTime month = DateTime(now.year, now.month - back);
              final DateTime from = DateTime(
                month.year,
                month.month - InsightsService.historyMonths,
              );

              return !transaction.date.isBefore(from) &&
                  transaction.date.isBefore(
                    DateTime(month.year, month.month + 1),
                  );
            }).toList(),
            month: DateTime(now.year, now.month - back),
            now: now,
            limit: 9,
          ),
        ),
    };
  }

  test("every monthly bill is charged once a month", () {
    final List<Transaction> transactions = generate(1);

    for (int back = 1; back < 36; back++) {
      final DateTime month = DateTime(now.year, now.month - back);

      for (final String title in monthlyBills) {
        expect(
          transactions.where(
            (transaction) =>
                transaction.title == title &&
                transaction.transactionDate.year == month.year &&
                transaction.transactionDate.month == month.month,
          ),
          hasLength(1),
          reason: "$title in $month",
        );
      }
    }
  });

  for (int seed = 1; seed <= 3; seed++) {
    group("seed $seed", () {
      late String? rentCategory;
      late Map<DateTime, InsightReport> byMonth;

      setUpAll(() {
        final List<Transaction> transactions = generate(seed);

        rentCategory = transactions
            .firstWhere((transaction) => transaction.title == "Rent")
            .categoryUuid;
        byMonth = reports(transactions);
      });

      test("tracking is only suggested for this month", () {
        for (final MapEntry(key: month, value: report) in byMonth.entries) {
          final List<RecurringChargeInsight> suggestions = report.insights
              .whereType<RecurringChargeInsight>()
              .toList();

          if (month.month != now.month) {
            expect(suggestions, isEmpty, reason: "$month");
            continue;
          }

          final RecurringSeries rent = suggestions.single.series;
          expect(rent.title, "Rent");
          expect(rent.typicalAmount, 1690.0);
          expect(rent.occurrences.last.date.month, now.month);
          expect(rent.occurrences.last.date.day, 1);
        }
      });

      test("regular bills never explain a month", () {
        for (final MapEntry(key: month, value: report) in byMonth.entries) {
          for (final Insight insight in report.insights) {
            final InsightAttribution? attribution = switch (insight) {
              MonthPaceInsight pace => pace.attribution,
              CategorySpikeInsight spike => spike.attribution,
              _ => null,
            };

            expect(
              monthlyBills,
              isNot(contains(attribution?.title)),
              reason: "$month: ${insight.key}",
            );

            if (insight case MonthPaceInsight pace) {
              expect(
                pace.dominantDriver?.categoryUuid,
                isNot(rentCategory),
                reason: "$month",
              );
            }
          }
        }
      });

      test("the rent raise shows in its month only", () {
        for (final MapEntry(key: month, value: report) in byMonth.entries) {
          final List<PriceChangeInsight> changes = report.insights
              .whereType<PriceChangeInsight>()
              .toList();

          if (month != DateTime(2025, 10)) {
            expect(changes, isEmpty, reason: "$month");
            continue;
          }

          expect(changes.single.series.title, "Rent");
          expect(changes.single.previousAmount, 1590.0);
          expect(changes.single.currentAmount, 1690.0);
        }
      });

      test("every insight is shown once", () {
        for (final MapEntry(key: month, value: report) in byMonth.entries) {
          expect(report.status, InsightReportStatus.ready, reason: "$month");
          expect(
            report.insights.map((insight) => insight.key).toSet(),
            hasLength(report.insights.length),
            reason: "$month",
          );
        }
      });
    });
  }
}

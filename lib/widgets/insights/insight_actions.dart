import "package:flow/data/insights/insight_engine.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/providers/categories_provider.dart";
import "package:flow/services/transactions.dart";
import "package:flutter/widgets.dart";
import "package:go_router/go_router.dart";
import "package:moment_dart/moment_dart.dart";
import "package:recurrence/recurrence.dart";

/// Where Worth knowing rows lead to.
abstract final class InsightActions {
  /// Opens the latest charge with its recurrence filled in, so saving it
  /// starts tracking the series from there.
  static Future<void> trackAsRecurring(
    BuildContext context,
    RecurringSeries series,
  ) async {
    final Transaction? latest = TransactionsService().findByIdentifierSync(
      series.occurrences.last.transactionUuid,
    );
    if (latest == null) return;

    final DateTime date = latest.transactionDate;

    final Recurrence recurrence = Recurrence.fromIndefinitely(
      rules: [
        switch (series.cadence) {
          .weekly => RecurrenceRule.weekly(date.weekday),
          .monthly => RecurrenceRule.monthly(date.day),
          .yearly => RecurrenceRule.yearly(date.month, date.day),
        },
      ],
      start: date,
    );

    await context.push(
      "/transaction/${latest.id}?recurrence=${Uri.encodeQueryComponent(recurrence.serialize())}",
    );
  }

  /// A list of the transactions behind [insight], or null if there's no
  /// better list than the evidence itself.
  static String? transactionsPath(
    BuildContext context,
    Insight insight,
    InsightReport report,
  ) {
    final String range = Uri.encodeQueryComponent(
      MonthTimeRange.fromDateTime(report.month).encodeShort(),
    );

    final String? categoryUuid = switch (insight) {
      CategorySpikeInsight spike => spike.categoryUuid,
      CategoryDropInsight drop => drop.categoryUuid,
      NewCategoryInsight newCategory => newCategory.categoryUuid,
      _ => null,
    };

    if (categoryUuid != null) {
      final Category? category = CategoriesProvider.of(
        context,
      ).get(categoryUuid);

      return category == null ? null : "/category/${category.id}?range=$range";
    }

    return switch (insight) {
      MonthPaceInsight() => "/transactions?range=$range",
      _ => null,
    };
  }
}

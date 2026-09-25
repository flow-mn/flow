import "package:flow/data/flow_icon.dart";
import "package:flow/data/insights/insight_engine.dart";
import "package:flow/data/insights/insight_thresholds.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/providers/categories_provider.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/insights/insight_formatter.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// What a Worth knowing row says about an [Insight]: one sentence with an
/// emphasized figure, and one line of context.
class InsightSummary {
  /// Holds a `{value}` token for [value], see `EmphasizedText`.
  final String template;
  final String value;
  final String detail;

  final FlowIconData icon;

  /// Whether spending went up. Null for insights that aren't a change.
  final bool? increase;

  /// Past values, oldest first, ending with the current one.
  final List<double>? spark;

  const InsightSummary({
    required this.template,
    required this.value,
    required this.detail,
    required this.icon,
    this.increase,
    this.spark,
  });

  /// A day of month as `{day}` ("25th") and `{dayNumber}` ("25"), for
  /// languages without ordinal formatting.
  static Map<String, String> dayValues(int day) => {
    "day": DateTime(2000, 1, day).toMoment().format("Do"),
    "dayNumber": day.toString(),
  };

  /// The sentence without emphasis.
  String get sentence => template.replaceAll("{value}", value);

  /// Follows the user's change colors.
  Color valueColor(BuildContext context) {
    final bool? increase = this.increase;
    if (increase == null) return context.colorScheme.primary;

    final bool redWhenUp =
        UserPreferencesService().changeVisuals.expenseIncreaseRed;

    return increase == redWhenUp
        ? context.flowColors.expense
        : context.flowColors.income;
  }

  factory InsightSummary.of(
    BuildContext context, {
    required Insight insight,
    required InsightReport report,
    required InsightFormatter format,
  }) => _InsightSummaryBuilder(
    context,
    report: report,
    format: format,
  ).build(insight);
}

class _InsightSummaryBuilder {
  static const String _prefix = "tabs.stats.worthKnowing";
  static const int _maxSparkCharges = 7;

  final BuildContext context;
  final InsightReport report;
  final InsightFormatter format;

  const _InsightSummaryBuilder(
    this.context, {
    required this.report,
    required this.format,
  });

  bool get _past => !report.isInProgress;

  String get _month => report.month.toMoment().format("MMMM");

  String _t(String key, [dynamic replace]) =>
      "$_prefix.$key".t(context, replace);

  Category? _category(String? uuid) =>
      uuid == null ? null : CategoriesProvider.of(context).get(uuid);

  String _categoryName(String? uuid) =>
      _category(uuid)?.name ?? "tabs.stats.analytics.uncategorized".t(context);

  FlowIconData _categoryIcon(String? uuid) =>
      _category(uuid)?.icon ?? FlowIconData.icon(Symbols.category_rounded);

  String _untitled(String? title) => switch (title) {
    String title when title.trim().isNotEmpty => title,
    _ => "tabs.stats.analytics.untitled".t(context),
  };

  String _versus(double current, double usual) => _t("versusTypical", {
    "current": format.money(current),
    "usual": format.money(usual),
  });

  List<double> _spark(List<InsightMonthValue> history, double current) => [
    ...history.map((month) => month.amount),
    current,
  ];

  InsightSummary build(Insight insight) => switch (insight) {
    MonthPaceInsight pace => _monthPace(pace),
    CategorySpikeInsight spike => _categorySpike(spike),
    CategoryDropInsight drop => _categoryDrop(drop),
    NewCategoryInsight newCategory => _newCategory(newCategory),
    RecurringChargeInsight recurring => _recurringCharge(recurring),
    PriceChangeInsight priceChange => _priceChange(priceChange),
  };

  InsightSummary _monthPace(MonthPaceInsight pace) {
    final bool above = pace.direction == .above;
    final bool upArrow =
        above == UserPreferencesService().changeVisuals.expenseIncreaseUpArrow;

    final String key = switch ((above, _past)) {
      (true, false) => "monthAbove",
      (false, false) => "monthBelow",
      (true, true) => "monthAbovePast",
      (false, true) => "monthBelowPast",
    };

    return InsightSummary(
      template: _t(key, {
        "month": _month,
        if (pace.throughDay case int day) ...InsightSummary.dayValues(day),
      }),
      value: format.percent(pace.ratio - 1.0),
      detail: _monthPaceDetail(pace),
      icon: FlowIconData.icon(
        upArrow ? Symbols.trending_up_rounded : Symbols.trending_down_rounded,
      ),
      increase: above,
      spark: _spark(pace.history, pace.current),
    );
  }

  String _monthPaceDetail(MonthPaceInsight pace) {
    final InsightAttribution? attribution = pace.attribution;

    if (attribution != null) {
      final double ratio = pace.ratioWithoutAttribution!;
      final Map<String, String> values = {
        "title": switch (attribution.title) {
          String title when title.trim().isNotEmpty => title,
          _ => _categoryName(attribution.categoryUuid),
        },
        "amount": format.money(attribution.amount),
        "percent": format.percent(ratio - 1.0),
      };

      return switch (ratio) {
        < 0.995 => _t("mostlyUnder", values),
        > 1.005 => _t("mostlyOver", values),
        _ => _t("mostlyEven", values),
      };
    }

    if (pace.dominantDriver case InsightCategoryDelta driver) {
      return _t("mostlyCategory", {
        "category": _categoryName(driver.categoryUuid),
        "difference": _difference(driver.delta),
      });
    }

    return _versus(pace.current, pace.usual);
  }

  String _difference(double delta) => _t(
    delta >= 0.0 ? "moreThanUsual" : "lessThanUsual",
    {"amount": format.money(delta)},
  );

  InsightSummary _categorySpike(CategorySpikeInsight spike) => InsightSummary(
    template: _t(_past ? "categorySpikePast" : "categorySpike", {
      "category": _categoryName(spike.categoryUuid),
    }),
    value: format.ratio(spike.ratio),
    detail: [
      _versus(spike.current, spike.usual),
      _t("entries", spike.entryCount),
    ].join(" · "),
    icon: _categoryIcon(spike.categoryUuid),
    increase: true,
    spark: _spark(spike.history, spike.current),
  );

  InsightSummary _categoryDrop(CategoryDropInsight drop) => InsightSummary(
    template: _t(_past ? "categoryDropPast" : "categoryDrop", {
      "category": _categoryName(drop.categoryUuid),
    }),
    value: format.percent(1.0 - drop.ratio),
    detail: _versus(drop.current, drop.usual),
    icon: _categoryIcon(drop.categoryUuid),
    increase: false,
    spark: _spark(drop.history, drop.current),
  );

  InsightSummary _newCategory(NewCategoryInsight insight) => InsightSummary(
    template: _t("newCategory", {"months": InsightThresholds.baselineMonths}),
    value: _categoryName(insight.categoryUuid),
    detail: [
      format.money(insight.current),
      _t("entries", insight.entryCount),
    ].join(" · "),
    icon: _categoryIcon(insight.categoryUuid),
  );

  InsightSummary _recurringCharge(RecurringChargeInsight insight) {
    final RecurringSeries series = insight.series;

    final Map<String, String> values = {
      "amount": format.money(series.typicalAmount),
      "times": _t("times", series.occurrences.length),
      ...InsightSummary.dayValues(series.anchorDay),
      "weekday": DateTime(2024, 1, series.anchorDay).toMoment().format("dddd"),
      "date": series.occurrences.last.date.toMoment().format("MMMM Do"),
    };

    final String cadence = switch (series.cadence) {
      .weekly => "Weekly",
      .monthly => "Monthly",
      .yearly => "Yearly",
    };

    return InsightSummary(
      template: _t("recurring$cadence"),
      value: _untitled(series.title),
      detail: _t("recurring${cadence}Detail", values),
      icon: FlowIconData.icon(Symbols.autorenew_rounded),
    );
  }

  InsightSummary _priceChange(PriceChangeInsight insight) => InsightSummary(
    template: _t("priceChange", {
      "title": _untitled(insight.series.title),
      "previous": format.money(insight.previousAmount),
    }),
    value: format.money(insight.currentAmount),
    detail: _t(
      insight.currentAmount >= insight.previousAmount ? "priceUp" : "priceDown",
      {"amount": format.money(insight.stake)},
    ),
    icon: FlowIconData.icon(Symbols.price_change_rounded),
    increase: insight.currentAmount >= insight.previousAmount,
    spark: insight.series.occurrences.reversed
        .take(_maxSparkCharges)
        .map((occurrence) => occurrence.amount)
        .toList()
        .reversed
        .toList(),
  );
}

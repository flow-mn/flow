import "package:flow/data/flow_analytics.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/reports/trends_report.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/analytics/insight_card.dart";
import "package:flow/widgets/analytics/weekday_bars.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/stats/emphasized_text.dart";
import "package:flow/widgets/stats/missing_rates_notice.dart";
import "package:flow/widgets/stats/stats_app_bar.dart";
import "package:flow/widgets/stats/stats_empty_state.dart";
import "package:flow/widgets/stats/wrapped/mini_bars.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Monthly "wrapped" — narrative insight cards instead of raw charts.
///
/// Combines [TrendsReport] (median spend, top titles) with a
/// period-over-period category comparison and a locally-computed weekday
/// breakdown.
class WrappedPage extends StatefulWidget {
  const WrappedPage({super.key});

  @override
  State<WrappedPage> createState() => _WrappedPageState();
}

class _WrappedPageState extends State<WrappedPage>
    with PrimaryCurrencyDependentState<WrappedPage> {
  bool busy = false;
  bool missingRates = false;

  /// The period being "wrapped". The selector pages this; the insight cards
  /// compare it against its trailing periods (see [_recentPeriods]).
  TimeRange range = TimeRange.thisMonth();

  List<Transaction> thisMonthTransactions = [];
  TrendsReport? trends;

  Category? topCategory;
  double topCategoryCurrent = 0.0;
  double topCategoryAverage = 0.0;
  List<double> topCategoryHistory = [];

  /// Weekday (1 = Mon .. 7 = Sun) -> summed expense, computed locally.
  ///
  /// [TrendsReport.expenseByWeekday] is declared but never populated, so its
  /// `topSpendingWeekday` always returns null; we compute weekday spend here.
  Map<int, double> weekdayExpense = {};
  Transaction? biggestExpense;
  double biggestExpenseConverted = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StatsAppBar(title: "tabs.stats.analytics.wrapped".t(context)),
      body: SafeArea(
        child: Column(
          children: [
            Frame.standalone(
              child: TimeRangeSelector(
                initialValue: range,
                onChanged: _updateRange,
              ),
            ),
            Expanded(
              child: busy && trends == null
                  ? const Spinner.center()
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          const SizedBox(height: 8.0),
                          if (thisMonthTransactions.isEmpty)
                            StatsEmptyState(
                              message:
                                  "tabs.stats.analytics.wrapped.noTransactions"
                                      .t(context),
                            )
                          else
                            ..._buildInsightCards(context),
                          if (missingRates) ...[
                            const SizedBox(height: 8.0),
                            MissingRatesNotice(
                              message:
                                  "tabs.stats.analytics.missingRatesAmounts".t(
                                    context,
                                  ),
                            ),
                          ],
                          const SizedBox(height: 96.0),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateRange(TimeRange value) {
    if (value == range) return;
    range = value;
    fetch();
  }

  List<Widget> _buildInsightCards(BuildContext context) {
    return [
      if (topCategory != null || topCategoryCurrent > 0)
        _buildCategoryTrendCard(context),
      if (trends?.sortedTitlesByFrequency.isNotEmpty == true)
        _buildTopMerchantCard(context),
      if (weekdayExpense.isNotEmpty) _buildWeekdayCard(context),
      _buildSpendShapeCard(context),
    ];
  }

  Widget _buildCategoryTrendCard(BuildContext context) {
    final double avg = topCategoryAverage;
    final double current = topCategoryCurrent;
    final bool up = current >= avg;
    final double deltaPct = avg <= 0 ? 0.0 : ((current - avg) / avg) * 100.0;
    final Color accent = up
        ? context.flowColors.expense
        : context.flowColors.income;

    final String name =
        topCategory?.name ?? "tabs.stats.analytics.uncategorized".t(context);
    final String direction = up
        ? "tabs.stats.analytics.up".t(context)
        : "tabs.stats.analytics.down".t(context);
    // The {value} token is left for [EmphasizedText]; the Map fill only
    // replaces the named tokens it's given.
    final String template = "tabs.stats.analytics.wrapped.categoryTrend".t(
      context,
      {"name": name, "direction": direction},
    );

    return InsightCard(
      icon: Symbols.lunch_dining_rounded,
      label: "tabs.stats.analytics.wrapped.label.category".t(context),
      accent: accent,
      title: EmphasizedText(
        template: template,
        value: "${deltaPct.abs().toStringAsFixed(0)}%",
        valueStyle: TextStyle(color: accent, fontWeight: FontWeight.bold),
      ),
      subtitle: "tabs.stats.analytics.wrapped.categorySubtitle".t(context, {
        "current": Money(current, primaryCurrency).formatted,
        "typical": Money(avg, primaryCurrency).formatted,
      }),
      child: MiniBars(values: topCategoryHistory, highlightColor: accent),
    );
  }

  Widget _buildTopMerchantCard(BuildContext context) {
    final MapEntry<String, int> top = trends!.sortedTitlesByFrequency.first;

    return InsightCard(
      icon: Symbols.storefront_rounded,
      label: "tabs.stats.analytics.wrapped.label.frequent".t(context),
      title: EmphasizedText(
        template: "tabs.stats.analytics.wrapped.frequentEntry".t(context),
        value: top.key,
      ),
      subtitle: "tabs.stats.analytics.wrapped.loggedTimes".t(context, {
        "count": top.value,
      }),
    );
  }

  Widget _buildWeekdayCard(BuildContext context) {
    final int topWeekday = weekdayExpense.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    return InsightCard(
      icon: Symbols.calendar_month_rounded,
      label: "tabs.stats.analytics.rhythm".t(context),
      title: EmphasizedText(
        template: "tabs.stats.analytics.wrapped.spendMostOn".t(context),
        value: _weekdayName(topWeekday),
      ),
      child: WeekdayBars(
        byWeekday: weekdayExpense,
        topWeekday: topWeekday,
        accent: context.colorScheme.primary,
      ),
    );
  }

  Widget _buildSpendShapeCard(BuildContext context) {
    final Money median =
        trends?.medianExpensePerTransaction ?? Money(0.0, primaryCurrency);

    final String biggestLine = biggestExpense == null
        ? "tabs.stats.analytics.wrapped.noExpenses".t(context)
        : "tabs.stats.analytics.wrapped.biggest".t(context, {
            "title":
                biggestExpense!.title ??
                "tabs.stats.analytics.untitled".t(context),
            "amount": Money(biggestExpenseConverted, primaryCurrency).formatted,
            "date": biggestExpense!.transactionDate.toMoment().format("MMM D"),
          });

    return InsightCard(
      icon: Symbols.bar_chart_rounded,
      label: "tabs.stats.analytics.wrapped.label.shape".t(context),
      title: EmphasizedText(
        template: "tabs.stats.analytics.wrapped.medianPurchase".t(context),
        value: median.formatted,
      ),
      subtitle: biggestLine,
    );
  }

  @override
  Future<void> fetch() async {
    if (!mounted) return;
    setState(() {
      busy = true;
    });

    bool missing = false;

    try {
      final List<TimeRange> periods = _recentPeriods(range, 4);

      final FlowAnalytics<Category?> current = await ObjectBox()
          .flowByCategories(range: periods.first);
      final List<FlowAnalytics<Category?>> previous = [];
      for (final TimeRange period in periods.skip(1)) {
        previous.add(await ObjectBox().flowByCategories(range: period));
      }

      thisMonthTransactions = await ObjectBox().transcationsByRange(
        periods.first,
        includeTransfers: false,
      );

      trends = TrendsReport(
        rates: rates,
        primaryCurrency: primaryCurrency,
        transactions: thisMonthTransactions,
      );

      missing = missing || _computeTopCategory(current, previous);
      missing = missing || _computeWeekdayAndBiggest();

      missingRates = missing;
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }

  /// Picks the biggest expense category this month and its 3-month average.
  ///
  /// Returns whether any currency conversion was skipped.
  bool _computeTopCategory(
    FlowAnalytics<Category?> current,
    List<FlowAnalytics<Category?>> previous,
  ) {
    String? topUuid;
    double topExpense = 0.0;
    Category? category;

    for (final MapEntry<String, dynamic> entry in current.flow.entries) {
      final double expense = _categoryExpense(current, entry.key);
      if (expense > topExpense) {
        topExpense = expense;
        topUuid = entry.key;
        category = current.flow[entry.key]?.associatedData;
      }
    }

    topCategory = category;
    topCategoryCurrent = topExpense;

    // Merging swallows unconvertible foreign currency (sets hasMissingData
    // rather than throwing), so check every month's flows to surface the
    // "amounts were skipped" banner when the numbers are under-counted.
    final bool missing = [current, ...previous].any(
      (analytics) => analytics.flow.values.any(
        (flow) => flow.merge(primaryCurrency, rates).hasMissingData,
      ),
    );

    if (topUuid == null) {
      topCategoryAverage = 0.0;
      topCategoryHistory = [];
      return missing;
    }

    final List<double> history = previous.reversed
        .map((flow) => _categoryExpense(flow, topUuid!))
        .toList();
    history.add(topExpense);

    topCategoryHistory = history;
    topCategoryAverage = previous.isEmpty
        ? 0.0
        : previous
                  .map((flow) => _categoryExpense(flow, topUuid!))
                  .fold<double>(0.0, (a, b) => a + b) /
              previous.length;

    return missing;
  }

  double _categoryExpense(FlowAnalytics<Category?> analytics, String uuid) {
    final flow = analytics.flow[uuid];
    if (flow == null) return 0.0;
    return flow.merge(primaryCurrency, rates).totalExpense.amount.abs();
  }

  bool _computeWeekdayAndBiggest() {
    bool missing = false;
    final Map<int, double> byWeekday = {};

    Transaction? biggest;
    double biggestAmount = 0.0;

    for (final Transaction transaction in thisMonthTransactions) {
      if (transaction.type != TransactionType.expense) continue;

      final double? converted = transaction.money.tryConvertAmount(
        primaryCurrency,
        rates,
      );
      if (converted == null) {
        missing = true;
        continue;
      }

      final double magnitude = converted.abs();
      final int weekday = transaction.transactionDate.weekday;
      byWeekday[weekday] = (byWeekday[weekday] ?? 0.0) + magnitude;

      if (magnitude > biggestAmount) {
        biggestAmount = magnitude;
        biggest = transaction;
      }
    }

    weekdayExpense = byWeekday;
    biggestExpense = biggest;
    biggestExpenseConverted = biggestAmount;

    return missing;
  }

  /// The selected [anchor] plus the [count] - 1 immediately preceding periods,
  /// newest first.
  ///
  /// Pageable ranges (week/month/year) page backwards via [PageableRange.last].
  /// Non-pageable custom ranges fall back to equal-length preceding spans so the
  /// period-over-period comparison degrades sensibly instead of repeating the
  /// same range. Unbounded ranges (all-time) have no meaningful preceding
  /// period — and their span overflows [DateTime] arithmetic — so the list
  /// simply stops at the anchor.
  List<TimeRange> _recentPeriods(TimeRange anchor, int count) {
    final List<TimeRange> periods = [anchor];
    for (int i = 1; i < count; i++) {
      final TimeRange previous = periods.last;
      if (previous is PageableRange) {
        periods.add(previous.last);
      } else {
        if (previous.from <= Moment.minValue ||
            previous.to >= Moment.maxValue) {
          break;
        }
        final Duration span = previous.duration;
        periods.add(
          CustomTimeRange(previous.from.subtract(span), previous.from),
        );
      }
    }
    return periods;
  }

  String _weekdayName(int weekday) {
    // 1 == Monday .. 7 == Sunday (DateTime.weekday).
    return DateTime(2024, 1, weekday).toMoment().format("dddd");
  }
}

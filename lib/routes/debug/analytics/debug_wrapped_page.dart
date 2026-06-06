import "package:flow/data/exchange_rates.dart";
import "package:flow/data/flow_analytics.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/budget.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/reports/trends_report.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/debug/analytics/bullet_chart.dart";
import "package:flow/widgets/debug/analytics/insight_card.dart";
import "package:flow/widgets/debug/analytics/weekday_bars.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// [dev] Monthly "wrapped" — narrative insight cards instead of raw charts.
///
/// Activates two dormant pieces of Flow: [TrendsReport] (median spend, top
/// titles) and the unused [Budget] entity (rendered as a bullet chart). The
/// remaining cards are period-over-period category comparison and a
/// locally-computed weekday breakdown.
class DebugWrappedPage extends StatefulWidget {
  const DebugWrappedPage({super.key});

  @override
  State<DebugWrappedPage> createState() => _DebugWrappedPageState();
}

class _BudgetProgress {
  final Budget budget;
  final double actual;

  const _BudgetProgress(this.budget, this.actual);
}

class _DebugWrappedPageState extends State<DebugWrappedPage> {
  bool busy = false;
  bool missingRates = false;

  late String primaryCurrency;
  ExchangeRates? rates;

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

  List<_BudgetProgress> budgets = [];

  @override
  void initState() {
    super.initState();

    primaryCurrency = UserPreferencesService().primaryCurrency;
    rates = ExchangeRatesService().getPrimaryCurrencyRates();

    fetch();
  }

  @override
  Widget build(BuildContext context) {
    final String month = DateTime.now().toMoment().format("MMMM");

    return Scaffold(
      appBar: AppBar(
        title: Text("$month, wrapped (dev)"),
        elevation: 0.0,
        scrolledUnderElevation: 1.0,
        centerTitle: false,
        shadowColor: context.colorScheme.onSurface.withAlpha(0x40),
        backgroundColor: context.colorScheme.surface,
        surfaceTintColor: kTransparent,
      ),
      body: SafeArea(
        child: busy && trends == null
            ? const Spinner.center()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8.0),
                    _DevToolbar(
                      canCreate: topCategory != null,
                      onCreate: _createSampleBudget,
                      onClear: _clearDevBudgets,
                    ),
                    // Budgets stand on their own range, so they show even when
                    // the current month has no transactions yet.
                    ..._buildBudgetCards(context),
                    if (thisMonthTransactions.isEmpty)
                      const Frame(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 48.0),
                          child: Center(
                            child: Text("No transactions yet this month."),
                          ),
                        ),
                      )
                    else
                      ..._buildInsightCards(context),
                    if (missingRates) ...[
                      const SizedBox(height: 8.0),
                      Frame(
                        child: Text(
                          "Some non-primary currency amounts were skipped "
                          "(missing exchange rates).",
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.flowColors.expense,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 96.0),
                  ],
                ),
              ),
      ),
    );
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

  List<Widget> _buildBudgetCards(BuildContext context) {
    if (budgets.isEmpty) {
      return [
        InsightCard(
          icon: Symbols.savings_rounded,
          label: "Budget",
          title: const Text("No budgets yet"),
          subtitle:
              "The Budget entity is modeled but unused. Create a sample "
              "budget above to see budget-vs-actual.",
        ),
      ];
    }

    return budgets.map((progress) {
      final Budget budget = progress.budget;
      final Money actual = Money(progress.actual, budget.currency);
      final Money limit = Money(budget.amount, budget.currency);
      final bool over = progress.actual > budget.amount;
      final double remaining = budget.amount - progress.actual;

      return InsightCard(
        icon: Symbols.savings_rounded,
        label: "Budget",
        accent: over ? context.flowColors.expense : context.flowColors.income,
        title: Row(
          children: [
            Expanded(child: Text(budget.name)),
            MoneyText(actual, style: context.textTheme.titleSmall),
            Text(
              " / ",
              style: context.textTheme.titleSmall?.copyWith(
                color: context.colorScheme.onSecondary.withAlpha(0x80),
              ),
            ),
            MoneyText(
              limit,
              style: context.textTheme.titleSmall?.copyWith(
                color: context.colorScheme.onSecondary.withAlpha(0x80),
              ),
            ),
          ],
        ),
        subtitle: over
            ? "Over by ${Money(-remaining, budget.currency).formatted}"
            : "${Money(remaining, budget.currency).formatted} left",
        child: BulletChart(value: progress.actual, target: budget.amount),
      );
    }).toList();
  }

  Widget _buildCategoryTrendCard(BuildContext context) {
    final double avg = topCategoryAverage;
    final double current = topCategoryCurrent;
    final bool up = current >= avg;
    final double deltaPct = avg <= 0 ? 0.0 : ((current - avg) / avg) * 100.0;
    final Color accent = up
        ? context.flowColors.expense
        : context.flowColors.income;

    final String name = topCategory?.name ?? "Uncategorized";
    final String direction = up ? "up" : "down";

    return InsightCard(
      icon: Symbols.lunch_dining_rounded,
      label: "Category",
      accent: accent,
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: "$name is $direction "),
            TextSpan(
              text: "${deltaPct.abs().toStringAsFixed(0)}%",
              style: TextStyle(color: accent, fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: " vs your 3-month average."),
          ],
        ),
      ),
      subtitle:
          "${Money(current, primaryCurrency).formatted} this month vs "
          "${Money(avg, primaryCurrency).formatted} typical",
      child: _MiniBars(values: topCategoryHistory, highlightColor: accent),
    );
  }

  Widget _buildTopMerchantCard(BuildContext context) {
    final MapEntry<String, int> top = trends!.sortedTitlesByFrequency.first;

    return InsightCard(
      icon: Symbols.storefront_rounded,
      label: "Frequent",
      title: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: "Your most frequent entry: "),
            TextSpan(
              text: top.key,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      subtitle: "Logged ${top.value} times this month",
    );
  }

  Widget _buildWeekdayCard(BuildContext context) {
    final int topWeekday = weekdayExpense.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    final String weekdayName = _weekdayName(topWeekday);

    return InsightCard(
      icon: Symbols.calendar_month_rounded,
      label: "Rhythm",
      title: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: "You spend most on "),
            TextSpan(
              text: weekdayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: "."),
          ],
        ),
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
        ? "No expenses recorded."
        : "Biggest: ${biggestExpense!.title ?? "Untitled"} · "
              "${Money(biggestExpenseConverted, primaryCurrency).formatted} · "
              "${biggestExpense!.transactionDate.toMoment().format("MMM D")}";

    return InsightCard(
      icon: Symbols.bar_chart_rounded,
      label: "Shape",
      title: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: "Your median purchase is "),
            TextSpan(
              text: median.formatted,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: "."),
          ],
        ),
      ),
      subtitle: biggestLine,
    );
  }

  Future<void> fetch() async {
    if (!mounted) return;
    setState(() {
      busy = true;
    });

    bool missing = false;

    try {
      primaryCurrency = UserPreferencesService().primaryCurrency;
      rates = ExchangeRatesService().getPrimaryCurrencyRates();

      final List<TimeRange> months = _recentMonths(4);

      final FlowAnalytics<Category?> current = await ObjectBox()
          .flowByCategories(range: months.first);
      final List<FlowAnalytics<Category?>> previous = [];
      for (final TimeRange range in months.skip(1)) {
        previous.add(await ObjectBox().flowByCategories(range: range));
      }

      thisMonthTransactions = await ObjectBox().transcationsByRange(
        months.first,
        includeTransfers: false,
      );

      trends = TrendsReport(
        rates: rates,
        primaryCurrency: primaryCurrency,
        transactions: thisMonthTransactions,
      );

      missing = missing || _computeTopCategory(current, previous);
      missing = missing || _computeWeekdayAndBiggest();
      missing = missing || await _computeBudgets();

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

      final double? converted = _convert(transaction.money, primaryCurrency);
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

  Future<bool> _computeBudgets() async {
    bool missing = false;
    final List<Budget> all = ObjectBox().box<Budget>().getAll();
    final List<_BudgetProgress> result = [];

    for (final Budget budget in all) {
      final List<Transaction> transactions = await ObjectBox()
          .transcationsByRange(budget.timeRange, includeTransfers: false);
      final Set<String> categoryUuids =
          budget.categoriesUuids?.toSet() ?? <String>{};

      double actual = 0.0;
      for (final Transaction transaction in transactions) {
        if (transaction.type != TransactionType.expense) continue;
        // A budget with no categories tracks nothing rather than silently
        // summing every expense in the range.
        if (categoryUuids.isEmpty ||
            !categoryUuids.contains(transaction.categoryUuid)) {
          continue;
        }

        final double? converted = _convert(transaction.money, budget.currency);
        if (converted == null) {
          missing = true;
          continue;
        }
        actual += converted.abs();
      }

      result.add(_BudgetProgress(budget, actual));
    }

    budgets = result;
    return missing;
  }

  double? _convert(Money money, String currency) {
    if (money.currency == currency) return money.amount;

    final ExchangeRates? rates = this.rates;
    if (rates == null) return null;

    try {
      return money.convert(currency, rates).amount;
    } catch (_) {
      return null;
    }
  }

  List<TimeRange> _recentMonths(int count) {
    final List<TimeRange> months = [TimeRange.thisMonth()];
    for (int i = 1; i < count; i++) {
      final TimeRange previous = months.last;
      months.add(previous is PageableRange ? previous.last : previous);
    }
    return months;
  }

  void _createSampleBudget() {
    final Category? category = topCategory;
    if (category == null) return;

    final double base = topCategoryCurrent <= 0 ? 100000.0 : topCategoryCurrent;
    final String name = "[dev] ${category.name} budget";

    final Box<Budget> box = ObjectBox().box<Budget>();

    // Avoid the unique-name constraint on repeated taps.
    final List<Budget> existing = box
        .getAll()
        .where((budget) => budget.name == name)
        .toList();
    for (final Budget budget in existing) {
      box.remove(budget.id);
    }

    final Budget budget = Budget(
      name: name,
      amount: (base * 1.2).roundToDouble(),
      currency: primaryCurrency,
      range: TimeRange.thisMonth().toString(),
    )..setCategories([category]);

    box.put(budget);

    fetch();
  }

  void _clearDevBudgets() {
    final Box<Budget> box = ObjectBox().box<Budget>();
    final List<Budget> devBudgets = box
        .getAll()
        .where((budget) => budget.name.startsWith("[dev]"))
        .toList();
    for (final Budget budget in devBudgets) {
      box.remove(budget.id);
    }

    fetch();
  }

  String _weekdayName(int weekday) {
    // 1 == Monday .. 7 == Sunday (DateTime.weekday).
    return DateTime(2024, 1, weekday).toMoment().format("dddd");
  }
}

class _DevToolbar extends StatelessWidget {
  final bool canCreate;
  final VoidCallback onCreate;
  final VoidCallback onClear;

  const _DevToolbar({
    required this.canCreate,
    required this.onCreate,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Frame(
      child: Wrap(
        spacing: 8.0,
        children: [
          TextButton.icon(
            onPressed: canCreate ? onCreate : null,
            icon: const Icon(Symbols.add_rounded),
            label: const Text("Create sample budget"),
          ),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Symbols.delete_rounded),
            label: const Text("Clear [dev] budgets"),
          ),
        ],
      ),
    );
  }
}

class _MiniBars extends StatelessWidget {
  final List<double> values;
  final Color highlightColor;

  const _MiniBars({required this.values, required this.highlightColor});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    final double max = values.reduce((a, b) => a > b ? a : b);
    final Color base = context.colorScheme.onSurface.withAlpha(0x33);

    return SizedBox(
      height: 44.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.asMap().entries.map((entry) {
          final bool isLast = entry.key == values.length - 1;
          final double factor = max <= 0 ? 0.0 : entry.value / max;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: factor.clamp(0.05, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isLast ? highlightColor : base,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

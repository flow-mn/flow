import "dart:async";

import "package:flow/data/chart_data.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/flow_analytics.dart";
import "package:flow/data/money.dart";
import "package:flow/data/multi_currency_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/time_and_range.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/home/stats/group_list_view.dart";
import "package:flow/widgets/home/stats/pie_graph_view.dart";
import "package:flow/widgets/rates_missing_error_box.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class StatsByGroupPage extends StatefulWidget {
  final TimeRange? initialRange;
  final bool byCategory;

  const StatsByGroupPage({
    super.key,
    this.initialRange,
    this.byCategory = true,
  });

  @override
  State<StatsByGroupPage> createState() => StatsByGroupPageState();
}

class StatsByGroupPageState extends State<StatsByGroupPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late TimeRange range;

  FlowAnalytics? analytics;

  bool busy = false;
  bool useChart = false;

  @override
  void initState() {
    super.initState();

    range = widget.initialRange ?? TimeRange.thisMonth();
    _tabController = TabController(length: 2, vsync: this);

    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.byCategory ? "categories".t(context) : "accounts".t(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8.0),
            child: SegmentedButton<bool>(
              selected: {useChart},
              onSelectionChanged: (selection) =>
                  updateUseChart(selection.first),
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                selectedBackgroundColor: context.colorScheme.primary,
                selectedForegroundColor: context.colorScheme.onPrimary,
              ),
              segments: [
                ButtonSegment<bool>(
                  value: false,
                  icon: const Icon(Symbols.view_list_rounded),
                  tooltip: "tabs.stats.byGroup.view.list".t(context),
                ),
                ButtonSegment<bool>(
                  value: true,
                  icon: const Icon(Symbols.donut_large_rounded),
                  tooltip: "tabs.stats.byGroup.view.chart".t(context),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: ExchangeRatesService().exchangeRatesCache,
        builder: (context, exchangeRatesCache, child) {
          final ExchangeRates? rates = exchangeRatesCache?.get(
            UserPreferencesService().primaryCurrency,
          );

          final bool showMissingExchangeRatesWarning =
              rates == null &&
              TransitiveLocalPreferences().usesNonPrimaryCurrency.get();

          final Map<String, ChartData> expenses = _prepareChartData(
            analytics?.flow,
            TransactionType.expense,
            rates,
          );

          final Map<String, ChartData> incomes = _prepareChartData(
            analytics?.flow,
            TransactionType.income,
            rates,
          );

          return Column(
            children: [
              Material(
                elevation: 1.0,
                child: Container(
                  padding: const EdgeInsets.all(16.0).copyWith(bottom: 8.0),
                  width: double.infinity,
                  child: TimeRangeSelector(
                    initialValue: range,
                    onChanged: updateRange,
                  ),
                ),
              ),
              if (busy)
                const Padding(padding: EdgeInsets.all(24.0), child: Spinner())
              else ...[
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      text: TransactionType.expense.localizedTextKey.t(context),
                    ),
                    Tab(
                      text: TransactionType.income.localizedTextKey.t(context),
                    ),
                  ],
                ),
                if (showMissingExchangeRatesWarning)
                  const RatesMissingErrorBox(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      useChart
                          ? PieGraphView(
                              data: expenses,
                              changeMode: changeMode,
                              range: range,
                            )
                          : GroupListView(
                              data: expenses,
                              changeMode: changeMode,
                              range: range,
                              type: TransactionType.expense,
                              byCategory: widget.byCategory,
                            ),
                      useChart
                          ? PieGraphView(
                              data: incomes,
                              changeMode: changeMode,
                              range: range,
                            )
                          : GroupListView(
                              data: incomes,
                              changeMode: changeMode,
                              range: range,
                              type: TransactionType.income,
                              byCategory: widget.byCategory,
                            ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void updateUseChart(bool newValue) {
    setState(() {
      useChart = newValue;
    });
  }

  void updateRange(TimeRange newRange) {
    setState(() {
      range = newRange;
    });

    fetch();
  }

  Future<void> fetch() async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      analytics = widget.byCategory
          ? await ObjectBox().flowByCategories(range: range)
          : await ObjectBox().flowByAccounts(range: range);
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> changeMode() async {
    final TimeRange? newRange = await showTimeRangePickerSheet(
      context,
      initialValue: range,
    );

    if (!mounted || newRange == null) return;

    setState(() {
      range = newRange;
    });
  }

  Map<String, ChartData<T>> _prepareChartData<T>(
    Map<String, MultiCurrencyFlow<T>>? raw,
    TransactionType type,
    ExchangeRates? rates,
  ) {
    if (raw == null || raw.isEmpty) return {};

    final String primaryCurrency = UserPreferencesService().primaryCurrency;

    final Map<String, Money> cache = {};
    final Map<String, int> counts = {};

    final List<MapEntry<String, MultiCurrencyFlow<T>>> filtered = raw.entries
        .where((entry) {
          final mergedFlow = entry.value.merge(primaryCurrency, rates);

          if (type == TransactionType.expense) {
            cache[entry.key] = mergedFlow.totalExpense;
            counts[entry.key] = entry.value.expenseCount;
            return mergedFlow.totalExpense.amount < 0.0;
          } else {
            cache[entry.key] = mergedFlow.totalIncome;
            counts[entry.key] = entry.value.incomeCount;
            return mergedFlow.totalIncome.amount > 0.0;
          }
        })
        .toList();

    filtered.sort(
      (a, b) =>
          cache[b.key]!.amount.abs().compareTo(cache[a.key]!.amount.abs()),
    );

    return Map.fromEntries(
      filtered.map(
        (entry) => MapEntry<String, ChartData<T>>(
          entry.key,
          ChartData<T>(
            key: entry.key,
            money: cache[entry.key]!,
            currency: primaryCurrency,
            associatedData: entry.value.associatedData,
            transactionCount: counts[entry.key] ?? 0,
          ),
        ),
      ),
    );
  }
}

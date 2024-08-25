import "package:flow/data/chart_data.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/flow_analytics.dart";
import "package:flow/data/money.dart";
import "package:flow/data/money_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs.dart";
import "package:flow/routes/home/stats_tab/pie_graph_view.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/home/stats/exchange_missing_notice.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flow/widgets/utils/time_and_range.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  TimeRange range = TimeRange.thisMonth();

  FlowAnalytics? analytics;

  bool busy = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    fetch(true);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: ExchangeRatesService().exchangeRatesCache,
        builder: (context, exchangeRatesCache, child) {
          final ExchangeRates? rates = exchangeRatesCache?.get(
            LocalPreferences().getPrimaryCurrency(),
          );

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
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Spinner(),
                )
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
                if (rates == null) const ExchangeMissingNotice(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      PieGraphView(
                        data: expenses,
                        changeMode: changeMode,
                        range: range,
                      ),
                      PieGraphView(
                        data: incomes,
                        changeMode: changeMode,
                        range: range,
                      ),
                    ],
                  ),
                )
              ],
            ],
          );
        });
  }

  void updateRange(TimeRange newRange) {
    setState(() {
      range = newRange;
    });

    fetch(true);
  }

  Future<void> fetch(bool byCategory) async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      analytics = byCategory
          ? await ObjectBox().flowByCategories(
              from: range.from,
              to: range.to,
              currencyOverride: LocalPreferences().getPrimaryCurrency(),
            )
          : await ObjectBox().flowByAccounts(
              from: range.from,
              to: range.to,
              currencyOverride: LocalPreferences().getPrimaryCurrency(),
            );
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
    Map<String, MoneyFlow<T>>? raw,
    TransactionType type,
    ExchangeRates? rates,
  ) {
    if (raw == null || raw.isEmpty) return {};

    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    final Map<String, Money> cache = {};

    final List<MapEntry<String, MoneyFlow<T>>> filtered =
        raw.entries.where((entry) {
      if (rates != null) {
        cache[entry.key] =
            entry.value.getTotalByType(type, rates, primaryCurrency);
      } else {
        cache[entry.key] =
            entry.value.getByTypeAndCurrency(primaryCurrency, type);
      }

      if (type == TransactionType.expense) {
        return cache[entry.key]!.amount < 0.0;
      } else {
        return cache[entry.key]!.amount > 0.0;
      }
    }).toList();

    filtered.sort(
      (a, b) => cache[b.key]!.tryCompareTo(cache[a.key]!),
    );

    return Map.fromEntries(
      filtered.map(
        (entry) => MapEntry<String, ChartData<T>>(
          entry.key,
          ChartData<T>(
            key: entry.key,
            money: cache[entry.key]!,
            associatedData: entry.value.associatedData,
          ),
        ),
      ),
    );
  }
}

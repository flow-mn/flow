import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/data/flow_standard_report.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/blur_on_busy.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/home/stats/info_card_with_delta.dart";
import "package:flow/widgets/home/stats/most_spending_category.dart";
import "package:flow/widgets/home/stats/no_data.dart";
import "package:flow/widgets/home/stats/range_daily_chart.dart";
import "package:flow/widgets/rates_missing_warning.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flow/widgets/trend.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with AutomaticKeepAliveClientMixin {
  TimeRange range = TimeRange.thisMonth();
  FlowStandardReport? report;

  final AutoSizeGroup autoSizeGroup = AutoSizeGroup();

  bool busy = false;

  ExchangeRates? rates;

  @override
  void initState() {
    super.initState();

    fetch();

    rates = ExchangeRatesService().getPrimaryCurrencyRates();
    ExchangeRatesService().exchangeRatesCache.addListener(_updateRates);
  }

  @override
  void dispose() {
    ExchangeRatesService().exchangeRatesCache.removeListener(_updateRates);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (busy && report == null) {
      return Spinner.center();
    }

    final bool hasData = report != null && report!.currentFlowByDay.isNotEmpty;

    final bool showForecast =
        report?.current.contains(DateTime.now()) == true &&
            report!.currentExpenseSumForecast != null;

    final bool showMissingExchangeRatesWarning = rates == null &&
        TransitiveLocalPreferences().transitiveUsesSingleCurrency.get();

    return Column(
      children: [
        Frame.standalone(
          child: TimeRangeSelector(
            initialValue: range,
            onChanged: updateRange,
          ),
        ),
        if (showMissingExchangeRatesWarning) ...[
          RatesMissingWarning(),
          const SizedBox(height: 12.0),
        ],
        Expanded(
          child: hasData
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlurOnBusy(
                        busy: busy,
                        child: Frame(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                showForecast
                                    ? "tabs.stats.dailyReport.forecastFor"
                                        .t(context, report!.current.format())
                                    : "tabs.stats.dailyReport.totalExpenseFor"
                                        .t(context, report!.current.format()),
                                style:
                                    context.textTheme.titleSmall?.semi(context),
                              ),
                              Row(
                                children: [
                                  MoneyText(
                                    showForecast
                                        ? report!.currentExpenseSumForecast
                                        : report!.expenseSum,
                                    style: context.textTheme.displaySmall,
                                    autoSize: true,
                                    tapToToggleAbbreviation: true,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Trend.fromMoney(
                                    current: showForecast
                                        ? report!.currentExpenseSumForecast
                                        : report!.expenseSum,
                                    previous: report!.previousExpenseSum,
                                    invertDelta: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      BlurOnBusy(
                        busy: busy,
                        child: RangeDailyChart(report: report!),
                      ),
                      const SizedBox(height: 24.0),
                      BlurOnBusy(
                        busy: busy,
                        child: Frame(
                          child: Row(
                            children: [
                              Expanded(
                                child: InfoCardWithDelta(
                                  title:
                                      "tabs.stats.dailyReport.dailyAvgExpense"
                                          .t(context),
                                  autoSizeGroup: autoSizeGroup,
                                  money: report!.dailyAvgExpenditure,
                                  previousMoney:
                                      report!.previousDailyAvgExpenditure,
                                  invertDelta: true,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: InfoCardWithDelta(
                                  title: "tabs.stats.dailyReport.dailyAvgIncome"
                                      .t(context),
                                  autoSizeGroup: autoSizeGroup,
                                  money: report!.dailyAvgIncome,
                                  previousMoney: report!.previousDailyAvgIncome,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      ListHeader("tabs.stats.topSpendingCategory".t(context)),
                      const SizedBox(height: 8.0),
                      Frame(child: MostSpendingCategory(range: range)),
                      const SizedBox(height: 24.0),
                      ListHeader("tabs.stats.otherStats".t(context)),
                      ListTile(
                        title: Text("tabs.stats.summaryByCategory".t(context)),
                        onTap: () => context.push(
                          "/stats/category?range=${Uri.encodeQueryComponent(range.encodeShort())}",
                        ),
                        leading: FlowIcon(
                          FlowIconData.icon(Symbols.category_rounded),
                          size: 24.0,
                        ),
                        trailing: Icon(Symbols.chevron_right_rounded),
                      ),
                      ListTile(
                        title: Text("tabs.stats.summaryByAccount".t(context)),
                        onTap: () => context.push(
                          "/stats/account?range=${Uri.encodeQueryComponent(range.encodeShort())}",
                        ),
                        leading: FlowIcon(
                          FlowIconData.icon(Symbols.wallet_rounded),
                          size: 24.0,
                        ),
                        trailing: Icon(Symbols.chevron_right_rounded),
                      ),
                      const SizedBox(height: 96.0),
                    ],
                  ),
                )
              : NoData(),
        ),
      ],
    );
  }

  void updateRange(TimeRange value) {
    range = value;
    fetch();

    if (!mounted) return;
    setState(() {});
  }

  Future<void> fetch() async {
    setState(() {
      busy = true;
    });

    try {
      report = await FlowStandardReport.generate(range, rates);
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void _updateRates() {
    rates = ExchangeRatesService().getPrimaryCurrencyRates();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  bool get wantKeepAlive => true;
}

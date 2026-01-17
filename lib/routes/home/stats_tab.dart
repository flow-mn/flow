import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/reports/interval_flow_report.dart";
import "package:flow/reports/range_forecast_report.dart";
import "package:flow/reports/report.dart";
import "package:flow/reports/trends_report.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/extensions/interval_report.dart";
import "package:flow/widgets/general/blur_backgorund.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/home/stats/info_card_with_delta.dart";
import "package:flow/widgets/home/stats/most_spending_category.dart";
import "package:flow/widgets/home/stats/no_data.dart";
import "package:flow/widgets/rates_missing_error_box.dart";
import "package:flow/widgets/reports/interval_flow_report_view.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flow/widgets/trend.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:moment_dart/moment_dart.dart";

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with AutomaticKeepAliveClientMixin {
  TimeRange range = TimeRange.thisMonth();

  List<Transaction> transactions = [];

  RangeForecastReport? rangeForecastReport;
  IntervalFlowReport? intervalFlowReport;
  IntervalFlowReport? previousIntervalFlowReport;
  TrendsReport? trendsReport;

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

    if (busy && intervalFlowReport == null) {
      return Spinner.center();
    }

    final bool hasData =
        intervalFlowReport != null && intervalFlowReport!.data.isNotEmpty;

    final bool showForecast =
        intervalFlowReport?.rangeData.range.contains(DateTime.now()) == true &&
        rangeForecastReport != null;

    final bool showMissingExchangeRatesWarning =
        rates == null &&
        TransitiveLocalPreferences().usesNonPrimaryCurrency.get();

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Frame.standalone(
            child: TimeRangeSelector(
              initialValue: range,
              onChanged: updateRange,
            ),
          ),
        ),
        if (showMissingExchangeRatesWarning) ...[
          RatesMissingErrorBox(),
          const SizedBox(height: 12.0),
        ],
        Expanded(
          child: hasData
              ? SingleChildScrollView(
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        BlurBackground(
                          blur: busy,
                          child: Frame(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: .start,
                              children: [
                                Text(
                                  showForecast
                                      ? "tabs.stats.intervalReport.forecast".t(
                                          context,
                                          rangeForecastReport
                                              ?.currentRangeData
                                              .range
                                              .format(),
                                        )
                                      : "tabs.stats.intervalReport.totalExpense"
                                            .t(
                                              context,
                                              intervalFlowReport!
                                                  .rangeData
                                                  .range
                                                  .format(),
                                            ),
                                  style: context.textTheme.titleSmall?.semi(
                                    context,
                                  ),
                                ),
                                Row(
                                  children: [
                                    MoneyText(
                                      showForecast
                                          ? rangeForecastReport!
                                                .forecast
                                                .totalExpense
                                          : intervalFlowReport!.totalExpense,
                                      style: context.textTheme.displaySmall,
                                      autoSize: true,
                                      tapToToggleAbbreviation: true,
                                    ),
                                    const SizedBox(width: 8.0),
                                    Trend.fromMoney(
                                      current: showForecast
                                          ? rangeForecastReport
                                                ?.forecast
                                                .totalExpense
                                          : intervalFlowReport!.totalExpense,
                                      previous: previousIntervalFlowReport
                                          ?.totalExpense,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        if (intervalFlowReport != null)
                          BlurBackground(
                            blur: busy,
                            child: IntervalFlowReportView(
                              report: intervalFlowReport!,
                              compareWith: previousIntervalFlowReport,
                            ),
                          ),
                        const SizedBox(height: 24.0),
                        if (intervalFlowReport != null) ...[
                          const SizedBox(height: 24.0),
                          ListHeader(intervalFlowReport!.averageTitle(context)),
                          const SizedBox(height: 8.0),
                          BlurBackground(
                            blur: busy,
                            child: Frame(
                              child: Column(
                                spacing: 16.0,
                                children: [
                                  Row(
                                    spacing: 16.0,
                                    children: [
                                      Expanded(
                                        child: InfoCardWithDelta(
                                          title:
                                              "tabs.stats.intervalReport.averages.expense"
                                                  .t(context),
                                          autoSizeGroup: autoSizeGroup,
                                          money: intervalFlowReport!
                                              .averageExpense,
                                          previousMoney:
                                              previousIntervalFlowReport
                                                  ?.averageExpense,
                                          invertDelta: true,
                                        ),
                                      ),
                                      Expanded(
                                        child: InfoCardWithDelta(
                                          title:
                                              "tabs.stats.intervalReport.averages.income"
                                                  .t(context),
                                          autoSizeGroup: autoSizeGroup,
                                          money:
                                              intervalFlowReport!.averageIncome,
                                          previousMoney:
                                              previousIntervalFlowReport
                                                  ?.averageIncome,
                                        ),
                                      ),
                                    ],
                                  ),

                                  InfoCardWithDelta(
                                    title:
                                        "tabs.stats.intervalReport.averages.flow"
                                            .t(context),
                                    autoSizeGroup: autoSizeGroup,
                                    money: intervalFlowReport!.averageFlow,
                                    previousMoney:
                                        previousIntervalFlowReport?.averageFlow,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        // if (trendsReport != null) ...[
                        //   const SizedBox(height: 24.0),
                        //   ListHeader("tabs.stats.trends".t(context)),
                        //   const SizedBox(height: 8.0),
                        //   BlurBackground(
                        //     blur: busy,
                        //     child: Frame(
                        //       child: Column(
                        //         spacing: 16.0,
                        //         mainAxisSize: MainAxisSize.min,
                        //         children: [
                        //           Surface(
                        //             builder: (context) {
                        //               return Padding(
                        //                 padding: EdgeInsets.all(16.0),
                        //                 child: Column(
                        //                   mainAxisSize: MainAxisSize.min,
                        //                   children: [
                        //                     Text(
                        //                       "tabs.stats.trends.topSpendingTitles"
                        //                           .t(context),
                        //                     ),
                        //                     const SizedBox(height: 16.0),
                        //                     ...trendsReport!
                        //                         .sortedTitlesByFrequency
                        //                         .take(3)
                        //                         .map(
                        //                           (titleFrequency) => Text(
                        //                             "${titleFrequency.key} (${titleFrequency.value})",
                        //                           ),
                        //                         ),
                        //                   ],
                        //                 ),
                        //               );
                        //             },
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ],
                        const SizedBox(height: 24.0),
                        ListHeader("tabs.stats.categories".t(context)),
                        const SizedBox(height: 8.0),
                        Frame(child: MostSpendingCategory(range: range)),
                        const SizedBox(height: 12.0),
                        Frame(
                          child: Align(
                            alignment: AlignmentDirectional.topEnd,
                            child: TextButton.icon(
                              onPressed: () => context.push(
                                "/stats/category?range=${Uri.encodeQueryComponent(range.encodeShort())}",
                              ),
                              label: Text(
                                "tabs.stats.categories.seeAll".t(context),
                              ),
                              icon: DirectionalChevron(),
                              iconAlignment: IconAlignment.end,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        const SizedBox(height: 96.0),
                      ],
                    ),
                  ),
                )
              : SafeArea(child: NoData()),
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
      final String primaryCurrency = UserPreferencesService().primaryCurrency;

      transactions = await ObjectBox().transcationsByRange(
        range,
        includeTransfers: false,
      );

      final TimeRange? previousRange = range is PageableRange
          ? (range as PageableRange).last
          : null;

      final List<Transaction>? previousRangeTransactions = previousRange != null
          ? await ObjectBox().transcationsByRange(
              previousRange,
              includeTransfers: false,
            )
          : null;

      final RangeData currentRangeData = RangeData(
        range: range,
        transactions: transactions,
      );
      RangeData previousRangeData = previousRange != null
          ? RangeData(
              range: previousRange,
              transactions: previousRangeTransactions ?? [],
            )
          : RangeData(
              range: CustomTimeRange(
                range.from - range.duration,
                range.to - range.duration,
              ),
              transactions: [],
            );

      // report = await FlowStandardReport.generate(range, rates);

      rangeForecastReport =
          (previousRange != null && previousRangeData.transactions.isNotEmpty)
          ? RangeForecastReport(
              rates: rates,
              primaryCurrency: primaryCurrency,
              previousRangeData: previousRangeData,
              currentRangeData: currentRangeData,
            )
          : null;

      final Duration interval = RangeData.getOptimalInterval(range);

      intervalFlowReport = IntervalFlowReport(
        interval: interval,
        rangeData: currentRangeData,
        rates: rates,
        primaryCurrency: primaryCurrency,
      );
      previousIntervalFlowReport = previousRange != null
          ? IntervalFlowReport(
              interval: interval,
              rangeData: previousRangeData,
              rates: rates,
              primaryCurrency: primaryCurrency,
            )
          : null;
      trendsReport = TrendsReport(
        rates: rates,
        primaryCurrency: primaryCurrency,
        transactions: transactions,
      );
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void _updateRates() {
    rates = ExchangeRatesService().getPrimaryCurrencyRates();
    fetch();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  bool get wantKeepAlive => true;
}

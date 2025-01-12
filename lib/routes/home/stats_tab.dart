import "package:flow/data/exchange_rates_set.dart";
import "package:flow/data/flow_analytics.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/routes/home/stats_tab/daily_average.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  TimeRange range = TimeRange.thisMonth();
  ExchangeRatesSet? exchangeRatesSet;

  FlowAnalytics<TimeRange>? data;

  bool ready = false;

  @override
  void initState() {
    super.initState();
    exchangeRatesSet = ExchangeRatesService().exchangeRatesCache.value;
    ExchangeRatesService().exchangeRatesCache.addListener(_updateExchangeRates);

    _fetch().whenComplete(() {
      if (!mounted) return;
      setState(() {
        ready = true;
      });
    });
  }

  @override
  void dispose() {
    ExchangeRatesService()
        .exchangeRatesCache
        .removeListener(_updateExchangeRates);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) {
      return Spinner.center();
    }

    if (ready && (data == null || data!.flow.isEmpty)) {
      return Center(
        child: Text("No data available"),
      );
    }

    return ValueListenableBuilder(
      valueListenable: ExchangeRatesService().exchangeRatesCache,
      builder: (context, exchangeRates, child) {
        return Column(
          children: [
            Material(
              elevation: 1.0,
              child: Container(
                padding: const EdgeInsets.all(16.0).copyWith(bottom: 8.0),
                width: double.infinity,
                child: TimeRangeSelector(
                  initialValue: range,
                  onChanged: _updateRange,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DailyAverage(
                      data: data!,
                      exchangeRatesSet: exchangeRatesSet,
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetch() async {
    data = await ObjectBox().flowByTimeRange(
      from: range.from,
      to: range.to,
      unit: DurationUnit.day,
    );

    if (!mounted) return;

    setState(() {});
  }

  void _updateRange(TimeRange newRange) {
    setState(() {
      range = newRange;
    });

    _fetch();
  }

  void _updateExchangeRates() {
    setState(() {
      exchangeRatesSet = ExchangeRatesService().exchangeRatesCache.value;
    });
  }
}

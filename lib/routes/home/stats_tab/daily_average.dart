import "package:fl_chart/fl_chart.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/exchange_rates_set.dart";
import "package:flow/data/flow_analytics.dart";
import "package:flow/data/money.dart";
import "package:flow/prefs.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class DailyAverage extends StatelessWidget {
  final FlowAnalytics<TimeRange> data;
  final ExchangeRatesSet? exchangeRatesSet;

  const DailyAverage({
    super.key,
    required this.data,
    required this.exchangeRatesSet,
  });

  @override
  Widget build(BuildContext context) {
    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();
    final ExchangeRates? exchangeRates =
        exchangeRatesSet?.rates[primaryCurrency];

    late final Money convertedSum;

    if (exchangeRates == null) {
      try {
        convertedSum = data.flow.values
            .map((flow) => flow.getExpenseByCurrency(primaryCurrency))
            .reduce((a, b) => a + b);
      } catch (e) {
        convertedSum = Money(0.0, primaryCurrency);
      }
    } else {
      try {
        convertedSum = data.flow.values
            .map((flow) => flow.getTotalExpense(exchangeRates, primaryCurrency))
            .reduce((a, b) => a + b);
      } catch (e) {
        convertedSum = Money(0.0, primaryCurrency);
      }
    }

    final double days = data.flow.length.toDouble();

    final Money dailyAverage = convertedSum / (days == 0.0 ? 1.0 : days);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Daily average: ${dailyAverage.formattedCompact}"),
        Text("Total: ${convertedSum.formattedCompact}"),
        SizedBox(
          height: 200.0,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                verticalInterval: Duration(days: 1).inMilliseconds.toDouble(),
                horizontalInterval: dailyAverage.amount,
              ),
              lineBarsData: data
                  .relevantFlow(primaryCurrency, exchangeRates)
                  .entries
                  .map(
                    (entry) => LineChartBarData(
                      spots: [
                        FlSpot(
                          TimeRange.parse(entry.key)
                              .from
                              .millisecondsSinceEpoch
                              .toDouble(),
                          entry.value.expense.abs(),
                        )
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        )
      ],
    );
  }
}

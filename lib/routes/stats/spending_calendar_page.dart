import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/analytics/insight_card.dart";
import "package:flow/widgets/analytics/spending_heatmap.dart";
import "package:flow/widgets/analytics/weekday_bars.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/stats/emphasized_text.dart";
import "package:flow/widgets/stats/missing_rates_notice.dart";
import "package:flow/widgets/stats/stats_app_bar.dart";
import "package:flow/widgets/stats/stats_empty_state.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Spending calendar — a heatmap of daily spend intensity.
///
/// Bins expenses by [Transaction.transactionDate] and renders a GitHub-style
/// grid, plus a weekday breakdown. The weekday rhythm is computed here because
/// `TrendsReport.expenseByWeekday` is never populated upstream.
class SpendingCalendarPage extends StatefulWidget {
  const SpendingCalendarPage({super.key});

  @override
  State<SpendingCalendarPage> createState() => _SpendingCalendarPageState();
}

class _SpendingCalendarPageState extends State<SpendingCalendarPage>
    with PrimaryCurrencyDependentState<SpendingCalendarPage> {
  TimeRange range = TimeRange.thisYear();

  bool busy = false;
  bool missingRates = false;

  Map<DateTime, double> dailyExpense = {};
  Map<int, double> weekdayExpense = {};
  double total = 0.0;
  DateTime from = DateTime.now();
  DateTime to = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final bool hasData = dailyExpense.isNotEmpty;

    return Scaffold(
      appBar: StatsAppBar(
        title: "tabs.stats.analytics.spendingCalendar".t(context),
      ),
      body: SafeArea(
        child: busy && dailyExpense.isEmpty
            ? const Spinner.center()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    const SizedBox(height: 16.0),
                    Frame(
                      child: TimeRangeSelector(
                        initialValue: range,
                        onChanged: _updateRange,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Frame(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            "tabs.stats.analytics.calendar.spentIn".t(
                              context,
                              range.format(useRelative: false),
                            ),
                            style: context.textTheme.titleSmall?.semi(context),
                          ),
                          const SizedBox(height: 2.0),
                          MoneyText(
                            Money(total, primaryCurrency),
                            style: context.textTheme.displaySmall,
                            autoSize: true,
                            tapToToggleAbbreviation: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    if (hasData)
                      Frame(
                        child: SpendingHeatmap(
                          dailyExpense: dailyExpense,
                          from: from,
                          to: to,
                          currency: primaryCurrency,
                        ),
                      )
                    else
                      StatsEmptyState(
                        message: "tabs.stats.analytics.noSpendingWindow".t(
                          context,
                        ),
                      ),
                    if (weekdayExpense.isNotEmpty) ...[
                      const SizedBox(height: 16.0),
                      _buildWeekdayInsight(context),
                    ],
                    if (missingRates) ...[
                      const SizedBox(height: 8.0),
                      MissingRatesNotice(
                        message: "tabs.stats.analytics.missingRatesAmounts".t(
                          context,
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

  Widget _buildWeekdayInsight(BuildContext context) {
    final int topWeekday = weekdayExpense.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    return InsightCard(
      icon: Symbols.calendar_month_rounded,
      label: "tabs.stats.analytics.rhythm".t(context),
      title: EmphasizedText(
        template: "tabs.stats.analytics.calendar.priciestDay".t(context),
        value: _weekdayName(topWeekday),
      ),
      child: WeekdayBars(
        byWeekday: weekdayExpense,
        topWeekday: topWeekday,
        accent: context.colorScheme.primary,
      ),
    );
  }

  void _updateRange(TimeRange value) {
    if (value == range) return;
    range = value;
    fetch();
  }

  @override
  Future<void> fetch() async {
    if (!mounted) return;
    setState(() {
      busy = true;
    });

    bool missing = false;

    try {
      // Heatmap cells past today render empty, so cap the grid at "now" when
      // the range runs into the future (e.g. the remainder of this year).
      final DateTime now = DateTime.now();
      from = range.from;
      to = range.to.isAfter(now) ? now : range.to;

      final List<Transaction> transactions = await ObjectBox()
          .transcationsByRange(range, includeTransfers: false);

      final Map<DateTime, double> daily = {};
      final Map<int, double> weekday = {};
      double sum = 0.0;

      for (final Transaction transaction in transactions) {
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
        final DateTime day = DateTime(
          transaction.transactionDate.year,
          transaction.transactionDate.month,
          transaction.transactionDate.day,
        );

        daily[day] = (daily[day] ?? 0.0) + magnitude;
        weekday[transaction.transactionDate.weekday] =
            (weekday[transaction.transactionDate.weekday] ?? 0.0) + magnitude;
        sum += magnitude;
      }

      dailyExpense = daily;
      weekdayExpense = weekday;
      total = sum;
      missingRates = missing;
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }

  String _weekdayName(int weekday) {
    // 1 == Monday .. 7 == Sunday (DateTime.weekday).
    return DateTime(2024, 1, weekday).toMoment().format("dddd");
  }
}

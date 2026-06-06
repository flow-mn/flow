import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/debug/analytics/insight_card.dart";
import "package:flow/widgets/debug/analytics/spending_heatmap.dart";
import "package:flow/widgets/debug/analytics/weekday_bars.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// [dev] Spending calendar — a heatmap of daily spend intensity.
///
/// Bins expenses by [Transaction.transactionDate] and renders a GitHub-style
/// grid, plus a weekday breakdown. The weekday rhythm is computed here because
/// `TrendsReport.expenseByWeekday` is never populated upstream.
class DebugSpendingCalendarPage extends StatefulWidget {
  const DebugSpendingCalendarPage({super.key});

  @override
  State<DebugSpendingCalendarPage> createState() =>
      _DebugSpendingCalendarPageState();
}

enum _Period {
  m3("3M", 13),
  m6("6M", 26),
  y1("1Y", 53);

  final String label;
  final int weeks;

  const _Period(this.label, this.weeks);
}

class _DebugSpendingCalendarPageState extends State<DebugSpendingCalendarPage> {
  _Period period = _Period.m6;

  bool busy = false;
  bool missingRates = false;

  late String primaryCurrency;
  ExchangeRates? rates;

  Map<DateTime, double> dailyExpense = {};
  Map<int, double> weekdayExpense = {};
  double total = 0.0;
  DateTime from = DateTime.now();
  DateTime to = DateTime.now();

  @override
  void initState() {
    super.initState();

    primaryCurrency = UserPreferencesService().primaryCurrency;
    rates = ExchangeRatesService().getPrimaryCurrencyRates();

    fetch();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasData = dailyExpense.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Spending calendar (dev)"),
        elevation: 0.0,
        scrolledUnderElevation: 1.0,
        centerTitle: false,
        shadowColor: context.colorScheme.onSurface.withAlpha(0x40),
        backgroundColor: context.colorScheme.surface,
        surfaceTintColor: kTransparent,
      ),
      body: SafeArea(
        child: busy && dailyExpense.isEmpty
            ? const Spinner.center()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    Frame(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Spent in ${period.label}",
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
                    Frame(
                      child: Wrap(
                        spacing: 8.0,
                        children: _Period.values
                            .map(
                              (p) => FilterChip(
                                label: Text(p.label),
                                selected: p == period,
                                onSelected: busy ? null : (_) => _setPeriod(p),
                              ),
                            )
                            .toList(),
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
                      const Frame(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 48.0),
                          child: Center(
                            child: Text("No spending in this window."),
                          ),
                        ),
                      ),
                    if (weekdayExpense.isNotEmpty) ...[
                      const SizedBox(height: 16.0),
                      _buildWeekdayInsight(context),
                    ],
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

  Widget _buildWeekdayInsight(BuildContext context) {
    final int topWeekday = weekdayExpense.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    return InsightCard(
      icon: Symbols.calendar_month_rounded,
      label: "Rhythm",
      title: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: "Your priciest day is "),
            TextSpan(
              text: _weekdayName(topWeekday),
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

  void _setPeriod(_Period value) {
    if (value == period) return;
    period = value;
    fetch();
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

      final DateTime now = DateTime.now();
      to = now;
      from = now.subtract(Duration(days: period.weeks * 7));

      final List<Transaction> transactions = await ObjectBox()
          .transcationsByRange(
            CustomTimeRange(from, to),
            includeTransfers: false,
          );

      final Map<DateTime, double> daily = {};
      final Map<int, double> weekday = {};
      double sum = 0.0;

      for (final Transaction transaction in transactions) {
        if (transaction.type != TransactionType.expense) continue;

        final double? converted = _convert(transaction.money, primaryCurrency);
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

  String _weekdayName(int weekday) {
    // 1 == Monday .. 7 == Sunday (DateTime.weekday).
    return DateTime(2024, 1, weekday).toMoment().format("dddd");
  }
}

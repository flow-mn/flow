import "dart:math" as math;

import "package:fl_chart/fl_chart.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/account.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// [dev] Net worth over time.
///
/// Samples [Account.balanceAt] at the end of each month for the selected
/// window, converting non-primary currency balances into the primary
/// currency. Below the trend, balances are grouped into net-worth buckets
/// (cash / savings / investments / debt).
///
/// Buildable entirely from existing data: account types + [Account.balanceAt].
class DebugNetWorthPage extends StatefulWidget {
  const DebugNetWorthPage({super.key});

  @override
  State<DebugNetWorthPage> createState() => _DebugNetWorthPageState();
}

enum _Period {
  m3("3M", 3),
  m6("6M", 6),
  y1("1Y", 12),
  all("All", null);

  final String label;

  /// Number of months to look back, or `null` for "all".
  final int? months;

  const _Period(this.label, this.months);
}

enum _NetWorthBucket {
  cash("Cash", Symbols.account_balance_wallet_rounded),
  savings("Savings", Symbols.savings_rounded),
  investments("Investments", Symbols.trending_up_rounded),
  debt("Debt", Symbols.credit_card_rounded),
  other("Other", Symbols.account_balance_rounded);

  final String label;
  final IconData icon;

  const _NetWorthBucket(this.label, this.icon);

  static _NetWorthBucket of(AccountType type) => switch (type) {
    AccountType.debit => _NetWorthBucket.cash,
    AccountType.savings => _NetWorthBucket.savings,
    AccountType.asset => _NetWorthBucket.investments,
    AccountType.creditLine || AccountType.loan => _NetWorthBucket.debt,
    AccountType.other => _NetWorthBucket.other,
  };
}

class _NetWorthSample {
  final DateTime anchor;
  final double amount;

  const _NetWorthSample(this.anchor, this.amount);
}

class _DebugNetWorthPageState extends State<DebugNetWorthPage> {
  _Period period = _Period.y1;

  bool busy = false;

  /// Whether any non-primary currency balance couldn't be converted.
  bool missingRates = false;

  List<Account> accounts = [];
  List<_NetWorthSample> samples = [];
  Map<_NetWorthBucket, double> breakdown = {};

  late String primaryCurrency;
  ExchangeRates? rates;

  @override
  void initState() {
    super.initState();

    primaryCurrency = UserPreferencesService().primaryCurrency;
    rates = ExchangeRatesService().getPrimaryCurrencyRates();

    fetch();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasData = samples.length >= 2;

    final Money current = Money(
      samples.isEmpty ? 0.0 : samples.last.amount,
      primaryCurrency,
    );
    final Money first = Money(
      samples.isEmpty ? 0.0 : samples.first.amount,
      primaryCurrency,
    );
    final Money delta = current - first;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Net worth (dev)"),
        elevation: 0.0,
        scrolledUnderElevation: 1.0,
        centerTitle: false,
        shadowColor: context.colorScheme.onSurface.withAlpha(0x40),
        backgroundColor: context.colorScheme.surface,
        surfaceTintColor: kTransparent,
      ),
      body: SafeArea(
        child: busy && samples.isEmpty
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
                            "Net worth",
                            style: context.textTheme.titleSmall?.semi(context),
                          ),
                          const SizedBox(height: 2.0),
                          MoneyText(
                            current,
                            style: context.textTheme.displaySmall,
                            autoSize: true,
                            tapToToggleAbbreviation: true,
                          ),
                          const SizedBox(height: 4.0),
                          _DeltaLabel(delta: delta, windowLabel: period.label),
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
                        child: SizedBox(
                          height: 220.0,
                          child: _NetWorthChart(
                            samples: samples,
                            primaryCurrency: primaryCurrency,
                          ),
                        ),
                      )
                    else
                      const Frame(
                        child: SizedBox(
                          height: 120.0,
                          child: Center(
                            child: Text("Not enough history to draw a trend."),
                          ),
                        ),
                      ),
                    if (missingRates) ...[
                      const SizedBox(height: 8.0),
                      Frame(
                        child: Text(
                          "Some non-primary currency balances were skipped "
                          "(missing exchange rates).",
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.flowColors.expense,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32.0),
                    const ListHeader("Composition"),
                    const SizedBox(height: 8.0),
                    ..._buildBreakdownRows(context),
                    const SizedBox(height: 96.0),
                  ],
                ),
              ),
      ),
    );
  }

  List<Widget> _buildBreakdownRows(BuildContext context) {
    if (breakdown.isEmpty) {
      return [const Frame(child: Text("No accounts to summarize."))];
    }

    // Stable, meaningful order rather than insertion order.
    final List<_NetWorthBucket> order = _NetWorthBucket.values
        .where(breakdown.containsKey)
        .toList();

    return order.map((bucket) {
      final double amount = breakdown[bucket] ?? 0.0;
      final bool isDebt = bucket == _NetWorthBucket.debt;
      final Color color = isDebt
          ? context.flowColors.expense
          : context.colorScheme.primary;

      return ListTile(
        leading: FlowIcon(
          FlowIconData.icon(bucket.icon),
          plated: true,
          color: color,
        ),
        title: Text(bucket.label),
        trailing: MoneyText(
          Money(amount, primaryCurrency),
          style: context.textTheme.titleSmall?.copyWith(
            color: isDebt ? context.flowColors.expense : null,
          ),
        ),
      );
    }).toList();
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

    try {
      primaryCurrency = UserPreferencesService().primaryCurrency;
      rates = ExchangeRatesService().getPrimaryCurrencyRates();

      accounts = ObjectBox()
          .getAccounts(false)
          .where((account) => account.excludeFromTotalBalance != true)
          .toList();

      final int months = period.months ?? _allMonths(accounts);
      final List<DateTime> anchors = _monthAnchors(months);

      bool missing = false;

      final List<_NetWorthSample> nextSamples = anchors.map((anchor) {
        double total = 0.0;
        for (final Account account in accounts) {
          final ({double value, bool missing}) result = _convertedBalance(
            account.balanceAt(anchor),
          );
          total += result.value;
          missing = missing || result.missing;
        }
        return _NetWorthSample(anchor, total);
      }).toList();

      final Map<_NetWorthBucket, double> nextBreakdown = {};
      for (final Account account in accounts) {
        final ({double value, bool missing}) result = _convertedBalance(
          account.balance,
        );
        missing = missing || result.missing;

        final _NetWorthBucket bucket = _NetWorthBucket.of(account.accountType);
        nextBreakdown[bucket] = (nextBreakdown[bucket] ?? 0.0) + result.value;
      }

      samples = nextSamples;
      breakdown = nextBreakdown;
      missingRates = missing;
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }

  /// Converts [money] into the primary currency, flagging when conversion is
  /// impossible (missing rates) so the UI can warn instead of lying.
  ({double value, bool missing}) _convertedBalance(Money money) {
    if (money.currency == primaryCurrency) {
      return (value: money.amount, missing: false);
    }

    final ExchangeRates? rates = this.rates;
    if (rates == null) {
      return (value: 0.0, missing: true);
    }

    try {
      return (
        value: money.convert(primaryCurrency, rates).amount,
        missing: false,
      );
    } catch (_) {
      return (value: 0.0, missing: true);
    }
  }

  /// End-of-month anchors for the trailing [months] months, with the most
  /// recent point anchored to "now" so the latest figure is live.
  List<DateTime> _monthAnchors(int months) {
    final DateTime now = DateTime.now();
    final List<DateTime> anchors = [];

    for (int i = months - 1; i >= 0; i--) {
      if (i == 0) {
        anchors.add(now);
      } else {
        // Day 0 of (month - i + 1) == last day of (month - i).
        anchors.add(DateTime(now.year, now.month - i + 1, 0, 23, 59, 59));
      }
    }

    return anchors;
  }

  int _allMonths(List<Account> accounts) {
    if (accounts.isEmpty) return 12;

    final DateTime earliest = accounts
        .map((a) => a.createdDate)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final DateTime now = DateTime.now();
    final int months =
        (now.year - earliest.year) * 12 + (now.month - earliest.month) + 1;

    return months.clamp(3, 60);
  }
}

class _DeltaLabel extends StatelessWidget {
  final Money delta;
  final String windowLabel;

  const _DeltaLabel({required this.delta, required this.windowLabel});

  @override
  Widget build(BuildContext context) {
    final bool up = delta.amount >= 0;
    final Color color = up
        ? context.flowColors.income
        : context.flowColors.expense;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          up ? Symbols.trending_up_rounded : Symbols.trending_down_rounded,
          color: color,
          size: 18.0,
        ),
        const SizedBox(width: 4.0),
        MoneyText(
          delta,
          displayAbsoluteAmount: true,
          style: context.textTheme.bodyMedium?.copyWith(color: color),
        ),
        const SizedBox(width: 6.0),
        Text(
          "in $windowLabel",
          style: context.textTheme.bodyMedium?.semi(context),
        ),
      ],
    );
  }
}

class _NetWorthChart extends StatelessWidget {
  final List<_NetWorthSample> samples;
  final String primaryCurrency;

  const _NetWorthChart({required this.samples, required this.primaryCurrency});

  @override
  Widget build(BuildContext context) {
    final Color line = context.colorScheme.primary;

    final double maxY = samples
        .map((s) => s.amount)
        .reduce((a, b) => a > b ? a : b);
    final double minY = samples
        .map((s) => s.amount)
        .reduce((a, b) => a < b ? a : b);

    // Frame the chart to the actual data range (plus a little padding) so a
    // net worth that stays positive still shows its variation instead of
    // being flattened against a 0 baseline. The 0 line is drawn separately
    // only when the range actually crosses zero.
    final double span = (maxY - minY).abs();
    final double pad = span == 0 ? maxY.abs() * 0.1 + 1 : span * 0.12;
    final double resolvedMinY = minY - pad;
    final double resolvedMaxY = maxY + pad;

    return LineChart(
      LineChartData(
        minX: 0.0,
        maxX: (samples.length - 1).toDouble(),
        minY: resolvedMinY,
        maxY: resolvedMaxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) => context.colorScheme.onPrimary,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final _NetWorthSample sample = samples[spot.x.toInt()];
                return LineTooltipItem(
                  "${sample.anchor.toMoment().format("MMM yyyy")}\n"
                  "${Money(sample.amount, primaryCurrency).formattedCompact}",
                  TextStyle(
                    color: line,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                  ),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: _bottomTitles()),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48.0,
              getTitlesWidget: (value, meta) {
                if (value != meta.min && value != meta.max) {
                  return const SizedBox.shrink();
                }
                return MoneyText(
                  Money(value, primaryCurrency),
                  initiallyAbbreviated: true,
                  autoSize: true,
                  style: context.textTheme.labelSmall,
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (resolvedMinY < 0)
              HorizontalLine(
                y: 0.0,
                color: context.colorScheme.onSurface.withAlpha(0x30),
                strokeWidth: 1.0,
              ),
          ],
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: context.colorScheme.onSurface.withAlpha(0x40),
              width: 2.0,
            ),
            left: BorderSide(
              color: context.colorScheme.onSurface.withAlpha(0x40),
              width: 2.0,
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            barWidth: 2.5,
            color: line,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            spots: samples
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.amount))
                .toList(),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [line.withAlpha(0x40), line.withAlpha(0x00)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SideTitles _bottomTitles() {
    // Aim for ~4 labels regardless of window length.
    final int step = math.max(1, (samples.length / 4).floor());

    return SideTitles(
      showTitles: true,
      interval: 1.0,
      reservedSize: 28.0,
      getTitlesWidget: (value, meta) {
        final int index = value.round();
        if (index < 0 || index >= samples.length) {
          return const SizedBox.shrink();
        }
        if (index % step != 0 && index != samples.length - 1) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            samples[index].anchor.toMoment().format("MMM"),
            style: const TextStyle(fontSize: 11.0),
          ),
        );
      },
    );
  }
}

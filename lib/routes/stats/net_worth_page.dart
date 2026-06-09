import "package:flow/data/money.dart";
import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/reports/report.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/stats/missing_rates_notice.dart";
import "package:flow/widgets/stats/money_delta_label.dart";
import "package:flow/widgets/stats/net_worth/account_balance_share.dart";
import "package:flow/widgets/stats/net_worth/account_share_tile.dart";
import "package:flow/widgets/stats/net_worth/net_worth_chart.dart";
import "package:flow/widgets/stats/net_worth/net_worth_sample.dart";
import "package:flow/widgets/stats/stats_app_bar.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

/// Net worth over time.
///
/// Samples [Account.balanceAt] at regular intervals across the selected
/// [TimeRange], converting non-primary currency balances into the primary
/// currency. The sampling interval (day / week / month / year) follows the
/// range via [RangeData.getOptimalUnit], mirroring how [IntervalFlowReport]
/// walks a range, so axis labels and tooltips stay distinct and meaningful.
///
/// Below the trend, each account's current balance is shown as a share of net
/// worth so the composition is informative no matter how many account types a
/// user has.
class NetWorthPage extends StatefulWidget {
  const NetWorthPage({super.key});

  @override
  State<NetWorthPage> createState() => _NetWorthPageState();
}

class _NetWorthPageState extends State<NetWorthPage>
    with PrimaryCurrencyDependentState<NetWorthPage> {
  TimeRange range = TimeRange.thisYear();

  bool busy = false;

  /// Whether any non-primary currency balance couldn't be converted.
  bool missingRates = false;

  List<Account> accounts = [];
  List<NetWorthSample> samples = [];
  List<AccountBalanceShare> shares = [];

  /// Unit the samples are spaced by, used to format axis labels and tooltips.
  DurationUnit sampleUnit = DurationUnit.month;

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
      appBar: StatsAppBar(title: "tabs.stats.analytics.netWorth".t(context)),
      body: SafeArea(
        child: busy && samples.isEmpty
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
                            "tabs.stats.analytics.netWorth".t(context),
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
                          MoneyDeltaLabel(
                            delta: delta,
                            suffixLabel: "tabs.stats.analytics.inRange".t(
                              context,
                              range.format(useRelative: false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    if (hasData)
                      Frame(
                        child: SizedBox(
                          height: 220.0,
                          child: NetWorthChart(
                            samples: samples,
                            unit: sampleUnit,
                            primaryCurrency: primaryCurrency,
                          ),
                        ),
                      )
                    else
                      Frame(
                        child: SizedBox(
                          height: 120.0,
                          child: Center(
                            child: Text(
                              "tabs.stats.analytics.netWorth.notEnoughHistory"
                                  .t(context),
                            ),
                          ),
                        ),
                      ),
                    if (missingRates) ...[
                      const SizedBox(height: 8.0),
                      MissingRatesNotice(
                        message: "tabs.stats.analytics.missingRatesBalances".t(
                          context,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32.0),
                    ListHeader(
                      "tabs.stats.analytics.netWorth.byAccount".t(context),
                    ),
                    const SizedBox(height: 8.0),
                    ..._buildShareRows(context),
                    const SizedBox(height: 96.0),
                  ],
                ),
              ),
      ),
    );
  }

  List<Widget> _buildShareRows(BuildContext context) {
    if (shares.isEmpty) {
      return [
        Frame(
          child: Text("tabs.stats.analytics.netWorth.noAccounts".t(context)),
        ),
      ];
    }

    // Share is relative to the gross size of holdings (sum of absolute
    // balances) so debt and assets each get a sensible bar instead of one
    // overflowing the other.
    final double gross = shares.fold<double>(
      0.0,
      (sum, share) => sum + share.amount.abs(),
    );

    return shares
        .map(
          (share) => AccountShareTile(
            share: share,
            gross: gross,
            primaryCurrency: primaryCurrency,
          ),
        )
        .toList();
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

    try {
      accounts = ObjectBox()
          .getAccounts(false)
          .where((account) => account.excludeFromTotalBalance != true)
          .toList();

      final DurationUnit unit = RangeData.getOptimalUnit(range);
      final List<DateTime> anchors = _anchors(range, unit);

      bool missing = false;

      final List<NetWorthSample> nextSamples = anchors.map((anchor) {
        double total = 0.0;
        for (final Account account in accounts) {
          final double? value = account
              .balanceAt(anchor)
              .tryConvertAmount(primaryCurrency, rates);
          total += value ?? 0.0;
          missing = missing || value == null;
        }
        return NetWorthSample(anchor, total);
      }).toList();

      final List<AccountBalanceShare> nextShares = [];
      for (final Account account in accounts) {
        final double? value = account.balance.tryConvertAmount(
          primaryCurrency,
          rates,
        );
        missing = missing || value == null;

        if ((value ?? 0.0) == 0.0) continue;
        nextShares.add(AccountBalanceShare(account, value!));
      }
      nextShares.sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));

      sampleUnit = unit;
      samples = nextSamples;
      shares = nextShares;
      missingRates = missing;
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }

  /// Even anchors stepping through [range] by [unit], capped at a readable
  /// count, with the final anchor pinned to "now" so the latest figure is
  /// live (when the range includes the present).
  List<DateTime> _anchors(TimeRange range, DurationUnit unit) {
    final DateTime now = DateTime.now();
    final DateTime start = range.from;
    final DateTime end = range.to.isAfter(now) ? now : range.to;

    if (!end.isAfter(start)) {
      return [end];
    }

    final int stepMicros = unit.microseconds;
    final int spanMicros = end.difference(start).inMicroseconds;

    // Keep at most ~24 points; never fewer than one step.
    final int rawCount = (spanMicros / stepMicros).floor();
    final int count = rawCount.clamp(1, 24);
    final double strideMicros = spanMicros / count;

    final List<DateTime> anchors = [];
    for (int i = 0; i < count; i++) {
      anchors.add(
        start.add(Duration(microseconds: (strideMicros * i).round())),
      );
    }
    anchors.add(end);

    return anchors;
  }
}

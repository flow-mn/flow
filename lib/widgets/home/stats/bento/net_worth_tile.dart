import "package:flow/data/money.dart";
import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/home/stats/bento/bento_tile.dart";
import "package:flow/widgets/home/stats/bento/net_worth_sparkline.dart";
import "package:flow/widgets/stats/money_delta_label.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";

/// Bento preview of net worth: the current total, its change over the sampled
/// window, and a minimal sparkline. Range-independent — it always trails the
/// last [_months] months regardless of the Stats range selector.
class NetWorthTile extends StatefulWidget {
  const NetWorthTile({super.key});

  @override
  State<NetWorthTile> createState() => _NetWorthTileState();
}

class _NetWorthTileState extends State<NetWorthTile>
    with PrimaryCurrencyDependentState<NetWorthTile> {
  static const int _months = 6;

  bool busy = true;
  bool loaded = false;

  List<double> samples = [];

  @override
  Widget build(BuildContext context) {
    final bool hasTrend = samples.length >= 2;
    final double currentAmount = samples.isEmpty ? 0.0 : samples.last;
    final double firstAmount = samples.isEmpty ? 0.0 : samples.first;

    return BentoTile(
      label: "tabs.stats.analytics.netWorth".t(context),
      icon: Symbols.trending_up_rounded,
      height: 188.0,
      busy: busy && !loaded,
      onTap: () => context.push("/stats/net-worth"),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          MoneyText(
            Money(currentAmount, primaryCurrency),
            style: context.textTheme.headlineMedium,
            autoSize: true,
            initiallyAbbreviated: true,
          ),
          const SizedBox(height: 4.0),
          MoneyDeltaLabel(
            delta: Money(currentAmount - firstAmount, primaryCurrency),
            suffixLabel: "tabs.stats.analytics.inRange".t(
              context,
              "${_months}M",
            ),
            iconSize: 16.0,
            initiallyAbbreviated: true,
            suffixStyle: context.textTheme.bodySmall?.semi(context),
          ),
          const SizedBox(height: 12.0),
          Expanded(
            child: hasTrend
                ? NetWorthSparkline(
                    samples: samples,
                    color: context.colorScheme.primary,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> fetch() async {
    try {
      final List<Account> accounts = ObjectBox()
          .getAccounts(false)
          .where((account) => account.excludeFromTotalBalance != true)
          .toList();

      final List<DateTime> anchors = _monthAnchors(_months);

      samples = anchors.map((anchor) {
        double total = 0.0;
        for (final Account account in accounts) {
          total +=
              account
                  .balanceAt(anchor)
                  .tryConvertAmount(primaryCurrency, rates) ??
              0.0;
        }
        return total;
      }).toList();
      loaded = true;
    } finally {
      busy = false;
      if (mounted) setState(() {});
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
        anchors.add(DateTime(now.year, now.month - i + 1, 0, 23, 59, 59));
      }
    }

    return anchors;
  }
}

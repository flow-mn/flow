import "dart:io";

import "package:flow/constants.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/utils/extensions.dart";
import "package:flutter/foundation.dart";
import "package:home_widget/home_widget.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("NetWorthWidgetSync");

/// Feeds the "Net worth" home screen widget: today's total plus a 30-day
/// trend the widget draws as a sparkline.
///
/// Uses the same rules as the Net worth stats page: accounts excluded from the
/// total balance are left out, and non-primary balances are converted with the
/// primary currency's rates (unconvertible ones count as 0).
class NetWorthWidgetSync {
  static const int days = 30;

  static Future<void> sync() async {
    try {
      final Stopwatch stopwatch = Stopwatch()..start();
      final String primaryCurrency = UserPreferencesService().primaryCurrency;
      final ExchangeRates? rates = ExchangeRatesService()
          .getPrimaryCurrencyRates();

      final List<Account> accounts = ObjectBox()
          .getAccounts(false)
          .where((account) => account.excludeFromTotalBalance != true)
          .toList();

      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);

      // [days] anchors: the start of each of the previous `days - 1` days,
      // then "now", so the chart and the delta span the full 30 days the
      // label promises and the last point matches the app. Calendar days, not
      // 24h steps, so a DST change doesn't shift an anchor off midnight.
      final List<DateTime> anchors = [
        for (int i = days - 1; i >= 1; i--)
          DateTime(today.year, today.month, today.day - i),
        now,
      ];

      final List<double> samples = List.filled(anchors.length, 0.0);
      for (final Account account in accounts) {
        final List<double> balances = balancesAt(account, anchors);
        for (int i = 0; i < anchors.length; i++) {
          samples[i] +=
              Money(
                balances[i],
                account.currency,
              ).tryConvertAmount(primaryCurrency, rates) ??
              0.0;
        }
      }

      final Money current = Money(samples.last, primaryCurrency);
      final Money delta = Money(samples.last - samples.first, primaryCurrency);

      final bool obscure =
          UserPreferencesService().privacyModeUponLaunch ||
          LocalPreferences().requireLocalAuth.get();

      String format(Money money) {
        final String text = money.formatMoney(compact: true);
        return obscure ? text.digitsObscured : text;
      }

      final String deltaText =
          (delta.amount >= 0 ? "+" : "−") + format(delta.abs());

      if (Platform.isIOS) {
        await HomeWidget.setAppGroupId(iOSAppGroupId);
      }

      await HomeWidget.saveWidgetData(
        "netWorthLabel",
        "tabs.stats.analytics.netWorth".tr(),
      );
      await HomeWidget.saveWidgetData("netWorthAmount", format(current));
      // Hidden with the amounts: the sign and the up/down arrow would still
      // tell whether the balance went up. Both widgets drop the row when null.
      await HomeWidget.saveWidgetData<String>(
        "netWorthDelta",
        obscure ? null : deltaText,
      );
      await HomeWidget.saveWidgetData(
        "netWorthDeltaPositive",
        delta.amount >= 0,
      );
      await HomeWidget.saveWidgetData(
        "netWorthRangeLabel",
        "select.timeRange.last30Days".tr(),
      );
      // Hidden with the amounts: the shape of the line still gives away how
      // much the balance moved. Both widgets skip the chart below 2 samples.
      await HomeWidget.saveWidgetData(
        "netWorthSamples",
        obscure ? "" : samples.map((v) => v.toStringAsFixed(2)).join(","),
      );

      await HomeWidget.updateWidget(
        name: "FlowNetWorthWidget",
        iOSName: "FlowNetWorthWidget",
        androidName: "NetWorthReceiver",
        qualifiedAndroidName: "mn.flow.flow.glance.NetWorthReceiver",
      );

      _log.finest(
        "Synced net worth widget (${accounts.length} accounts, ${stopwatch.elapsedMilliseconds} ms)",
      );
    } catch (e) {
      _log.warning("Failed to sync net worth widget: $e");
    }
  }

  // Rolls recent transactions back from the latest balance, instead of
  // summing the whole history once per anchor.
  @visibleForTesting
  static List<double> balancesAt(Account account, List<DateTime> anchors) {
    final double latest = account.balanceAt(anchors.last).amount;

    final Query<Transaction> query = ObjectBox()
        .box<Transaction>()
        .query(
          Transaction_.account.equals(account.id) &
              Transaction_.transactionDate.greaterThanDate(anchors.first) &
              Transaction_.transactionDate.lessOrEqualDate(anchors.last) &
              (Transaction_.isPending.isNull() |
                  Transaction_.isPending.notEquals(true)) &
              (Transaction_.isDeleted.isNull() |
                  Transaction_.isDeleted.notEquals(true)),
        )
        .build();

    final List<Transaction> recent;
    try {
      recent = query.find();
    } finally {
      query.close();
    }

    return [
      for (final DateTime anchor in anchors)
        recent
            .where((transaction) => transaction.transactionDate.isAfter(anchor))
            .fold(
              latest,
              (balance, transaction) => balance - transaction.amount,
            ),
    ];
  }
}

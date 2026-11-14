import "dart:io";

import "package:flow/constants.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/utils/extensions.dart";
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
      final ExchangeRates? rates =
          ExchangeRatesService().getPrimaryCurrencyRates();

      final List<Account> accounts = ObjectBox()
          .getAccounts(false)
          .where((account) => account.excludeFromTotalBalance != true)
          .toList();

      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);

      double totalAt(DateTime anchor) {
        double total = 0.0;
        for (final Account account in accounts) {
          total +=
              account
                  .balanceAt(anchor)
                  .tryConvertAmount(primaryCurrency, rates) ??
              0.0;
        }
        return total;
      }

      // [days] samples: the balance at the start of each of the previous
      // `days - 1` days, then "now", so the chart and the delta span the full
      // 30 days the label promises and the last point matches the app.
      final List<double> samples = [
        for (int i = days - 1; i >= 1; i--)
          totalAt(today.subtract(Duration(days: i))),
        totalAt(now),
      ];

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
      await HomeWidget.saveWidgetData("netWorthDelta", deltaText);
      await HomeWidget.saveWidgetData(
        "netWorthDeltaPositive",
        delta.amount >= 0,
      );
      await HomeWidget.saveWidgetData(
        "netWorthRangeLabel",
        "select.timeRange.last30Days".tr(),
      );
      // The chart shape is not hidden in privacy mode: without an axis it
      // reveals the trend, not the amounts.
      await HomeWidget.saveWidgetData(
        "netWorthSamples",
        samples.map((v) => v.toStringAsFixed(2)).join(","),
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
}

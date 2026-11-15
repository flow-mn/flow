import "dart:async";
import "dart:io";

import "package:flow/entity/account.dart";
import "package:flow/entity/budget.dart";
import "package:flow/objectbox.dart";
import "package:flow/services/budget_widget_sync.dart";
import "package:flow/services/net_worth_widget_sync.dart";
import "package:flow/services/widget_summary_sync.dart";
import "package:home_widget/home_widget.dart";
import "package:intl/intl.dart";
import "package:intl/number_symbols.dart";

/// One entry point for refreshing every home-screen widget.
///
/// The triggers for "widgets are stale" — a transaction changed, the locale
/// changed, the primary currency changed, the app resumed — are the same for
/// all of them. Fanning those out to each widget's own sync at four separate
/// call sites is how one widget quietly stops updating: someone adds a fifth
/// trigger, or a sixth widget, and misses a wiring.
class HomeWidgets {
  static StreamSubscription<void>? _budgetSubscription;
  static StreamSubscription<void>? _accountSubscription;

  /// Home-screen widgets only exist on mobile
  static bool get supported => Platform.isIOS || Platform.isAndroid;

  /// Refreshes every widget. Safe to call often; each sync swallows its own
  /// failures so one broken widget can't stop the others.
  static Future<void> syncAll() async {
    if (!supported) return;

    await Future.wait([
      WidgetSummarySync.sync(),
      BudgetWidgetSync.sync(),
      NetWorthWidgetSync.sync(),
      if (Platform.isAndroid) _syncNumberSymbols(),
    ]);
  }

  /// Widget-picker previews format sample amounts like the real ones, and
  /// need the app's separators when a synced amount has none ("685 мян").
  static Future<void> _syncNumberSymbols() async {
    final NumberSymbols symbols = NumberFormat.decimalPattern(
      Intl.defaultLocale,
    ).symbols;

    await HomeWidget.saveWidgetData(
      "numberDecimalSeparator",
      symbols.DECIMAL_SEP,
    );
    await HomeWidget.saveWidgetData("numberGroupSeparator", symbols.GROUP_SEP);
  }

  /// Starts watching the data that only widgets care about.
  ///
  /// Transactions already have a listener wired in `main`. Budgets do not, and
  /// creating or editing one touches no transaction — so without this, a new
  /// budget wouldn't reach the home screen until something unrelated happened.
  static void watchForChanges() {
    _budgetSubscription ??= ObjectBox().box<Budget>().query().watch().listen(
      (_) => unawaited(BudgetWidgetSync.sync()),
    );
    // Same for accounts: excluding one from the total balance, or adding or
    // archiving one, changes net worth without touching any transaction.
    // (New exchange rates already trigger a full sync from `main`.)
    _accountSubscription ??= ObjectBox().box<Account>().query().watch().listen(
      (_) => unawaited(NetWorthWidgetSync.sync()),
    );
  }

  static void dispose() {
    _budgetSubscription?.cancel();
    _budgetSubscription = null;
    _accountSubscription?.cancel();
    _accountSubscription = null;
  }
}

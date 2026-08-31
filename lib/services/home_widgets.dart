import "dart:async";

import "package:flow/entity/budget.dart";
import "package:flow/objectbox.dart";
import "package:flow/services/budget_widget_sync.dart";
import "package:flow/services/widget_summary_sync.dart";

/// One entry point for refreshing every home-screen widget.
///
/// The triggers for "widgets are stale" — a transaction changed, the locale
/// changed, the primary currency changed, the app resumed — are the same for
/// all of them. Fanning those out to each widget's own sync at four separate
/// call sites is how one widget quietly stops updating: someone adds a fifth
/// trigger, or a sixth widget, and misses a wiring.
class HomeWidgets {
  static StreamSubscription<void>? _budgetSubscription;

  /// Refreshes every widget. Safe to call often; each sync swallows its own
  /// failures so one broken widget can't stop the others.
  static Future<void> syncAll() async {
    await Future.wait([WidgetSummarySync.sync(), BudgetWidgetSync.sync()]);
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
  }

  static void dispose() {
    _budgetSubscription?.cancel();
    _budgetSubscription = null;
  }
}

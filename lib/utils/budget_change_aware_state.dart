import "dart:async";

import "package:flow/entity/budget.dart";
import "package:flow/objectbox.dart";
import "package:flow/utils/primary_currency_dependent_state.dart";
import "package:flutter/widgets.dart";

/// Re-runs [PrimaryCurrencyDependentState.fetch] whenever a budget is created,
/// edited, or deleted.
///
/// [PrimaryCurrencyDependentState] watches transactions, the primary currency,
/// and exchange rates — everything a budget's *spend* depends on, but nothing
/// about the budget itself. Screens that summarize budgets need both: creating
/// your first budget touches no transaction, so without this a budgets overview
/// still reads "No budgets yet" after you just made one.
///
/// Watches the box rather than hooking the write path, so it can't be bypassed
/// by a caller that forgets to announce its write.
mixin BudgetChangeAwareState<T extends StatefulWidget>
    on PrimaryCurrencyDependentState<T> {
  StreamSubscription<void>? _budgetSubscription;

  @override
  void initState() {
    super.initState();

    // No `triggerImmediately` — the superclass already fetches on init, and an
    // immediate trigger would double every screen's first load.
    _budgetSubscription = ObjectBox().box<Budget>().query().watch().listen(
      (_) => fetch(),
    );
  }

  @override
  void dispose() {
    _budgetSubscription?.cancel();
    super.dispose();
  }
}

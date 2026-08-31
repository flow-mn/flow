import "package:flow/entity/budget.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/budget.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/widgets/budgets/budget_card.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/rates_missing_error_box.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  QueryBuilder<Budget> qb() => BudgetService().allQb();

  @override
  Widget build(BuildContext context) {
    final bool showMissingExchangeRatesWarning =
        ExchangeRatesService().getPrimaryCurrencyRates() == null &&
        TransitiveLocalPreferences().usesNonPrimaryCurrency.get();

    return Scaffold(
      appBar: AppBar(title: Text("budgets".t(context))),
      body: SafeArea(
        child: StreamBuilder<List<Budget>>(
          stream: qb()
              .watch(triggerImmediately: true)
              .map((event) => event.find()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Spinner.center();
            }

            final List<Budget> budgets = snapshot.requireData;

            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 6.0,
                  ),
                  child: Button(
                    onTap: () => context.push("/budgets/new"),
                    leading: const Icon(Symbols.add_rounded),
                    child: Text("budgets.new".t(context)),
                  ),
                ),
                if (showMissingExchangeRatesWarning)
                  const RatesMissingErrorBox(),
                ...budgets.map((budget) => BudgetCard(budget: budget)),
              ],
            );
          },
        ),
      ),
    );
  }
}

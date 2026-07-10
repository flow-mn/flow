import "package:flow/data/exchange_rates.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/budget.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/services/budget.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/widgets/analytics/bullet_chart.dart";
import "package:flow/widgets/analytics/insight_card.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Shows a budget's spent-vs-amount for its current period.
///
/// Watches the budget's matching transactions, so it live-updates as
/// transactions change.
class BudgetCard extends StatelessWidget {
  final Budget budget;

  const BudgetCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    final ExchangeRates? rates = ExchangeRatesService()
        .getPrimaryCurrencyRates();

    return StreamBuilder<List<Transaction>>(
      stream: BudgetService()
          .transactionsQb(budget)
          .watch(triggerImmediately: true)
          .map((event) => event.find()),
      builder: (context, snapshot) {
        final SingleCurrencyFlow spentFlow = BudgetService().computeSpent(
          budget,
          snapshot.data ?? const [],
          rates,
        );

        final double spent = spentFlow.totalExpense.amount.abs();

        return InsightCard(
          icon: Symbols.money_bag_rounded,
          label: budget.name,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MoneyText(Money(spent, budget.currency)),
              const Text(" / "),
              MoneyText(Money(budget.amount, budget.currency)),
            ],
          ),
          subtitle: _periodLabel(),
          onTap: () => context.push("/budgets/${budget.id}"),
          child: BulletChart(value: spent, target: budget.amount),
        );
      },
    );
  }

  String _periodLabel() {
    final TimeRange range = budget.timeRange;

    return switch (range) {
      MonthTimeRange monthTimeRange => monthTimeRange.from.format(
        payload: monthTimeRange.from.isAtSameYearAs(DateTime.now())
            ? "MMMM"
            : "MMMM YYYY",
      ),
      YearTimeRange yearTimeRange => yearTimeRange.year.toString(),
      _ => "${range.from.toMoment().ll} -> ${range.to.toMoment().ll}",
    };
  }
}

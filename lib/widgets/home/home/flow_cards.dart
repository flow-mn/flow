import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/data/money_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs.dart";
import "package:flow/widgets/home/home/info_card.dart";
import "package:flutter/cupertino.dart";

class FlowCards extends StatefulWidget {
  final List<Transaction>? transactions;
  final ExchangeRates? rates;

  const FlowCards({super.key, required this.transactions, required this.rates});

  @override
  State<FlowCards> createState() => _FlowCardsState();
}

class _FlowCardsState extends State<FlowCards> {
  @override
  Widget build(BuildContext context) {
    final Money totalBalance = ObjectBox().getPrimaryCurrencyGrandTotal();
    final MoneyFlow? flow = widget.transactions?.flow;
    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    final String flowText = switch ((flow, widget.rates)) {
      (null, _) => "-",
      (MoneyFlow moneyFlow, null) =>
        moneyFlow.getFlowByCurrency(primaryCurrency).moneyCompact,
      (MoneyFlow moneyFlow, ExchangeRates exchangeRates) =>
        moneyFlow.getTotalFlow(exchangeRates, primaryCurrency).moneyCompact,
    };

    final String expensesText = switch ((flow, widget.rates)) {
      (null, _) => "-",
      (MoneyFlow moneyFlow, null) =>
        moneyFlow.getExpenseByCurrency(primaryCurrency).moneyCompact,
      (MoneyFlow moneyFlow, ExchangeRates exchangeRates) =>
        moneyFlow.getTotalExpense(exchangeRates, primaryCurrency).moneyCompact,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InfoCard(
                  title: "tabs.home.flow".t(context),
                  value: flowText,
                ),
                const SizedBox(height: 12.0),
                InfoCard(
                  title: TransactionType.expense.localizedNameContext(context),
                  value: expensesText,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          FutureBuilder<Money?>(
            future: widget.rates == null ? null : ObjectBox().getGrandTotal(),
            builder: (context, snapshot) {
              final String value = snapshot.hasData
                  ? snapshot.data!.moneyCompact
                  : totalBalance.moneyCompact;

              return Expanded(
                child: InfoCard(
                  title: "tabs.home.totalBalance".t(context),
                  value: value,
                  large: true,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

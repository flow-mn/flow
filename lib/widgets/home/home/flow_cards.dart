import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money.dart";
import "package:flow/data/money_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/home/home/info_card.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/services.dart";

class FlowCards extends StatefulWidget {
  final List<Transaction>? transactions;
  final ExchangeRates? rates;

  const FlowCards({super.key, required this.transactions, required this.rates});

  @override
  State<FlowCards> createState() => _FlowCardsState();
}

class _FlowCardsState extends State<FlowCards> {
  final AutoSizeGroup autoSizeGroup = AutoSizeGroup();

  late bool abbreviate;
  late bool excludeTransferFromFlow;

  @override
  void initState() {
    super.initState();

    abbreviate = !LocalPreferences().preferFullAmounts.get();
    LocalPreferences().preferFullAmounts.addListener(_updateAbbreviation);

    excludeTransferFromFlow = LocalPreferences().excludeTransferFromFlow.get();
    LocalPreferences()
        .excludeTransferFromFlow
        .addListener(_updateExcludeTransferFromFlow);
  }

  @override
  void dispose() {
    LocalPreferences().preferFullAmounts.removeListener(_updateAbbreviation);
    LocalPreferences()
        .excludeTransferFromFlow
        .removeListener(_updateExcludeTransferFromFlow);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MoneyFlow? flow = excludeTransferFromFlow
        ? widget.transactions?.nonPending.nonTransfers.flow
        : widget.transactions?.nonPending.flow;
    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    final Money? totalExpense = switch ((flow, widget.rates)) {
      (null, _) => null,
      (MoneyFlow moneyFlow, null) =>
        moneyFlow.getExpenseByCurrency(primaryCurrency),
      (MoneyFlow moneyFlow, ExchangeRates exchangeRates) =>
        moneyFlow.getTotalExpense(exchangeRates, primaryCurrency),
    };

    final Money? totalIncome = switch ((flow, widget.rates)) {
      (null, _) => null,
      (MoneyFlow moneyFlow, null) =>
        moneyFlow.getIncomeByCurrency(primaryCurrency),
      (MoneyFlow moneyFlow, ExchangeRates exchangeRates) =>
        moneyFlow.getTotalIncome(exchangeRates, primaryCurrency),
    };

    return Row(
      key: ValueKey(abbreviate),
      children: [
        Expanded(
          child: InfoCard(
            title: TransactionType.income.localizedNameContext(context),
            icon: Icon(
              TransactionType.income.icon,
              color: TransactionType.income.color(context),
            ),
            moneyText: MoneyText(
              totalIncome,
              style: context.textTheme.displaySmall,
              autoSizeGroup: autoSizeGroup,
              autoSize: true,
              initiallyAbbreviated: abbreviate,
              onTap: handleTap,
            ),
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: InfoCard(
            title: TransactionType.expense.localizedNameContext(context),
            icon: Icon(
              TransactionType.expense.icon,
              color: TransactionType.expense.color(context),
            ),
            moneyText: MoneyText(
              totalExpense,
              style: context.textTheme.displaySmall,
              autoSizeGroup: autoSizeGroup,
              autoSize: true,
              initiallyAbbreviated: abbreviate,
              onTap: handleTap,
            ),
          ),
        ),
      ],
    );
  }

  void handleTap() {
    if (LocalPreferences().enableHapticFeedback.get()) {
      HapticFeedback.lightImpact();
    }

    setState(() => abbreviate = !abbreviate);
  }

  _updateAbbreviation() {
    abbreviate = !LocalPreferences().preferFullAmounts.get();

    if (mounted) setState(() {});
  }

  _updateExcludeTransferFromFlow() {
    excludeTransferFromFlow = LocalPreferences().excludeTransferFromFlow.get();

    if (mounted) setState(() {});
  }
}

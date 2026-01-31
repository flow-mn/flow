import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/money.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/home/home/info_card.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/services.dart";

class FlowCards extends StatefulWidget {
  final Money? totalIncome;
  final Money? totalExpense;

  const FlowCards({
    super.key,
    required this.totalExpense,
    required this.totalIncome,
  });

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

    excludeTransferFromFlow = UserPreferencesService().excludeTransfersFromFlow;
    UserPreferencesService().valueNotifier.addListener(
      _updateExcludeTransferFromFlow,
    );
  }

  @override
  void dispose() {
    LocalPreferences().preferFullAmounts.removeListener(_updateAbbreviation);
    UserPreferencesService().valueNotifier.removeListener(
      _updateExcludeTransferFromFlow,
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            money: styledMoney(widget.totalIncome, context),
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
            money: styledMoney(widget.totalExpense, context),
          ),
        ),
      ],
    );
  }

  Widget styledMoney(Money? amount, BuildContext context) {
    return Container(
      height: MediaQuery.of(context).textScaler.scale(
        context.textTheme.displaySmall!.fontSize! *
            context.textTheme.displaySmall!.height!,
      ),
      alignment: AlignmentDirectional.centerStart,
      child: MoneyText(
        amount,
        style: context.textTheme.displaySmall,
        autoSizeGroup: autoSizeGroup,
        autoSize: true,
        initiallyAbbreviated: abbreviate,
        onTap: handleTap,
      ),
    );
  }

  void handleTap() {
    if (LocalPreferences().enableHapticFeedback.get()) {
      HapticFeedback.lightImpact();
    }

    setState(() => abbreviate = !abbreviate);
  }

  void _updateAbbreviation() {
    abbreviate = !LocalPreferences().preferFullAmounts.get();

    if (mounted) setState(() {});
  }

  void _updateExcludeTransferFromFlow() {
    excludeTransferFromFlow = UserPreferencesService().excludeTransfersFromFlow;

    if (mounted) setState(() {});
  }
}

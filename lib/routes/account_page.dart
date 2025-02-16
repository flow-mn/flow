import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/money_flow.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/error_page.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/category/transactions_info.dart";
import "package:flow/widgets/flow_card.dart";
import "package:flow/widgets/general/pending_transactions_header.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flow/widgets/grouped_transaction_list.dart";
import "package:flow/widgets/no_result.dart";
import "package:flow/widgets/rates_missing_warning.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flow/widgets/transactions_date_header.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class AccountPage extends StatefulWidget {
  static const EdgeInsets _defaultHeaderPadding = EdgeInsets.fromLTRB(
    16.0,
    16.0,
    16.0,
    8.0,
  );

  final int accountId;
  final TimeRange? initialRange;

  final EdgeInsets headerPadding;
  final EdgeInsets listPadding;

  const AccountPage({
    super.key,
    required this.accountId,
    this.initialRange,
    this.listPadding = const EdgeInsets.symmetric(vertical: 16.0),
    this.headerPadding = _defaultHeaderPadding,
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final AutoSizeGroup autoSizeGroup = AutoSizeGroup();

  bool busy = false;

  QueryBuilder<Transaction> qb(TimeRange range) => TransactionFilter(
        accounts: [account!.uuid],
        range: TransactionFilterTimeRange.fromTimeRange(range),
        sortBy: TransactionSortField.transactionDate,
        sortDescending: true,
      ).queryBuilder();

  late Account? account;

  late TimeRange range;

  @override
  void initState() {
    super.initState();

    account = ObjectBox().box<Account>().get(widget.accountId);
    range = widget.initialRange ?? TimeRange.thisMonth();
  }

  @override
  Widget build(BuildContext context) {
    if (this.account == null) return const ErrorPage();

    final Account account = this.account!;
    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();
    final ExchangeRates? rates =
        ExchangeRatesService().getPrimaryCurrencyRates();
    final bool showMissingExchangeRatesWarning = rates == null &&
        TransitiveLocalPreferences().transitiveUsesSingleCurrency.get();

    return StreamBuilder<List<Transaction>>(
      stream: qb(range)
          .watch(triggerImmediately: true)
          .map((event) => event.find()),
      builder: (context, snapshot) {
        final List<Transaction>? transactions = snapshot.data;

        final bool noTransactions = (transactions?.length ?? 0) == 0;

        final DateTime now = Moment.now().startOfNextMinute();

        final Map<TimeRange, List<Transaction>> grouped = transactions
                ?.where((transaction) =>
                    !transaction.transactionDate.isAfter(now) &&
                    transaction.isPending != true)
                .groupByDate() ??
            {};

        final List<Transaction> pendingTransactions = transactions
                ?.where((transaction) =>
                    transaction.transactionDate.isAfter(now) ||
                    transaction.isPending == true)
                .toList() ??
            [];

        final int actionNeededCount = pendingTransactions
            .where((transaction) => transaction.confirmable())
            .length;

        final Map<TimeRange, List<Transaction>> pendingTransactionsGrouped =
            pendingTransactions.groupByRange(
          rangeFn: (transaction) =>
              CustomTimeRange(Moment.minValue, Moment.maxValue),
        );

        final MoneyFlow flow = transactions?.nonPending.flow ?? MoneyFlow();

        const double firstHeaderTopPadding = 0.0;

        final Widget header = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TimeRangeSelector(
              initialValue: range,
              onChanged: onRangeChange,
            ),
            const SizedBox(height: 8.0),
            TransactionsInfo(
              count: transactions?.nonPending.length,
              flow: rates == null
                  ? flow.getFlowByCurrency(primaryCurrency)
                  : flow.getTotalFlow(rates, primaryCurrency),
              icon: account.icon,
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: FlowCard(
                    flow: rates == null
                        ? flow.getIncomeByCurrency(primaryCurrency)
                        : flow.getTotalIncome(rates, primaryCurrency),
                    type: TransactionType.income,
                    autoSizeGroup: autoSizeGroup,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: FlowCard(
                    flow: rates == null
                        ? flow.getExpenseByCurrency(primaryCurrency)
                        : flow.getTotalExpense(rates, primaryCurrency),
                    type: TransactionType.expense,
                    autoSizeGroup: autoSizeGroup,
                  ),
                ),
              ],
            ),
            if (showMissingExchangeRatesWarning) ...[
              const SizedBox(height: 12.0),
              RatesMissingWarning(),
            ],
          ],
        );

        final EdgeInsets headerPaddingOutOfList = widget.headerPadding +
            widget.listPadding.copyWith(bottom: 0, top: 0) +
            const EdgeInsets.only(top: firstHeaderTopPadding);

        return Scaffold(
          appBar: AppBar(
            title: Text(account.name),
            actions: [
              IconButton(
                icon: const Icon(Symbols.edit_rounded),
                onPressed: () => edit(),
                tooltip: "general.edit".t(context),
              ),
            ],
          ),
          body: SafeArea(
            child: switch (busy) {
              true => Padding(
                  padding: headerPaddingOutOfList,
                  child: Column(
                    children: [
                      header,
                      const Expanded(child: Spinner.center()),
                    ],
                  ),
                ),
              false when noTransactions => Padding(
                  padding: headerPaddingOutOfList,
                  child: Column(
                    children: [
                      header,
                      const Expanded(child: NoResult()),
                    ],
                  ),
                ),
              _ => GroupedTransactionList(
                  header: header,
                  transactions: grouped,
                  pendingTransactions: pendingTransactionsGrouped,
                  pendingDivider: WavyDivider(),
                  listPadding: widget.listPadding,
                  headerPadding: widget.headerPadding,
                  firstHeaderTopPadding: firstHeaderTopPadding,
                  headerBuilder: (
                    pendingGroup,
                    range,
                    transactions,
                  ) {
                    if (pendingGroup) {
                      return PendingTransactionsHeader(
                        transactions: transactions,
                        range: range,
                        badgeCount: actionNeededCount,
                      );
                    }

                    return TransactionListDateHeader(
                      transactions: transactions,
                      range: range,
                    );
                  },
                )
            },
          ),
        );
      },
    );
  }

  void onRangeChange(TimeRange newRange) {
    setState(() {
      range = newRange;
    });
  }

  Future<void> edit() async {
    await context.push("/account/${account!.id}/edit");

    account = ObjectBox().box<Account>().get(widget.accountId);

    if (mounted) {
      setState(() {});
    }
  }
}

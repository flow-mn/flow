import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/exchange_rates.dart";
import "package:flow/data/multi_currency_flow.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/error_page.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/category/transactions_info.dart";
import "package:flow/widgets/flow_card.dart";
import "package:flow/widgets/general/pending_transactions_header.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flow/widgets/grouped_transactions_list_view.dart";
import "package:flow/widgets/no_result.dart";
import "package:flow/widgets/rates_missing_error_box.dart";
import "package:flow/widgets/time_range_selector.dart";
import "package:flow/widgets/transactions_date_header.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class CategoryPage extends StatefulWidget {
  static const EdgeInsets _defaultHeaderPadding = EdgeInsets.fromLTRB(
    16.0,
    16.0,
    16.0,
    8.0,
  );

  final int categoryId;
  final TimeRange? initialRange;

  final EdgeInsets headerPadding;

  const CategoryPage({
    super.key,
    required this.categoryId,
    this.initialRange,
    this.headerPadding = _defaultHeaderPadding,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final AutoSizeGroup autoSizeGroup = AutoSizeGroup();

  bool busy = false;

  QueryBuilder<Transaction> qb(TimeRange range) => TransactionFilter(
    range: TransactionFilterTimeRange.fromTimeRange(range),
    categories: [category!.uuid],
    sortBy: TransactionSortField.transactionDate,
    sortDescending: true,
  ).queryBuilder();

  late Category? category;

  late TimeRange range;

  @override
  void initState() {
    super.initState();

    category = ObjectBox().box<Category>().get(widget.categoryId);
    range = widget.initialRange ?? TimeRange.thisMonth();
  }

  @override
  Widget build(BuildContext context) {
    if (this.category == null) return const ErrorPage();

    final Category category = this.category!;
    final String primaryCurrency = UserPreferencesService().primaryCurrency;
    final ExchangeRates? rates = ExchangeRatesService()
        .getPrimaryCurrencyRates();
    final bool showMissingExchangeRatesWarning =
        rates == null &&
        TransitiveLocalPreferences().usesNonPrimaryCurrency.get();

    return StreamBuilder<List<Transaction>>(
      stream: qb(
        range,
      ).watch(triggerImmediately: true).map((event) => event.find()),
      builder: (context, snapshot) {
        final List<Transaction>? transactions = snapshot.data;

        final bool noTransactions = (transactions?.length ?? 0) == 0;

        final DateTime now = Moment.now().startOfNextMinute();

        final Map<TimeRange, List<Transaction>> grouped =
            transactions
                ?.where(
                  (transaction) =>
                      !transaction.transactionDate.isAfter(now) &&
                      transaction.isPending != true,
                )
                .groupByDate() ??
            {};

        final List<Transaction> pendingTransactions =
            transactions
                ?.where(
                  (transaction) =>
                      transaction.transactionDate.isAfter(now) ||
                      transaction.isPending == true,
                )
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

        final MultiCurrencyFlow flow =
            transactions?.nonPending.flow ?? MultiCurrencyFlow();
        final SingleCurrencyFlow mergedFlow = flow.merge(
          primaryCurrency,
          rates,
        );

        final Widget header = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TimeRangeSelector(initialValue: range, onChanged: onRangeChange),
            const SizedBox(height: 8.0),
            TransactionsInfo(
              count: transactions?.nonPending.length,
              flow: mergedFlow.totalFlow,
              icon: category.icon,
              colorScheme: category.colorScheme,
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: FlowCard(
                    flow: mergedFlow.totalIncome,
                    type: TransactionType.income,
                    autoSizeGroup: autoSizeGroup,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: FlowCard(
                    flow: mergedFlow.totalExpense,
                    type: TransactionType.expense,
                    autoSizeGroup: autoSizeGroup,
                  ),
                ),
              ],
            ),
            if (showMissingExchangeRatesWarning) ...[
              const SizedBox(height: 12.0),
              RatesMissingErrorBox(),
            ],
          ],
        );

        final EdgeInsets headerPaddingOutOfList = widget.headerPadding;

        return Scaffold(
          appBar: AppBar(
            title: Text(category.name),
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
              _ => GroupedTransactionsListView(
                mainHeader: header,
                transactions: grouped,
                pendingTransactions: pendingTransactionsGrouped,
                pendingDivider: WavyDivider(),
                groupHeaderPadding: widget.headerPadding,
                mainHeaderPadding: EdgeInsets.zero,
                headerBuilder: (pendingGroup, range, transactions) {
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
              ),
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
    await context.push("/category/${category!.id}/edit");

    category = ObjectBox().box<Category>().get(widget.categoryId);

    if (mounted) {
      setState(() {});
    }
  }
}

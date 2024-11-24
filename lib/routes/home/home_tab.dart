import "package:flow/data/exchange_rates.dart";
import "package:flow/data/transactions_filter.dart";
import "package:flow/data/pending_transactions_duration.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/default_transaction_filter_head.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flow/widgets/grouped_transaction_list.dart";
import "package:flow/widgets/home/greetings_bar.dart";
import "package:flow/widgets/home/home/flow_cards.dart";
import "package:flow/widgets/home/home/no_transactions.dart";
import "package:flow/widgets/home/home/pending_transactions_header.dart";
import "package:flow/widgets/rates_missing_warning.dart";
import "package:flow/widgets/transactions_date_header.dart";
import "package:flow/widgets/utils/time_and_range.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class HomeTab extends StatefulWidget {
  final ScrollController? scrollController;

  const HomeTab({super.key, this.scrollController});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  late final AppLifecycleListener _listener;

  PendingTransactionsDuration _plannedTransactionsDuration =
      LocalPreferences.homeTabPlannedTransactionsDurationDefault;

  final TransactionFilter defaultFilter = TransactionFilter(
    range: last30Days(),
  );

  late TransactionFilter currentFilter = defaultFilter.copyWithOptional();

  TransactionFilter get currentFilterWithPlanned {
    final DateTime? plannedTransactionTo =
        _plannedTransactionsDuration.endsAt();

    if (plannedTransactionTo == null) return currentFilter;

    if (currentFilter.range != null &&
        currentFilter.range!.contains(Moment.now()) &&
        !currentFilter.range!.contains(plannedTransactionTo)) {
      return currentFilter.copyWithOptional(
        range: Optional(
          CustomTimeRange(
            currentFilter.range!.from,
            plannedTransactionTo,
          ),
        ),
      );
    }

    return currentFilter;
  }

  late final bool noTransactionsAtAll;

  @override
  void initState() {
    super.initState();
    _updatePlannedTransactionDays();
    LocalPreferences()
        .homeTabPlannedTransactionsDuration
        .addListener(_updatePlannedTransactionDays);

    _listener = AppLifecycleListener(onShow: () => setState(() {}));
  }

  @override
  void dispose() {
    _listener.dispose();
    LocalPreferences()
        .homeTabPlannedTransactionsDuration
        .removeListener(_updatePlannedTransactionDays);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final bool isFilterModified = currentFilter != defaultFilter;

    return StreamBuilder<List<Transaction>>(
      stream: currentFilterWithPlanned
          .queryBuilder()
          .watch(triggerImmediately: true)
          .map(
            (event) =>
                event.find().filter(currentFilterWithPlanned.postPredicates),
          ),
      builder: (context, snapshot) {
        final DateTime now = DateTime.now().startOfNextMinute();
        final ExchangeRates? rates =
            ExchangeRatesService().getPrimaryCurrencyRates();
        final List<Transaction>? transactions = snapshot.data;

        final Widget header = DefaultTransactionsFilterHead(
          defaultFilter: defaultFilter,
          current: currentFilter,
          onChanged: (value) {
            setState(() {
              currentFilter = value;
            });
          },
        );

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: GreetingsBar(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: header,
            ),
            switch ((transactions?.length ?? 0, snapshot.hasData)) {
              (0, true) => Expanded(
                  child: NoTransactions(isFilterModified: isFilterModified),
                ),
              (_, true) => Expanded(
                  child:
                      buildGroupedList(context, now, transactions ?? [], rates),
                ),
              (_, false) => const Expanded(
                  child: Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
            }
          ],
        );
      },
    );
  }

  Widget buildGroupedList(
    BuildContext context,
    DateTime now,
    List<Transaction> transactions,
    ExchangeRates? rates,
  ) {
    final Map<TimeRange, List<Transaction>> grouped = transactions
        .where((transaction) =>
            !transaction.transactionDate.isAfter(now) &&
            transaction.isPending != true)
        .groupByDate();

    final List<Transaction> pendingTransactions = transactions
        .where((transaction) =>
            transaction.transactionDate.isAfter(now) ||
            transaction.isPending == true)
        .toList();

    final int actionNeededCount = pendingTransactions
        .where((transaction) => transaction.confirmable())
        .length;

    final Map<TimeRange, List<Transaction>> pendingTransactionsGrouped =
        pendingTransactions.groupByRange(
      rangeFn: (transaction) =>
          CustomTimeRange(Moment.minValue, Moment.maxValue),
    );

    final bool shouldCombineTransferIfNeeded =
        currentFilter.accounts?.isNotEmpty != true;

    return GroupedTransactionList(
      header: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12.0),
          FlowCards(
            transactions: transactions,
            rates: rates,
          ),
          if (rates == null) ...[
            const SizedBox(height: 12.0),
            RatesMissingWarning(),
          ],
        ],
      ),
      controller: widget.scrollController,
      transactions: grouped,
      pendingTransactions: pendingTransactionsGrouped,
      shouldCombineTransferIfNeeded: shouldCombineTransferIfNeeded,
      pendingDivider: const WavyDivider(),
      listPadding: const EdgeInsets.only(
        top: 0,
        bottom: 80.0,
      ),
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
    );
  }

  void _updatePlannedTransactionDays() {
    _plannedTransactionsDuration =
        LocalPreferences().homeTabPlannedTransactionsDuration.get() ??
            LocalPreferences.homeTabPlannedTransactionsDurationDefault;
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}

import "dart:async";

import "package:flow/data/transactions_filter.dart";
import "package:flow/data/upcoming_transactions.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/default_transaction_filter_head.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flow/widgets/grouped_transaction_list.dart";
import "package:flow/widgets/home/greetings_bar.dart";
import "package:flow/widgets/home/home/no_transactions.dart";
import "package:flow/widgets/home/transactions_date_header.dart";
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
  UpcomingTransactionsDuration _plannedTransactionsDuration =
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
  late final Timer _updateTimer;

  DateTime now = DateTime.now().startOfNextMinute();

  @override
  void initState() {
    super.initState();
    noTransactionsAtAll = ObjectBox().box<Transaction>().count(limit: 1) == 0;
    _updatePlannedTransactionDays();
    LocalPreferences()
        .homeTabPlannedTransactionsDuration
        .addListener(_updatePlannedTransactionDays);

    _updateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!mounted) {
        return;
      }
      setState(() {
        now = DateTime.now().startOfNextMinute();
      });
    });
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    LocalPreferences()
        .homeTabPlannedTransactionsDuration
        .removeListener(_updatePlannedTransactionDays);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<List<Transaction>>(
      stream: currentFilterWithPlanned
          .queryBuilder()
          .watch(triggerImmediately: true)
          .map(
            (event) => event.find().search(currentFilter.searchData),
          ),
      builder: (context, snapshot) {
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
                  child: NoTransactions(
                    allTime: noTransactionsAtAll,
                  ),
                ),
              (_, true) => Expanded(
                  child: buildGroupedList(context, now, transactions ?? []),
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
  ) {
    final Map<TimeRange, List<Transaction>> grouped = transactions
        .where((transaction) => !transaction.transactionDate.isAfter(now))
        .groupByDate();
    final Map<TimeRange, List<Transaction>> groupedFuture = transactions
        .where((transaction) => transaction.transactionDate.isAfter(now))
        .groupByDate();

    return GroupedTransactionList(
      controller: widget.scrollController,
      transactions: grouped,
      futureTransactions: groupedFuture,
      shouldCombineTransferIfNeeded: currentFilter.accounts?.isNotEmpty != true,
      futureDivider: const WavyDivider(),
      listPadding: const EdgeInsets.only(
        top: 0,
        bottom: 80.0,
      ),
      headerBuilder: (
        TimeRange range,
        List<Transaction> transactions,
      ) =>
          TransactionListDateHeader(
        transactions: transactions,
        date: range.from,
        future: !range.from.isPast,
      ),
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

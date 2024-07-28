import 'package:flow/data/transactions_filter.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/widgets/default_transaction_filter_head.dart';
import 'package:flow/widgets/general/wavy_divider.dart';
import 'package:flow/widgets/grouped_transaction_list.dart';
import 'package:flow/widgets/home/greetings_bar.dart';
import 'package:flow/widgets/home/home/no_transactions.dart';
import 'package:flow/widgets/home/transactions_date_header.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';

class HomeTab extends StatefulWidget {
  final ScrollController? scrollController;

  const HomeTab({super.key, this.scrollController});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  final TransactionFilter defaultFilter = TransactionFilter(
    range: Moment.now()
        .subtract(const Duration(days: 29))
        .startOfDay()
        .rangeTo(Moment.maxValue),
  );

  late TransactionFilter currentFilter = defaultFilter.copyWithOptional();

  final DateTime startDate =
      Moment.now().subtract(const Duration(days: 29)).startOfDay();

  late final bool noTransactionsAtAll;

  @override
  void initState() {
    super.initState();
    noTransactionsAtAll = ObjectBox().box<Transaction>().count(limit: 1) == 0;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<List<Transaction>>(
      stream: currentFilter
          .queryBuilder()
          .watch(triggerImmediately: true)
          .map((event) => event.find()),
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
                  child: buildGroupedList(context, transactions ?? []),
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
    List<Transaction> transactions,
  ) {
    final Map<TimeRange, List<Transaction>> grouped =
        transactions.groupByDate();

    return GroupedTransactionList(
      controller: widget.scrollController,
      transactions: grouped,
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

  @override
  bool get wantKeepAlive => true;
}

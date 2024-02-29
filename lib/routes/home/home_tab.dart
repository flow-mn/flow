import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/flow_localizations.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/home/home/analytics_card.dart';
import 'package:flow/widgets/home/home/flow_separate_line_chart.dart';
import 'package:flow/widgets/home/home/flow_today_card.dart';
import 'package:flow/widgets/home/home/no_transactions.dart';
import 'package:flow/widgets/home/greetings_bar.dart';
import 'package:flow/widgets/grouped_transaction_list.dart';
import 'package:flow/widgets/home/home/total_balance_card.dart';
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
  final DateTime startDate =
      Moment.now().subtract(const Duration(days: 6)).startOfDay();

  // Last 7 days, and planned payments, newest to oldest
  QueryBuilder<Transaction> qb() => ObjectBox()
      .box<Transaction>()
      .query(
        Transaction_.transactionDate.greaterOrEqual(
          startDate.millisecondsSinceEpoch,
        ),
      )
      .order(Transaction_.transactionDate, flags: Order.descending);

  late final bool noTransactionsAtAll;

  @override
  void initState() {
    super.initState();
    noTransactionsAtAll = ObjectBox().box<Transaction>().count(limit: 1) == 0;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<Query<Transaction>>(
      stream: qb().watch(triggerImmediately: true),
      builder: (context, snapshot) {
        final transactions = snapshot.data
            ?.find()
            .where((element) => element.transactionDate <= Moment.now())
            .toList();

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: GreetingsBar(),
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
      BuildContext context, List<Transaction> transactions) {
    final Map<DateTime, List<Transaction>> grouped = transactions.groupByDate();
    final List<Widget> headers = grouped.keys
        .map((date) =>
            TransactionListDateHeader(transactions: grouped[date]!, date: date))
        .toList();

    return GroupedTransactionList(
      controller: widget.scrollController,
      header: SizedBox(
        height: 200.0,
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
                child: Column(
              children: [
                const Expanded(
                  child: TotalBalanceCard(),
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: FlowTodayCard(transactions: transactions),
                ),
              ],
            )),
            const SizedBox(width: 16.0),
            Expanded(
              child: AnalyticsCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0).copyWith(top: 12.0),
                  child: Column(
                    children: [
                      Text(
                        "tabs.home.last7days".t(context),
                        style: context.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8.0),
                      Expanded(
                        child: FlowSeparateLineChart(
                          transactions: transactions,
                          startDate: startDate,
                          endDate: DateTime.now(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      transactions: grouped.values.toList(),
      headers: headers,
      listPadding: const EdgeInsets.only(
        top: 0,
        bottom: 80.0,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

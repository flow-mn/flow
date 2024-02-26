import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/flow_localizations.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/home/home/analytics_card.dart';
import 'package:flow/widgets/home/home/flow_separate_line_chart.dart';
import 'package:flow/widgets/home/home/no_transactions.dart';
import 'package:flow/widgets/home/greetings_bar.dart';
import 'package:flow/widgets/grouped_transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

        final bool showAnalytics =
            !noTransactionsAtAll && transactions?.isNotEmpty == true;

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: GreetingsBar(),
            ),
            if (showAnalytics) ...[
              Container(
                height: 200.0,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                        child: Column(
                      children: [
                        Expanded(
                          child: AnalyticsCard(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "tabs.home.totalBalance".t(context),
                                    style: context.textTheme.bodyLarge,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Flexible(
                                    child: Text(
                                      ObjectBox()
                                          .getTotalBalance()
                                          .moneyCompact,
                                      style: context.textTheme.displaySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Expanded(
                          child: AnalyticsCard(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "tabs.home.flowToday".t(context),
                                    style: context.textTheme.bodyLarge,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Flexible(
                                    child: Text(
                                      (transactions ?? [])
                                          .where((element) =>
                                              element.transactionDate >=
                                                  DateTime.now().startOfDay() &&
                                              element.transactionDate <=
                                                  DateTime.now())
                                          .sum
                                          .moneyCompact,
                                      style: context.textTheme.displaySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: AnalyticsCard(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FlowSeparateLineChart(
                            transactions: transactions ?? [],
                            startDate: startDate,
                            endDate: DateTime.now(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
            ],
            switch ((transactions?.length ?? 0, snapshot.hasData)) {
              (0, true) => Expanded(
                  child: NoTransactions(
                    allTime: noTransactionsAtAll,
                  ),
                ),
              (_, true) => Expanded(
                  child: GroupedTransactionList(
                    controller: widget.scrollController,
                    transactions: transactions!,
                    listPadding: const EdgeInsets.only(
                      top: 16.0,
                      bottom: 80.0,
                    ),
                  ),
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

  @override
  bool get wantKeepAlive => true;
}

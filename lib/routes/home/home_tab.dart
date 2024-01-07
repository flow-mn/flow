import 'package:flow/entity/transaction.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/widgets/home/greetings_bar.dart';
import 'package:flow/widgets/home/week_transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Query for today's transaction, newest to oldest
  QueryBuilder<Transaction> qb() => ObjectBox()
      .box<Transaction>()
      .query(
        Transaction_.transactionDate.between(
          Moment.now()
              .subtract(const Duration(days: 6))
              .startOfDay()
              .millisecondsSinceEpoch,
          Moment.now().endOfDay().millisecondsSinceEpoch,
        ),
      )
      .order(Transaction_.transactionDate, flags: Order.descending);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Query<Transaction>>(
      stream: qb().watch(triggerImmediately: true),
      builder: (context, snapshot) {
        final transactions = snapshot.data?.find();

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: GreetingsBar(),
            ),
            switch ((transactions?.length ?? 0, snapshot.hasData)) {
              (0, true) => const Center(child: Text("Empty")),
              (_, true) => Expanded(
                  child: WeekTransactionList(
                    transactions: transactions!,
                    listPadding: const EdgeInsets.only(
                      top: 16.0,
                      bottom: 80.0,
                    ),
                  ),
                ),
              (_, false) => const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
            }
          ],
        );
      },
    );
  }
}

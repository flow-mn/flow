import 'package:flow/entity/transaction.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/widgets/general/spinner.dart';
import 'package:flow/widgets/grouped_transaction_list.dart';
import 'package:flow/widgets/home/transactions_date_header.dart';
import 'package:flutter/material.dart';

class TransactionsPage extends StatefulWidget {
  final QueryBuilder<Transaction> query;
  final String? title;

  const TransactionsPage({super.key, required this.query, this.title});

  factory TransactionsPage.account(
      {Key? key, required int accountId, String? title}) {
    final QueryBuilder<Transaction> queryBuilder = ObjectBox()
        .box<Transaction>()
        .query(Transaction_.account.equals(accountId))
        .order(Transaction_.transactionDate, flags: Order.descending);

    return TransactionsPage(
      query: queryBuilder,
      key: key,
      title: title,
    );
  }

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: widget.title == null ? null : Text(widget.title!),
        ),
        body: SafeArea(
          child: StreamBuilder(
            stream: widget.query.watch(triggerImmediately: true),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Spinner.center();
              }

              final grouped = snapshot.data!.find().groupByDate();
              final headers = grouped.keys
                  .map((date) => TransactionListDateHeader(
                      transactions: grouped[date]!, date: date))
                  .toList();

              return GroupedTransactionList(
                transactions: grouped.values.toList(),
                headers: headers,
              );
            },
          ),
        ));
  }
}

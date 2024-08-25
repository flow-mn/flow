import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/grouped_transaction_list.dart";
import "package:flow/widgets/home/transactions_date_header.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class TransactionsPage extends StatefulWidget {
  final QueryBuilder<Transaction> query;
  final String? title;

  final Widget? header;

  const TransactionsPage({
    super.key,
    required this.query,
    this.title,
    this.header,
  });

  factory TransactionsPage.account({
    Key? key,
    required int accountId,
    String? title,
    Widget? header,
  }) {
    final QueryBuilder<Transaction> queryBuilder = ObjectBox()
        .box<Transaction>()
        .query(Transaction_.account.equals(accountId))
        .order(Transaction_.transactionDate, flags: Order.descending);

    return TransactionsPage(
      query: queryBuilder,
      key: key,
      title: title,
      header: header,
    );
  }

  factory TransactionsPage.all({
    Key? key,
    String? title,
    Widget? header,
  }) {
    final QueryBuilder<Transaction> queryBuilder = ObjectBox()
        .box<Transaction>()
        .query()
        .order(Transaction_.transactionDate, flags: Order.descending);

    return TransactionsPage(
      query: queryBuilder,
      key: key,
      title: title,
      header: header,
    );
  }

  factory TransactionsPage.upcoming({
    Key? key,
    DateTime? anchor,
    String? title,
    Widget? header,
  }) {
    anchor ??= DateTime.now();

    final QueryBuilder<Transaction> queryBuilder = ObjectBox()
        .box<Transaction>()
        .query(Transaction_.transactionDate.greaterThanDate(anchor))
        .order(Transaction_.transactionDate, flags: Order.descending);

    return TransactionsPage(
      query: queryBuilder,
      key: key,
      title: title,
      header: header,
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
          child: StreamBuilder<Map<TimeRange, List<Transaction>>>(
            stream: widget.query
                .watch(triggerImmediately: true)
                .map((event) => event.find().groupByDate()),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Spinner.center();
              }

              final Map<TimeRange, List<Transaction>> grouped =
                  snapshot.requireData;

              return GroupedTransactionList(
                transactions: grouped,
                headerBuilder: (range, transactions) =>
                    TransactionListDateHeader(
                  transactions: transactions,
                  date: range.from,
                ),
                header: widget.header,
              );
            },
          ),
        ));
  }
}

import 'package:flow/entity/transaction.dart';
import 'package:flow/widgets/home/transactions_date_header.dart';
import 'package:flow/widgets/transaction_list_tile.dart';
import 'package:flutter/widgets.dart';

class WeekTransactionList extends StatelessWidget {
  final EdgeInsets listPadding;
  final EdgeInsets itemPadding;
  final List<Transaction> transactions;

  const WeekTransactionList({
    super.key,
    required this.transactions,
    this.listPadding = const EdgeInsets.symmetric(vertical: 16.0),
    this.itemPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 4.0,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final grouped = transactions.groupByDate();
    final flattened = [
      for (final date in grouped.keys) ...[
        date,
        ...grouped[date]!,
      ],
    ];

    return ListView.builder(
      padding: listPadding.copyWith(bottom: listPadding.bottom),
      itemBuilder: (context, index) => switch (flattened[index]) {
        (DateTime date) => Padding(
            padding: itemPadding.copyWith(top: index == 0 ? 8.0 : 24.0),
            child: TransactionListDateHeader(
              transactions: grouped[date]!,
              date: date,
            ),
          ),
        (Transaction transaction) => TransactionListTile(
            transaction: transaction,
            padding: itemPadding,
          ),
        (_) => Container(),
      },
      itemCount: flattened.length,
    );
  }
}

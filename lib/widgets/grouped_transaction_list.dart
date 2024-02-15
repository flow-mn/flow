import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/utils/utils.dart';
import 'package:flow/widgets/home/transactions_date_header.dart';
import 'package:flow/widgets/transaction_list_tile.dart';
import 'package:flutter/widgets.dart';

class GroupedTransactionList extends StatelessWidget {
  final EdgeInsets listPadding;
  final EdgeInsets itemPadding;
  final List<Transaction> transactions;

  final ScrollController? controller;

  const GroupedTransactionList({
    super.key,
    required this.transactions,
    this.listPadding = const EdgeInsets.symmetric(vertical: 16.0),
    this.itemPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 4.0,
    ),
    this.controller,
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
      controller: controller,
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
            dismissibleKey: ValueKey(transaction.id),
            deleteFn: () => deleteTransaction(context, transaction),
          ),
        (_) => Container(),
      },
      itemCount: flattened.length,
    );
  }

  Future<void> deleteTransaction(
    BuildContext context,
    Transaction transaction,
  ) async {
    final String txnTitle =
        transaction.title ?? "transaction.fallbackTitle".t(context);

    final confirmation = await context.showConfirmDialog(
      isDeletionConfirmation: true,
      title: "general.delete.confirmName".t(context, txnTitle),
    );

    if (confirmation == true) {
      transaction.delete();
    }
  }
}

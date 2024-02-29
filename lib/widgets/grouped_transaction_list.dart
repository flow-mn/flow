import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/prefs.dart';
import 'package:flow/utils/utils.dart';
import 'package:flow/widgets/transaction_list_tile.dart';
import 'package:flutter/widgets.dart';

class GroupedTransactionList extends StatelessWidget {
  final EdgeInsets listPadding;
  final EdgeInsets itemPadding;
  final List<List<Transaction>> transactions;
  final List<Widget> headers;

  final ScrollController? controller;

  final Widget? header;

  const GroupedTransactionList({
    super.key,
    required this.transactions,
    required this.headers,
    this.listPadding = const EdgeInsets.symmetric(vertical: 16.0),
    this.itemPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 4.0,
    ),
    this.controller,
    this.header,
  }) : assert(headers.length == transactions.length);

  @override
  Widget build(BuildContext context) {
    final bool combineTransfers =
        LocalPreferences().combineTransferTransactions.get();

    final List<Object> flattened = [
      if (header != null) header!,
      ...List.generate(transactions.length,
              (index) => [headers[index], ...transactions[index]])
          .expand((element) => element),
    ];

    return ListView.builder(
      controller: controller,
      padding: listPadding.copyWith(bottom: listPadding.bottom),
      itemBuilder: (context, index) => switch (flattened[index]) {
        (Widget header) => Padding(
            padding: itemPadding.copyWith(top: index == 0 ? 8.0 : 24.0),
            child: header,
          ),
        (Transaction transaction) => TransactionListTile(
            combineTransfers: combineTransfers,
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

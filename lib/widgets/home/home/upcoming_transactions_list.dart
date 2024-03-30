import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox/actions.dart';
import 'package:flow/prefs.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/utils.dart';
import 'package:flow/widgets/home/transactions_date_header.dart';
import 'package:flow/widgets/transaction_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UpcomingTransactionsList extends StatelessWidget {
  final List<Transaction> transactions;
  final bool shouldCombineTransferIfNeeded;

  const UpcomingTransactionsList({
    super.key,
    required this.transactions,
    required this.shouldCombineTransferIfNeeded,
  });

  @override
  Widget build(BuildContext context) {
    final bool combineTransfers = shouldCombineTransferIfNeeded &&
        LocalPreferences().combineTransferTransactions.get();

    final List<Transaction> visibleTransactions = transactions
        .where(
          (element) =>
              element.transactionDate.difference(DateTime.now()) <=
              const Duration(days: 7),
          // TODO make this duration configurable
        )
        .toList();

    if (visibleTransactions.isEmpty) {
      visibleTransactions.add(transactions.last);
    }

    final Map<DateTime, List<Transaction>> grouped =
        visibleTransactions.groupByDate();
    final List<Widget> headers = grouped.keys
        .map(
          (date) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TransactionListDateHeader.future(date: date),
          ),
        )
        .toList();

    final List<List<Widget>> transactionTiles = grouped.values
        .map((transactions) => transactions
            .map((transaction) => TransactionListTile(
                  transaction: transaction,
                  deleteFn: () => deleteTransaction(context, transaction),
                  combineTransfers: combineTransfers,
                ))
            .toList())
        .toList();

    final List<Widget> flattened = List.generate(
      grouped.length,
      (index) => [
        headers[index],
        ...transactionTiles[index],
      ],
    ).expand((element) => element).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "tabs.home.upcomingTransactions"
                    .t(context, transactions.length),
                style: context.textTheme.bodyLarge?.semi(context),
              ),
            ),
            const SizedBox(width: 16.0),
            TextButton(
              onPressed: () => context.push("/transactions/upcoming"),
              child: Text(
                "tabs.home.upcomingTransactions.seeAll".t(context),
              ),
            )
          ],
        ),
        const SizedBox(height: 16.0),
        ...flattened,
      ],
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

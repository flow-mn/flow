import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/recurring.dart";
import "package:flow/entity/transaction/extensions/default/transfer.dart";
import "package:flow/routes/transaction_page/select_recurring_update_mode_sheet.dart";
import "package:flow/services/recurring_transactions.dart";
import "package:flow/services/transactions.dart";
import "package:flow/utils/extensions/recurring_transaction.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";

final Logger _log = Logger("TransactionHelpers");

extension TransactionHelpers on Transaction {
  bool confirmable([DateTime? anchor]) {
    if (isPending != true) return false;

    return transactionDate.isPastAnchored(
      anchor ?? Moment.now().endOfNextMinute(),
    );
  }

  bool holdable([DateTime? anchor]) {
    if (isPending != true) return false;

    return transactionDate.isFutureAnchored(
      anchor ?? Moment.now().startOfMinute(),
    );
  }

  Future<void> _moveToTrashBinRecurring(BuildContext context) async {
    final Recurring? recurring = extensions.recurring;

    final RecurringTransaction? recurringTransaction =
        RecurringTransactionsService().findOneSync(recurring?.uuid);

    if (recurringTransaction == null) {
      _log.severe(
        "Couldn't delete recurring transaction properly due to missing recurring data",
      );
      return;
    }

    final RecurringUpdateMode? mode = await showModalBottomSheet(
      context: context,
      builder: (context) => SelectRecurringUpdateModeSheet(),
      isScrollControlled: true,
    );

    switch (mode) {
      case RecurringUpdateMode.current:
        try {
          TransactionsService().moveToBinSync(this);
        } catch (e, stackTrace) {
          _log.severe("Failed to move transaction to trash bin", e, stackTrace);
        }
        break;
      case RecurringUpdateMode.all:
        try {
          final List<Transaction> all = await TransactionsService().findMany(
            TransactionFilter(
              extraTag: recurringTransaction.extensionIdentifierTag,
            ),
          );
          for (var transaction in all) {
            TransactionsService().moveToBinSync(transaction);
          }
        } catch (e, stackTrace) {
          _log.severe(
            "Failed to move recurring transaction to trash bin",
            e,
            stackTrace,
          );
        }
        break;
      case RecurringUpdateMode.thisAndFuture:
        throw UnimplementedError();
      case null:
        return;
    }
  }

  Future<void> moveToTrashBin(BuildContext context) async {
    if (isRecurring) {
      return await _moveToTrashBinRecurring(context);
    }

    try {
      TransactionsService().moveToBinSync(this);
    } catch (e, stackTrace) {
      _log.severe("Failed to move transaction to trash bin", e, stackTrace);
    }
  }

  void recoverFromTrashBin() {
    if (isTransfer) {
      final Transfer? transfer = extensions.transfer;

      if (transfer == null) {
        _log.severe(
          "Couldn't delete transfer transaction properly due to missing transfer data",
        );
      } else {
        try {
          TransactionsService().recoverFromBinSync(
            transfer.relatedTransactionUuid,
          );
        } catch (e, stackTrace) {
          _log.severe(
            "Couldn't move transfer transaction to trash bin properly",
            e,
            stackTrace,
          );
        }
      }
    }

    try {
      TransactionsService().recoverFromBinSync(this);
    } catch (e, stackTrace) {
      _log.severe("Failed to move transaction to trash bin", e, stackTrace);
    }
  }
}

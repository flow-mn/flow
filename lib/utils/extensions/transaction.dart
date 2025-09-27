import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/recurring.dart";
import "package:flow/entity/transaction/extensions/default/transfer.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/transaction_page/select_recurring_update_mode_sheet.dart";
import "package:flow/services/recurring_transactions.dart";
import "package:flow/services/transactions.dart";
import "package:flow/utils/extensions/custom_popups.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";

final Logger _log = Logger("TransactionHelpers");

extension TransactionHelpers on Transaction {
  bool confirmable([DateTime? anchor]) {
    if (isDeleted == true) return false;
    if (isPending != true) return false;

    return transactionDate.isPastAnchored(
      anchor ?? Moment.now().endOfNextMinute(),
    );
  }

  bool holdable([DateTime? anchor]) {
    if (isDeleted == true) return false;
    if (isPending != true) return false;

    return transactionDate.isFutureAnchored(
          anchor ?? Moment.now().startOfMinute(),
        ) &&
        isPending == null;
  }

  Future<bool> _moveToTrashBinRecurring(BuildContext context) async {
    final Recurring? recurring = extensions.recurring;

    final RecurringTransaction? recurringTransaction =
        RecurringTransactionsService().findOneSync(recurring?.uuid);

    if (recurringTransaction == null) {
      _log.severe(
        "Couldn't delete recurring transaction properly due to missing recurring data",
      );
      return await moveToTrashBin(context, ignoreRecurring: true);
    }

    final RecurringUpdateMode? mode = await showModalBottomSheet(
      context: context,
      builder: (context) => SelectRecurringUpdateModeSheet(
        title: Text("transaction.recurring.delete".t(context)),
      ),
      isScrollControlled: true,
    );

    if (!context.mounted) return false;

    if (mode == RecurringUpdateMode.all) {
      final bool? areTheySure = await context.showConfirmationSheet(
        isDeletionConfirmation: true,
        child: Text(
          "transaction.recurring.delete.deleteAllDisclaimer".t(context),
        ),
      );

      if (areTheySure != true) {
        return false;
      }
    }

    if (mode == null) {
      return false;
    }

    if (mode == RecurringUpdateMode.current) {
      try {
        TransactionsService().moveToBinSync(this);
      } catch (e, stackTrace) {
        _log.severe("Failed to move transaction to trash bin", e, stackTrace);
      }
      return true;
    }

    final (
      _,
      List<Transaction> transactions,
    ) = await RecurringTransactionsService().findRelatedTransactionsByMode(
      this,
      mode,
    );

    int deletedCount = 0;

    for (final Transaction transaction in transactions) {
      try {
        if (mode == RecurringUpdateMode.all) {
          transaction.extensions.recurring = null;
        }
        TransactionsService().moveToBinSync(transaction);
        deletedCount++;
      } catch (e, stackTrace) {
        _log.severe(
          "Failed to move Transaction(${transaction.uuid}) to trash bin (Part of RecurringTransacion($uuid), initiated mass deletion by Tranasction($uuid))",
          e,
          stackTrace,
        );
      }
    }

    if (deletedCount == transactions.length) {
      _log.info(
        "Successfully moved ${transactions.length} transactions to trash bin (Part of RecurringTransacion($uuid), initiated mass deletion by Tranasction($uuid))",
      );
    } else {
      _log.warning(
        "Failed to move ${transactions.length - deletedCount} transactions to trash bin. Successfully moved $deletedCount though. (Part of RecurringTransacion($uuid), initiated mass deletion by Tranasction($uuid))",
      );
    }

    if (mode == RecurringUpdateMode.all) {
      try {
        await RecurringTransactionsService().delete(recurring?.uuid);
      } catch (e, stackTrace) {
        _log.severe("Failed to delete recurring transaction", e, stackTrace);
      }
    }

    if (mode == RecurringUpdateMode.thisAndFuture) {
      recurringTransaction.disabled = true;
      recurringTransaction.timeRange = CustomTimeRange(
        recurringTransaction.timeRange.from,
        recurringTransaction.recurrence.previousAbsoluteOccurrence(
              transactionDate,
            ) ??
            DateTime.now(),
      );
      await RecurringTransactionsService().update(recurringTransaction);
    }

    return true;
  }

  Future<bool> moveToTrashBin(
    BuildContext context, {
    bool ignoreRecurring = false,
  }) async {
    if (isRecurring && !ignoreRecurring) {
      return await _moveToTrashBinRecurring(context);
    }

    try {
      TransactionsService().moveToBinSync(this);
      return true;
    } catch (e, stackTrace) {
      _log.severe("Failed to move transaction to trash bin", e, stackTrace);
    }
    return false;
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

  /// Modifies the transaction in place.
  ///
  /// If the transaction already has a valid location, it is not modified.
  ///
  /// If anything goes wrong, the transaction is returned unmodified.
  Transaction migrateGeoExtensionToLocation() {
    try {
      if (this.location != null && this.location!.length == 2) return this;

      final List<double>? location = extensions.geo?.toLatLng();

      if (location == null) throw Exception("No location data");

      this.location = location;

      return this;
    } catch (e) {
      return this;
    }
  }
}

import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction/extensions/default/recurring.dart";
import "package:flow/entity/transaction/extensions/default/transfer.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
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
    if (isPending == true) return false;

    return transactionDate.isFutureAnchored(
      anchor ?? Moment.now().startOfMinute(),
    );
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

/// Bulk operations applied via a single `putMany`, so watchers emit once.
class BulkTransactions {
  static final Logger _log = Logger("BulkTransactions");

  /// Moves every transaction (and its transfer partner) to the trash bin.
  static int moveToTrashBin(Iterable<Transaction> transactions) {
    final List<Transaction> list = transactions
        .where((t) => t.isDeleted != true)
        .toList();
    if (list.isEmpty) return 0;
    final DateTime now = DateTime.now();
    final List<Transaction> toUpdate = [];
    final Set<String> seen = {};

    for (final Transaction t in list) {
      if (!seen.add(t.uuid)) continue;
      t.deletedDate = now;
      t.isDeleted = true;
      toUpdate.add(t);
      final Transaction? partner = TransactionsService()
          .findTransferRelatedTransactionSync(t);
      if (partner != null && seen.add(partner.uuid)) {
        partner.deletedDate = now;
        partner.isDeleted = true;
        toUpdate.add(partner);
      }
    }

    try {
      ObjectBox().box<Transaction>().putMany(toUpdate, mode: PutMode.update);
    } catch (e, stackTrace) {
      _log.severe("Bulk move-to-trash failed", e, stackTrace);
    }
    return list.length;
  }

  /// Recovers every transaction (and its transfer partner) from the trash bin.
  static int recoverFromTrashBin(Iterable<Transaction> transactions) {
    final List<Transaction> list = transactions
        .where((t) => t.isDeleted == true)
        .toList();
    if (list.isEmpty) return 0;
    final List<Transaction> toUpdate = [];
    final Set<String> seen = {};

    for (final Transaction t in list) {
      if (!seen.add(t.uuid)) continue;
      t.isDeleted = false;
      toUpdate.add(t);
      // Partner is also in the trash; default findTransferRelatedTransactionSync
      // skips deleted rows, so opt in.
      final Transaction? partner = TransactionsService()
          .findTransferRelatedTransactionSync(t, includeDeleted: true);
      if (partner != null && seen.add(partner.uuid)) {
        partner.isDeleted = false;
        toUpdate.add(partner);
      }
    }

    try {
      ObjectBox().box<Transaction>().putMany(toUpdate, mode: PutMode.update);
    } catch (e, stackTrace) {
      _log.severe("Bulk recover failed", e, stackTrace);
    }
    return list.length;
  }

  /// Confirms every transaction (and its transfer partner), leaving pending.
  static int confirm(
    Iterable<Transaction> transactions, {
    bool updateTransactionDate = true,
  }) {
    final List<Transaction> list = transactions.toList();
    if (list.isEmpty) return 0;
    final DateTime now = DateTime.now();
    final List<Transaction> toUpdate = [];
    final Set<String> seen = {};

    for (final Transaction t in list) {
      if (!seen.add(t.uuid)) continue;
      t.isPending = false;
      if (updateTransactionDate &&
          !t.extraTags.contains(Transaction.importedFromSiriTag)) {
        t.transactionDate = now;
      }
      toUpdate.add(t);
      final Transaction? partner = TransactionsService()
          .findTransferRelatedTransactionSync(t);
      if (partner != null && seen.add(partner.uuid)) {
        partner.isPending = false;
        if (updateTransactionDate &&
            !partner.extraTags.contains(Transaction.importedFromSiriTag)) {
          partner.transactionDate = now;
        }
        toUpdate.add(partner);
      }
    }

    try {
      ObjectBox().box<Transaction>().putMany(toUpdate, mode: PutMode.update);
    } catch (e, stackTrace) {
      _log.severe("Bulk confirm failed", e, stackTrace);
    }
    return list.length;
  }

  /// Sets [category] on every non-transfer transaction.
  static int setCategory(
    Iterable<Transaction> transactions,
    Category? category,
  ) {
    final List<Transaction> list = transactions
        .where((t) => !t.isTransfer)
        .toList();
    if (list.isEmpty) return 0;

    for (final t in list) {
      t.setCategory(category);
    }

    try {
      ObjectBox().box<Transaction>().putMany(list, mode: PutMode.update);
    } catch (e, stackTrace) {
      _log.severe("Bulk set category failed", e, stackTrace);
    }
    return list.length;
  }

  /// Sets [account] on every non-transfer transaction whose currency matches.
  static int setAccount(Iterable<Transaction> transactions, Account account) {
    final List<Transaction> list = transactions
        .where((t) => !t.isTransfer && t.currency == account.currency)
        .toList();
    if (list.isEmpty) return 0;

    for (final t in list) {
      t.setAccount(account);
    }

    try {
      ObjectBox().box<Transaction>().putMany(list, mode: PutMode.update);
    } catch (e, stackTrace) {
      _log.severe("Bulk set account failed", e, stackTrace);
    }
    return list.length;
  }
}

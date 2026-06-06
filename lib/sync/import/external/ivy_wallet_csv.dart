import "dart:async";

import "package:flow/data/flow_icon.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/backup_entry.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/transactions.dart";
import "package:flow/sync/exception.dart";
import "package:flow/sync/export.dart";
import "package:flow/sync/import/base.dart";
import "package:flow/sync/import/import_csv.dart";
import "package:flow/sync/model/external/ivy/ivy_wallet_csv.dart";
import "package:flow/sync/model/external/ivy/ivy_wallet_transaction.dart";
import "package:flow/utils/extensions/iterables.dart";
import "package:flow/utils/guess_preset_icon.dart";
import "package:flutter/foundation.dart" hide Category;
import "package:logging/logging.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:uuid/v4.dart";

final Logger _log = Logger("IvyWalletCsvImporter");

class IvyWalletCsvImporter extends Importer<IvyWalletCsv> {
  @override
  final IvyWalletCsv data;

  final Map<String, String> accountCurrencies = {};

  IvyWalletCsvImporter(this.data) {
    for (final String accountName in data.accountNames) {
      accountCurrencies[accountName] =
          data.transactions
              .firstWhereOrNull(
                (transaction) =>
                    transaction.type != TransactionType.transfer &&
                    transaction.account == accountName,
              )
              ?.currency ??
          "USD";
    }
  }

  @override
  Future<String?> execute({bool ignoreSafetyBackupFail = false}) async {
    String? safetyBackupFilePath;

    try {
      // Backup data before ruining everything
      await export(
        subfolder: "automated_backups",
        showShareDialog: false,
        type: BackupEntryType.preImport,
      ).then((value) => safetyBackupFilePath = value.filePath);
    } catch (e, stackTrace) {
      if (!ignoreSafetyBackupFail) {
        throw const ImportException(
          "Safety backup failed, aborting mission",
          l10nKey: "error.sync.safetyBackupFailed",
        );
      }
      _log.severe(
        "Safety backup failed but ignoreSafetyBackupFail=true; "
        "proceeding to erase main data with no backup on disk",
        e,
        stackTrace,
      );
    }

    try {
      TransactionsService().pauseListeners();

      await _eraseAndWrite();
    } catch (e, stackTrace) {
      _log.severe("Failed to execute import", e, stackTrace);
      progressNotifier.value = ImportCSVProgress.error;
      rethrow;
    } finally {
      TransactionsService().resumeListeners();
    }

    return safetyBackupFilePath;
  }

  Future<void> _eraseAndWrite() async {
    // 0. Erase current data
    progressNotifier.value = ImportCSVProgress.erasing;
    await ObjectBox().eraseMainData();

    // 1. Resurrect [Category]s
    final Map<String, String> categoryNameUuidMapping = {
      for (final String key in data.categoryNames.nonNulls)
        key: UuidV4().generate(),
    };

    progressNotifier.value = ImportCSVProgress.creatingCategories;
    final List<int> insertedCategoryIds = await ObjectBox()
        .box<Category>()
        .putManyAsync(
          categoryNameUuidMapping.keys
              .map(
                (name) => Category.preset(
                  name: name,
                  uuid: categoryNameUuidMapping[name]!,
                  iconCode: guessPresetIcon(
                    name,
                    fallback: IconFlowIcon(Symbols.category_rounded),
                  ).toString(),
                ),
              )
              .toList(),
        );

    final List<Category> insertedCategories =
        (await ObjectBox().box<Category>().getManyAsync(
          insertedCategoryIds,
        )).nonNulls.toList();
    final Map<String, Category> categoriesCache = insertedCategories
        .mapBy<String>((account) => account.uuid);

    // 2. Create [Account]s
    final Map<String, String> accountNameUuidMapping = {
      for (final String key in data.accountNames.nonNulls)
        key: UuidV4().generate(),
    };

    progressNotifier.value = ImportCSVProgress.creatingAccounts;
    final List<int> insertedAccountIds = await ObjectBox()
        .box<Account>()
        .putManyAsync(
          accountNameUuidMapping.keys
              .map(
                (name) => Account.preset(
                  name: name,
                  uuid: accountNameUuidMapping[name]!,
                  iconCode: guessPresetIcon(
                    name,
                    fallback: IconFlowIcon(Symbols.wallet),
                  ).toString(),
                  currency: accountCurrencies[name]!,
                ),
              )
              .toList(),
        );

    final List<Account> insertedAccounts =
        (await ObjectBox().box<Account>().getManyAsync(
          insertedAccountIds,
        )).nonNulls.toList();
    final Map<String, Account> accountsCache = insertedAccounts.mapBy<String>(
      (account) => account.uuid,
    );

    final String? newPrimaryCurrency = insertedAccounts.firstOrNull?.currency;

    if (newPrimaryCurrency != null) {
      unawaited(
        LocalPreferences().primaryCurrency
            .set(newPrimaryCurrency)
            .then((value) {
              _log.fine("Primary currency set to $newPrimaryCurrency");
            })
            .catchError((error, stackTrace) {
              _log.warning(
                "Failed to set primary currency, ignoring",
                error,
                stackTrace,
              );
            }),
      );
    }
    // 3. Create [Transaction]s
    progressNotifier.value = ImportCSVProgress.creatingTransactions;

    final List<Transaction> transformedTransactions = [];

    // Non-transfers
    for (final IvyWalletTransaction csvt in data.transactions.where(
      (t) => t.type != TransactionType.transfer,
    )) {
      final Account resolvedAccount =
          accountsCache[accountNameUuidMapping[csvt.account]!]!;

      final Transaction transaction =
          Transaction(
              uuid: UuidV4().generate(),
              amount: csvt.amount,
              title: csvt.title,
              description: csvt.note,
              transactionDate: csvt.transactionDate,
              currency: resolvedAccount.currency,
            )
            ..setAccount(resolvedAccount)
            ..setCategory(
              categoriesCache[categoryNameUuidMapping[csvt.category]],
            );

      transformedTransactions.add(transaction);
    }

    // Transfers

    for (final IvyWalletTransaction csvt in data.transactions.where(
      (t) => t.type == TransactionType.transfer,
    )) {
      final Account resolvedFromAccount =
          accountsCache[accountNameUuidMapping[csvt.account]!]!;
      final Account? resolvedToAccount =
          accountsCache[accountNameUuidMapping[csvt.transferToAccount]];

      if (resolvedToAccount == null) {
        // Apparently some transfers are not to a valid account name in the exported
        // This is a bug in Ivy Wallet CSV, hopefully we can ignore it
        _log.warning(
          "Transfer to account ${csvt.transferToAccount} not found, skipping",
        );
        continue;
      }

      if (csvt.currency != resolvedFromAccount.currency ||
          csvt.transferToCurrency != resolvedToAccount.currency) {
        throw const ImportException(
          "Transfer to account currency mismatch",
          l10nKey: "error.sync.import.csv.currencyMismatch",
        );
      }

      resolvedFromAccount.transferTo(
        targetAccount: resolvedToAccount,
        amount: csvt.amount,
        conversionRate: csvt.conversionRate,
        transactionDate: csvt.transactionDate,
        title: csvt.title,
        description: csvt.note,
      );
    }

    await ObjectBox().box<Transaction>().putManyAsync(
      transformedTransactions.toList(),
    );

    unawaited(
      TransitiveLocalPreferences().updateTransitiveProperties().catchError((
        error,
      ) {
        _log.warning("Failed to update transitive properties, ignoring", error);
      }),
    );

    progressNotifier.value = ImportCSVProgress.success;
  }

  @override
  final ValueNotifier<ImportCSVProgress> progressNotifier = ValueNotifier(
    ImportCSVProgress.waitingConfirmation,
  );
}

import "dart:async";

import "package:flow/data/flow_icon.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/backup_entry.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/services/transactions.dart";
import "package:flow/sync/exception.dart";
import "package:flow/sync/export.dart";
import "package:flow/sync/import/base.dart";
import "package:flow/sync/model/csv/parsed_data.dart";
import "package:flow/sync/model/csv/parsers.dart";
import "package:flow/utils/extensions/iterables.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:uuid/uuid.dart";
import "package:uuid/v4.dart";

final Logger _log = Logger("ImportCSV");

/// See format:
///
/// https://docs.google.com/spreadsheets/d/1wxdJ1T8PSvzayxvGs7bVyqQ9Zu0DPQ1YwiBLy1FluqE/edit?usp=sharing
class ImportCSV extends Importer {
  @override
  final CSVParsedData data;

  final Map<String, String> accountCurrencies = {};

  /// `null` for irrelevant columns
  final List<CSVCellParser?> orderedParserList = [];

  final ValueNotifier<String?> primaryCurrencyCandidate = ValueNotifier(null);

  bool get ready => accountCurrencies.values.length >= data.accountNames.length;

  ImportCSV(this.data);

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
    } catch (e) {
      if (!ignoreSafetyBackupFail) {
        throw const ImportException(
          "Safety backup failed, aborting mission",
          l10nKey: "error.sync.safetyBackupFailed",
        );
      }
    }

    try {
      TransactionsService().pauseListeners();

      await _eraseAndWrite();
    } catch (e) {
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
                  iconCode: IconFlowIcon(Symbols.category_rounded).toString(),
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
                  iconCode: IconFlowIcon(Symbols.wallet).toString(),
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

    // 3. Create [Transaction]s
    progressNotifier.value = ImportCSVProgress.creatingTransactions;
    final List<Transaction> transformedTransactions =
        data.transactions.map((csvt) {
          final Account resolvedAccount =
              accountsCache[accountNameUuidMapping[csvt.account]!]!;

          final Transaction transaction =
              Transaction(
                  uuid: UuidV4().generate(),
                  amount: csvt.amount,
                  title: csvt.title,
                  description: csvt.notes,
                  transactionDate: csvt.transactionDate,
                  currency: resolvedAccount.currency,
                )
                ..setAccount(resolvedAccount)
                ..setCategory(
                  categoriesCache[categoryNameUuidMapping[csvt.category]],
                );

          return transaction;
        }).toList();

    for (int i = 0; i < transformedTransactions.length; i++) {
      final Transaction? previousTransaction =
          i > 0 ? transformedTransactions[i - 1] : null;

      if (previousTransaction == null) continue;

      final Transaction transaction = transformedTransactions[i];

      if (transaction.transactionDate
              .difference(previousTransaction.transactionDate)
              .abs() >
          const Duration(seconds: 1, milliseconds: 200)) {
        continue;
      }
      if (transaction.amount != -previousTransaction.amount) {
        continue;
      }
      if (transaction.accountUuid == previousTransaction.accountUuid) {
        continue;
      }

      previousTransaction.account.target!.transferTo(
        amount: previousTransaction.amount,
        targetAccount: transaction.account.target!,
        transactionDate: previousTransaction.transactionDate,
        title: previousTransaction.title,
        description: previousTransaction.description,
      );

      transformedTransactions[i].uuid = Namespace.nil.value;
      transformedTransactions[i - 1].uuid = Namespace.nil.value;
      i++;
    }

    await ObjectBox().box<Transaction>().putManyAsync(
      transformedTransactions
          .where((t) => t.uuid != Namespace.nil.value)
          .toList(),
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

/// Used to report current status to user
enum ImportCSVProgress implements LocalizedEnum {
  waitingConfirmation,
  parsing,
  erasing,
  creatingAccounts,
  creatingCategories,
  creatingTransactions,
  success,
  error;

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "ImportCSVProgress";
}

import "dart:async";

import "package:flow/entity/account.dart";
import "package:flow/entity/backup_entry.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/services/transactions.dart";
import "package:flow/sync/exception.dart";
import "package:flow/sync/import/base.dart";
import "package:flow/sync/sync.dart";
import "package:flutter/widgets.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("ImportV1");

class ImportV1 extends Importer {
  @override
  final SyncModelV1 data;

  dynamic error;

  final Map<String, int> memoizeAccounts = {};
  final Map<String, int> memoizeCategories = {};

  @override
  final ValueNotifier<ImportV1Progress> progressNotifier = ValueNotifier(
    ImportV1Progress.waitingConfirmation,
  );

  ImportV1(this.data);

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
          versionCode: 1,
        );
      }
    }

    try {
      TransactionsService().pauseListeners();

      await _eraseAndWrite();
    } catch (e) {
      progressNotifier.value = ImportV1Progress.error;
      rethrow;
    } finally {
      TransactionsService().resumeListeners();
    }

    return safetyBackupFilePath;
  }

  /// Because we need to resolve dependencies thru `UUID`s, we'll populate
  /// [ObjectBox] in following order:
  /// 1. [Category] (no dependency)
  /// 2. [Account] (no dependency)
  /// 3. [Transaction] (Account, Category)
  Future<void> _eraseAndWrite() async {
    // 0. Erase current data
    progressNotifier.value = ImportV1Progress.erasing;
    await ObjectBox().eraseMainData();

    // 1. Resurrect [Category]s
    progressNotifier.value = ImportV1Progress.writingCategories;
    await ObjectBox().box<Category>().putManyAsync(data.categories);

    // 2. Resurrect [Account]s
    progressNotifier.value = ImportV1Progress.writingAccounts;
    await ObjectBox().box<Account>().putManyAsync(data.accounts);

    // 3. Resurrect [Transaction]s
    //
    // Resolve ToOne<T> [account] and [category] by `uuid`.
    progressNotifier.value = ImportV1Progress.resolvingTransactions;
    final transformedTransactions =
        data.transactions
            .map((transaction) {
              try {
                transaction = _resolveAccountForTransaction(transaction);
              } catch (e) {
                if (e is ImportException) {
                  _log.warning(e.toString());
                }
                return null;
              }

              try {
                transaction = _resolveCategoryForTransaction(transaction);
              } catch (e) {
                if (e is ImportException) {
                  _log.warning(e.toString());
                }
                // Still proceed without category
              }

              return transaction;
            })
            .nonNulls
            .toList();

    progressNotifier.value = ImportV1Progress.writingTransactions;
    await TransactionsService().upsertMany(transformedTransactions);

    unawaited(
      TransitiveLocalPreferences().updateTransitiveProperties().catchError((
        error,
      ) {
        _log.warning(
          "[Flow Sync Import v2] Failed to update transitive properties, ignoring",
          error,
        );
      }),
    );

    progressNotifier.value = ImportV1Progress.success;
  }

  Transaction _resolveAccountForTransaction(Transaction transaction) {
    if (transaction.accountUuid == null) {
      throw Exception("This transaction lacks `accountUuid`");
    }

    final String accountUuid = transaction.accountUuid!;

    // If the `id` is 0, we've already encountered it
    if (memoizeAccounts[accountUuid] != 0) {
      final Query<Account> accountQuery =
          ObjectBox()
              .box<Account>()
              .query(Account_.uuid.equals(accountUuid))
              .build();

      memoizeAccounts[accountUuid] ??= accountQuery.findFirst()?.id ?? 0;

      accountQuery.close();
    }

    if (memoizeAccounts[accountUuid] == 0) {
      throw ImportException(
        "Failed to link account to transaction because: Cannot find account ($accountUuid)",
        versionCode: 1,
      );
    }

    transaction.account.targetId = memoizeAccounts[accountUuid]!;

    return transaction;
  }

  Transaction _resolveCategoryForTransaction(Transaction transaction) {
    if (transaction.categoryUuid == null) {
      throw Exception("This transaction lacks `categoryUuid`");
    }

    final String categoryUuid = transaction.categoryUuid!;

    // If the `id` is 0, we've already encountered it
    if (memoizeCategories[categoryUuid] != 0) {
      final Query<Category> categoryQuery =
          ObjectBox()
              .box<Category>()
              .query(Category_.uuid.equals(categoryUuid))
              .build();

      memoizeCategories[categoryUuid] ??= categoryQuery.findFirst()?.id ?? 0;

      categoryQuery.close();
    }

    if (memoizeCategories[categoryUuid] == 0) {
      throw ImportException(
        "Failed to link category to transaction because: Cannot find category ($categoryUuid)",
        versionCode: 1,
      );
    }

    transaction.category.targetId = memoizeCategories[categoryUuid]!;

    return transaction;
  }
}

/// Used to report current status to user
enum ImportV1Progress implements LocalizedEnum {
  waitingConfirmation,
  erasing,
  writingCategories,
  writingAccounts,
  resolvingTransactions,
  writingTransactions,
  success,
  error;

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "ImportV1Progress";
}

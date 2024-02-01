import 'dart:convert';
import 'dart:developer';

import 'package:flow/entity/account.dart';
import 'package:flow/entity/category.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/sync/exception.dart';
import 'package:flow/sync/import/base.dart';
import 'package:flow/sync/model/model_v1.dart';
import 'package:flow/sync/sync.dart';
import 'package:flow/utils/utils.dart';
import 'package:flutter/widgets.dart';

/// We have to recover following models:
/// * Account
/// * Category
/// * Transactions
///
/// Because we need to resolve dependencies thru `UUID`s, we'll populate
/// [ObjectBox] in following order:
/// 1. [Category] (no dependency)
/// 2. [Account] (no dependency)
/// 3. [Transaction] (Account, Category)
Future<ImportV1> importBackupV1([ImportMode mode = ImportMode.merge]) async {
  final file = await pickFile();

  if (file == null) {
    throw StateError("No file was picked to proceed with the import");
  }

  final Map<String, dynamic> parsed =
      await file.readAsString().then((raw) => jsonDecode(raw));

  return ImportV1(SyncModelV1.fromJson(parsed), mode: mode);
}

/// Used to report current status to user
enum ImportV1Progress {
  preparing,
  erasing,
  loadingCategories,
  loadingAccounts,
  resolvingTransactions,
  loadingTransactions,
  success,
  error,
}

class ImportV1 extends Importer {
  @override
  final SyncModelV1 data;

  dynamic error;

  @override
  final ImportMode mode;

  final Map<String, int> memoizeAccounts = {};
  final Map<String, int> memoizeCategories = {};

  @override
  final ValueNotifier<ImportV1Progress> progressNotifier =
      ValueNotifier(ImportV1Progress.preparing);

  ImportV1(
    this.data, {
    this.mode = ImportMode.merge,
  });

  /// Before starting the import, it'll perform a safety backup, stored in
  /// `automated_backups` subfolder. If safety backups fails, will immediately
  /// halt, without making any changes to the state. You can alter this
  /// behaviour by setting [ignoreSafetyBackupFail] to true.
  ///
  /// Returns the path of the safety backup file.
  ///
  /// [ignoreSafetyBackupFail] - Forces to proceed in the import if safety
  /// backup fails
  Future<String?> execute({bool ignoreSafetyBackupFail = false}) async {
    String? safetyBackupFilePath;

    try {
      // Backup data before ruining everything
      await export(
        subfolder: "automated_backups",
        showShareDialog: false,
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
      switch (mode) {
        case ImportMode.eraseAndWrite:
          await _eraseAndWrite();
          break;
        case ImportMode.merge:
          await _merge();
          break;
      }
    } catch (e) {
      progressNotifier.value = ImportV1Progress.error;
      rethrow;
    }

    return safetyBackupFilePath;
  }

  Future<void> _eraseAndWrite() async {
    // 0. Erase current data
    progressNotifier.value = ImportV1Progress.erasing;
    await ObjectBox().wipeDatabase();

    // 1. Resurrect [Category]s
    progressNotifier.value = ImportV1Progress.loadingCategories;
    await ObjectBox().box<Category>().putManyAsync(data.categories);

    // 2. Resurrect [Account]s
    progressNotifier.value = ImportV1Progress.loadingAccounts;
    await ObjectBox().box<Account>().putManyAsync(data.accounts);

    // 3. Resurrect [Transaction]s
    //
    // Resolve ToOne<T> [account] and [category] by `uuid`.
    progressNotifier.value = ImportV1Progress.resolvingTransactions;
    final transformedTransactions = data.transactions
        .map((transaction) {
          try {
            transaction = _resolveAccountForTransaction(transaction);
          } catch (e) {
            if (e is ImportException) {
              log(e.toString());
            }
            return null;
          }

          try {
            transaction = _resolveCategoryForTransaction(transaction);
          } catch (e) {
            if (e is ImportException) {
              log(e.toString());
            }
            // Still proceed without category
          }

          return transaction;
        })
        .where((transaction) => transaction != null)
        .cast<Transaction>()
        .toList();

    progressNotifier.value = ImportV1Progress.loadingTransactions;
    await ObjectBox().box<Transaction>().putManyAsync(transformedTransactions);

    progressNotifier.value = ImportV1Progress.success;
  }

  Future<void> _merge() async {
    // Here, we might have an interactive selection screen for resolving
    // conflicts. For now, we'll ignore this.

    throw UnimplementedError();

    // // 1. Resurrect [Category]s
    // progressNotifier.value = ImportV1Progress.loadingCategories;
    // final currentCategories = await ObjectBox().box<Category>().getAllAsync();
    // await ObjectBox().box<Category>().putManyAsync(data.categories
    //     .where((incomingCategory) => !currentCategories.any(
    //         (currentCategory) => currentCategory.uuid == incomingCategory.uuid))
    //     .toList());

    // // 2. Resurrect [Account]s
    // progressNotifier.value = ImportV1Progress.loadingAccounts;
    // final currentAccounts = await ObjectBox().box<Account>().getAllAsync();
    // await ObjectBox().box<Account>().putManyAsync(data.accounts
    //     .where((incomingAccount) => !currentAccounts.any((currentAccount) =>
    //         currentAccount.uuid == incomingAccount.uuid ||
    //         currentAccount.name == incomingAccount.name))
    //     .toList());

    // // 3. Resurrect [Transaction]s
    // progressNotifier.value = ImportV1Progress.loadingTransactions;
    // final currentTransactions =
    //     await ObjectBox().box<Transaction>().getAllAsync();
  }

  Transaction _resolveAccountForTransaction(Transaction transaction) {
    if (transaction.accountUuid == null) {
      throw Exception("This transaction lacks `accountUuid`");
    }

    final String accountUuid = transaction.accountUuid!;

    // If the `id` is 0, we've already encountered it
    if (memoizeAccounts[accountUuid] != 0) {
      memoizeAccounts[accountUuid] ??= ObjectBox()
              .box<Account>()
              .query(Account_.uuid.equals(accountUuid))
              .build()
              .findFirst()
              ?.id ??
          0;
    }

    if (memoizeAccounts[accountUuid] == 0) {
      throw ImportException(
        "Failed to link account to transaction because: Cannot find account ($accountUuid)",
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
      memoizeCategories[categoryUuid] ??= ObjectBox()
              .box<Category>()
              .query(Category_.uuid.equals(categoryUuid))
              .build()
              .findFirst()
              ?.id ??
          0;
    }

    if (memoizeCategories[categoryUuid] == 0) {
      throw ImportException(
        "Failed to link category to transaction because: Cannot find category ($categoryUuid)",
      );
    }

    transaction.category.targetId = memoizeCategories[categoryUuid]!;

    return transaction;
  }
}

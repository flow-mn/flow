import "dart:async";
import "dart:developer";
import "dart:io";

import "package:path/path.dart" as path;

import "package:flow/data/currencies.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/backup_entry.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/profile.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs.dart";
import "package:flow/sync/exception.dart";
import "package:flow/sync/import/base.dart";
import "package:flow/sync/import/mode.dart";
import "package:flow/sync/model/model_v2.dart";
import "package:flow/sync/sync.dart";
import "package:flutter/widgets.dart";

/// Used to report current status to user
enum ImportV2Progress implements LocalizedEnum {
  waitingConfirmation,
  erasing,
  writingCategories,
  writingAccounts,
  resolvingTransactions,
  writingTransactions,
  writingProfile,
  settingPrimaryCurrency,
  copyingImages,
  success,
  error;

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "ImportV2Progress";
}

class ImportV2 extends Importer {
  @override
  final SyncModelV2 data;
  final String? assetsRoot;
  final String? cleanupFolder;

  dynamic error;

  @override
  final ImportMode mode;

  final Map<String, int> memoizeAccounts = {};
  final Map<String, int> memoizeCategories = {};

  @override
  final ValueNotifier<ImportV2Progress> progressNotifier =
      ValueNotifier(ImportV2Progress.waitingConfirmation);

  ImportV2(
    this.data, {
    this.cleanupFolder,
    this.assetsRoot,
    this.mode = ImportMode.merge,
  });

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
      switch (mode) {
        case ImportMode.eraseAndWrite:
          await _eraseAndWrite();
          break;
        case ImportMode.merge:
          await _merge();
          break;
      }
    } catch (e) {
      progressNotifier.value = ImportV2Progress.error;
      rethrow;
    } finally {
      if (cleanupFolder != null) {
        unawaited(_cleanup());
      }
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
    progressNotifier.value = ImportV2Progress.erasing;
    await ObjectBox().eraseMainData();

    // 1. Resurrect [Category]s
    progressNotifier.value = ImportV2Progress.writingCategories;
    await ObjectBox().box<Category>().putManyAsync(data.categories);

    // 2. Resurrect [Account]s
    progressNotifier.value = ImportV2Progress.writingAccounts;
    await ObjectBox().box<Account>().putManyAsync(data.accounts);

    // 3. Resurrect [Transaction]s
    //
    // Resolve ToOne<T> [account] and [category] by `uuid`.
    progressNotifier.value = ImportV2Progress.resolvingTransactions;
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
        .nonNulls
        .toList();

    progressNotifier.value = ImportV2Progress.writingTransactions;
    await ObjectBox().box<Transaction>().putManyAsync(transformedTransactions);

    if (data.profile != null) {
      try {
        await ObjectBox().box<Profile>().removeAllAsync();
      } catch (e) {
        log(
          "[Flow Sync Import v2] Failed to remove existing profile, ignoring",
          error: e,
        );
      }

      progressNotifier.value = ImportV2Progress.writingProfile;
      await ObjectBox().box<Profile>().putAsync(data.profile!);
    }

    if (data.primaryCurrency != null &&
        isCurrencyCodeValid(data.primaryCurrency!)) {
      progressNotifier.value = ImportV2Progress.settingPrimaryCurrency;
      try {
        await LocalPreferences().primaryCurrency.set(data.primaryCurrency!);
      } catch (e) {
        log("[Flow Sync Import v2] Failed to set primary currency, ignoring",
            error: e);
      }
    }

    if (assetsRoot != null) {
      progressNotifier.value = ImportV2Progress.copyingImages;
      try {
        final List<FileSystemEntity> assetsList =
            Directory(path.join(assetsRoot!, "images"))
                .listSync(followLinks: false);

        for (final asset in assetsList) {
          if (path.extension(asset.path).toLowerCase() == ".png") {
            final String assetName = path.basename(asset.path);
            final String targetPath =
                path.join(ObjectBox.imagesDirectory, assetName);

            try {
              await File(asset.path).copy(targetPath);
            } catch (e) {
              log("[Flow Sync Import v2] Failed to copy asset: $assetName",
                  error: e);
            }
          } else {
            log("[Flow Sync Import v2] Skipping non-PNG asset: ${path.basename(asset.path)}");
          }
        }
      } catch (e) {
        log("[Flow Sync Import v2] Failed to copy assets, ignoring", error: e);
      }
    }

    progressNotifier.value = ImportV2Progress.success;
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

  Future<void> _cleanup() async {
    if (cleanupFolder == null) {
      return;
    }

    try {
      await Directory(cleanupFolder!).delete(recursive: true);
    } catch (e) {
      log("[Flow Sync Import v2] Failed to delete cleanup folder", error: e);
    }
  }

  Transaction _resolveAccountForTransaction(Transaction transaction) {
    if (transaction.accountUuid == null) {
      throw Exception("This transaction lacks `accountUuid`");
    }

    final String accountUuid = transaction.accountUuid!;

    // If the `id` is 0, we've already encountered it
    if (memoizeAccounts[accountUuid] != 0) {
      final Query<Account> accountQuery = ObjectBox()
          .box<Account>()
          .query(Account_.uuid.equals(accountUuid))
          .build();

      memoizeAccounts[accountUuid] ??= accountQuery.findFirst()?.id ?? 0;

      accountQuery.close();
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
      final Query<Category> categoryQuery = ObjectBox()
          .box<Category>()
          .query(Category_.uuid.equals(categoryUuid))
          .build();

      memoizeCategories[categoryUuid] ??= categoryQuery.findFirst()?.id ?? 0;

      categoryQuery.close();
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

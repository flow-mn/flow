import "dart:async";
import "dart:io";

import "package:flow/entity/account.dart";
import "package:flow/entity/backup_entry.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/file_attachment.dart";
import "package:flow/entity/profile.dart";
import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/entity/transaction_filter_preset.dart";
import "package:flow/entity/transaction_tag.dart";
import "package:flow/entity/user_preferences.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/currency_registry.dart";
import "package:flow/services/transactions.dart";
import "package:flow/sync/exception.dart";
import "package:flow/sync/import/base.dart";
import "package:flow/sync/model/model_v2.dart";
import "package:flow/sync/sync.dart";
import "package:flow/utils/utils.dart";
import "package:flutter/widgets.dart";
import "package:logging/logging.dart";
import "package:path/path.dart" as path;

final Logger _log = Logger("ImportV2");

class ImportV2 extends Importer {
  @override
  final SyncModelV2 data;
  final String? assetsRoot;
  final String? cleanupFolder;

  dynamic error;

  final Map<String, int> memoizedAccounts = {};
  final Map<String, int> memoizedCategories = {};
  final Map<String, Optional<TransactionTag>> memoizedTransactionTags = {};

  @override
  final ValueNotifier<ImportV2Progress> progressNotifier = ValueNotifier(
    ImportV2Progress.waitingConfirmation,
  );

  ImportV2(this.data, {this.cleanupFolder, this.assetsRoot});

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
      progressNotifier.value = ImportV2Progress.error;
      rethrow;
    } finally {
      if (cleanupFolder != null) {
        unawaited(_cleanup());
      }

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
    progressNotifier.value = ImportV2Progress.erasing;
    await ObjectBox().eraseMainData();
    _log.fine("Erased main data");

    // 1. Resurrect [Category]s
    progressNotifier.value = ImportV2Progress.writingCategories;
    await ObjectBox().box<Category>().putManyAsync(data.categories);
    _log.fine("Imported ${data.categories.length} categories");

    // 2. Resurrect [Account]s
    progressNotifier.value = ImportV2Progress.writingAccounts;
    await ObjectBox().box<Account>().putManyAsync(data.accounts);
    _log.fine("Imported ${data.accounts.length} accounts");

    // 3. Resurrect [TransactionTag]s
    if (data.transactionTags?.isNotEmpty == true) {
      progressNotifier.value = ImportV2Progress.writingTransactionTags;
      await ObjectBox().box<TransactionTag>().putManyAsync(
        data.transactionTags!,
      );
      _log.fine("Imported ${data.transactionTags!.length} transaction tags");
    }

    // 4. Resurrect [FileAttachment]s
    if (data.attachments?.isNotEmpty == true) {
      progressNotifier.value = ImportV2Progress.writingFileAttachments;
      await ObjectBox().box<FileAttachment>().putManyAsync(data.attachments!);
      _log.fine("Imported ${data.attachments!.length} file attachments");
    }

    // 5. Resurrect [RecurringTransaction]s
    if (data.recurringTransactions?.isNotEmpty == true) {
      progressNotifier.value = ImportV2Progress.writingRecurringTransactions;
      await ObjectBox().box<RecurringTransaction>().putManyAsync(
        data.recurringTransactions!,
      );
    }
    _log.fine(
      "Imported ${data.recurringTransactions?.length ?? 0} recurring transactions",
    );

    // 6. Resurrect [Transaction]s
    //
    // Resolve ToOne<T> [account] and [category] by `uuid`.
    progressNotifier.value = ImportV2Progress.resolvingTransactions;
    final transformedTransactions = data.transactions
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

          try {
            transaction = _resolveTransactionTagsForTransaction(transaction);
          } catch (e) {
            if (e is ImportException) {
              _log.warning(e.toString());
            }
            // Still proceed without category
          }

          try {
            transaction = _resolveFileAttachmentsForTransaction(transaction);
          } catch (e) {
            if (e is ImportException) {
              _log.warning(e.toString());
            }
            // Still proceed without attachments
          }

          return transaction.migrateGeoExtensionToLocation();
        })
        .nonNulls
        .toList();
    _log.fine("Resolved ${transformedTransactions.length} transactions");

    progressNotifier.value = ImportV2Progress.writingTransactions;
    await TransactionsService().upsertMany(transformedTransactions);

    if (data.transactionFilterPresets?.isNotEmpty == true) {
      progressNotifier.value = ImportV2Progress.writingTranscationFilterPresets;
      await ObjectBox().box<TransactionFilterPreset>().putManyAsync(
        data.transactionFilterPresets!,
      );
    }

    if (data.profile != null) {
      try {
        await ObjectBox().box<Profile>().removeAllAsync();
      } catch (e) {
        _log.warning("Failed to remove existing profile, ignoring", e);
      }

      progressNotifier.value = ImportV2Progress.writingProfile;
      await ObjectBox().box<Profile>().putAsync(data.profile!);
      _log.fine("Imported profile");
    }

    if (data.userPreferences != null) {
      try {
        await ObjectBox().box<UserPreferences>().removeAllAsync();
      } catch (e) {
        _log.warning("Failed to remove existing user preferences, ignoring", e);
      }

      progressNotifier.value = ImportV2Progress.writingUserPreferences;
      await ObjectBox().box<UserPreferences>().putAsync(data.userPreferences!);
      _log.fine("Imported user preferences");
    }

    if (data.primaryCurrency != null &&
        CurrencyRegistryService().isCurrencyCodeValid(data.primaryCurrency!)) {
      progressNotifier.value = ImportV2Progress.settingPrimaryCurrency;
      try {
        await LocalPreferences().primaryCurrency.set(data.primaryCurrency!);
        _log.fine("Imported primary currency");
      } catch (e) {
        _log.warning("Failed to set primary currency, ignoring", e);
      }
    }

    unawaited(
      TransitiveLocalPreferences().updateTransitiveProperties().catchError((
        error,
      ) {
        _log.warning("Failed to update transitive properties, ignoring", error);
      }),
    );

    if (assetsRoot != null) {
      progressNotifier.value = ImportV2Progress.copyingImages;
      try {
        final List<FileSystemEntity> assetsList = Directory(
          path.join(assetsRoot!, "images"),
        ).listSync(followLinks: false);

        await Directory(ObjectBox.imagesDirectory).create(recursive: true);

        for (final asset in assetsList) {
          if (path.extension(asset.path).toLowerCase() == ".png") {
            final String assetName = path.basename(asset.path);
            final String targetPath = path.join(
              ObjectBox.imagesDirectory,
              assetName,
            );

            try {
              await File(asset.path).copy(targetPath);
            } catch (e) {
              _log.warning("Failed to copy asset: $assetName", e);
            }
          } else {
            _log.warning(
              "Skipping non-PNG asset: ${path.basename(asset.path)}",
            );
          }
        }
      } catch (e) {
        _log.warning("Failed to copy assets, ignoring", e);
      }
    }

    progressNotifier.value = ImportV2Progress.success;
  }

  Future<void> _cleanup() async {
    if (cleanupFolder == null) {
      return;
    }

    try {
      await Directory(cleanupFolder!).delete(recursive: true);
    } catch (e) {
      _log.warning("Failed to delete cleanup folder", e);
    }
  }

  Transaction _resolveAccountForTransaction(Transaction transaction) {
    if (transaction.accountUuid == null) {
      throw Exception("This transaction lacks `accountUuid`");
    }

    final String accountUuid = transaction.accountUuid!;

    // If the `id` is 0, we've already encountered it
    if (memoizedAccounts[accountUuid] != 0) {
      final Query<Account> accountQuery = ObjectBox()
          .box<Account>()
          .query(Account_.uuid.equals(accountUuid))
          .build();

      memoizedAccounts[accountUuid] ??= accountQuery.findFirst()?.id ?? 0;

      accountQuery.close();
    }

    if (memoizedAccounts[accountUuid] == 0) {
      throw ImportException(
        "Failed to link account to transaction because: Cannot find account ($accountUuid)",
      );
    }

    transaction.account.targetId = memoizedAccounts[accountUuid]!;

    return transaction;
  }

  Transaction _resolveCategoryForTransaction(Transaction transaction) {
    if (transaction.categoryUuid == null) {
      throw Exception("This transaction lacks `categoryUuid`");
    }

    final String categoryUuid = transaction.categoryUuid!;

    // If the `id` is 0, we've already encountered it
    if (memoizedCategories[categoryUuid] != 0) {
      final Query<Category> categoryQuery = ObjectBox()
          .box<Category>()
          .query(Category_.uuid.equals(categoryUuid))
          .build();

      memoizedCategories[categoryUuid] ??= categoryQuery.findFirst()?.id ?? 0;

      categoryQuery.close();
    }

    if (memoizedCategories[categoryUuid] == 0) {
      throw ImportException(
        "Failed to link category to transaction because: Cannot find category ($categoryUuid)",
      );
    }

    transaction.category.targetId = memoizedCategories[categoryUuid]!;

    return transaction;
  }

  Transaction _resolveTransactionTagsForTransaction(Transaction transaction) {
    if (transaction.tagsUuids?.isEmpty == true) {
      throw Exception("This transaction lacks `tagsUuids`");
    }

    final List<String> tagsUuids = transaction.tagsUuids!;

    for (final String tagUuid in tagsUuids) {
      if (memoizedTransactionTags[tagUuid] is! Optional) {
        final Query<TransactionTag> tagQuery = ObjectBox()
            .box<TransactionTag>()
            .query(TransactionTag_.uuid.equals(tagUuid))
            .build();

        memoizedTransactionTags[tagUuid] ??= Optional<TransactionTag>(
          tagQuery.findFirst(),
        );

        tagQuery.close();
      }

      if (memoizedTransactionTags[tagUuid] is Optional &&
          memoizedTransactionTags[tagUuid]!.value == null) {
        throw ImportException(
          "Failed to link tag to transaction because: Cannot find tag ($tagUuid)",
        );
      }
    }

    transaction.setTags(
      tagsUuids.map((e) => memoizedTransactionTags[e]!.value!).toList(),
    );

    return transaction;
  }

  Transaction _resolveFileAttachmentsForTransaction(Transaction transaction) {
    if (transaction.attachmentsUuids?.isEmpty == true) {
      throw Exception("This transaction lacks `attachmentsUuids`");
    }

    final List<String> attachmentsUuids = transaction.attachmentsUuids!;

    final query = ObjectBox()
        .box<FileAttachment>()
        .query(FileAttachment_.uuid.oneOf(attachmentsUuids))
        .build();

    final List<FileAttachment> foundFiles = query.find();

    if (foundFiles.length != attachmentsUuids.length) {
      final foundUuids = foundFiles.map((e) => e.uuid).toSet();
      final missingUuids = attachmentsUuids.where(
        (e) => !foundUuids.contains(e),
      );

      _log.warning(
        "Failed to link attachment to transaction because: Cannot find attachment(s) (${missingUuids.join(", ")})",
      );
    }

    transaction.setAttachments(foundFiles);

    return transaction;
  }
}

/// Used to report current status to user
enum ImportV2Progress with LocalizedEnum {
  waitingConfirmation,
  erasing,
  writingCategories,
  writingAccounts,
  writingTransactionTags,
  writingFileAttachments,
  resolvingTransactions,
  writingRecurringTransactions,
  writingTransactions,
  writingTranscationFilterPresets,
  writingProfile,
  writingUserPreferences,
  settingPrimaryCurrency,
  copyingImages,
  success,
  error;

  @override
  String get localizationEnumValue => name;
  @override
  String get localizationEnumName => "ImportV2Progress";
}

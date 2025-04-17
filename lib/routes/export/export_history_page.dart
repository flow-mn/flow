import "dart:async";
import "dart:io";

import "package:flow/entity/backup_entry.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/icloud_sync.dart";
import "package:flow/services/sync.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/utils/extensions/backup_entry.dart";
import "package:flow/widgets/export/export_history/backup_entry_card.dart";
import "package:flow/widgets/export/export_history/no_backups.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:icloud_storage/models/icloud_file.dart";
import "package:path/path.dart" as path;

class ExportHistoryPage extends StatefulWidget {
  const ExportHistoryPage({super.key});

  @override
  State<ExportHistoryPage> createState() => _ExportHistoryPageState();
}

class _ExportHistoryPageState extends State<ExportHistoryPage> {
  bool uploadBusy = false;
  late final bool uploadEnabled;

  (int uploadingId, double uploadProgress)? uploading;

  // Query for today's transaction, newest to oldest
  QueryBuilder<BackupEntry> qb() => ObjectBox()
      .box<BackupEntry>()
      .query()
      .order(BackupEntry_.createdDate, flags: Order.descending);

  @override
  void initState() {
    super.initState();
    uploadEnabled = UserPreferencesService().enableICloudSync;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("sync.export.history".t(context))),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: ICloudSyncService().filesCache,
          builder: (context, iCloudFiles, _) {
            return StreamBuilder<List<BackupEntry>>(
              stream: qb()
                  .watch(triggerImmediately: true)
                  .map((event) => event.find()),
              builder: (context, snapshot) {
                final List<BackupEntry>? backupEntries = snapshot.data;

                const Widget separator = SizedBox(height: 16.0);

                if (backupEntries != null) {
                  backupEntries.addAll(
                    iCloudFiles
                        .where(
                          (iCloudFile) => backupEntries.any(
                            (file) =>
                                file.iCloudChangeDate ==
                                iCloudFile.contentChangeDate,
                          ),
                        )
                        .map(
                          (iCloudFile) => BackupEntry(
                            filePath: iCloudFile.relativePath,
                            type: BackupEntryType.other.value,
                            fileExt:
                                path
                                    .extension(iCloudFile.relativePath)
                                    .replaceAll(r"^\.", "")
                                    .toLowerCase(),
                          ),
                        ),
                  );
                }

                return switch ((backupEntries?.length ?? 0, snapshot.hasData)) {
                  (0, true) => const NoBackups(),
                  (_, true) => SlidableAutoCloseBehavior(
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        final BackupEntry entry = backupEntries[index];

                        final bool canUpload =
                            uploadEnabled &&
                            !uploadBusy &&
                            entry.canUploadToCloud;

                        return BackupEntryCard(
                          entry: entry,
                          dismissibleKey: ValueKey(entry.id),
                          onUpload: canUpload ? (() => upload(entry)) : null,
                          uploadProgress:
                              uploading?.$1 == entry.id ? uploading?.$2 : null,
                          existsOnCloud: entry.correspondingFile != null,
                        );
                      },
                      separatorBuilder: (context, index) => separator,
                      itemCount: backupEntries!.length,
                    ),
                  ),
                  (_, false) => const Spinner.center(),
                };
              },
            );
          },
        ),
      ),
    );
  }

  void upload(BackupEntry entry) async {
    setState(() {
      uploadBusy = true;
    });

    try {
      final File file = File(entry.filePath);

      final bool exists = await file.exists().catchError((_) => false);

      if (!exists) return;

      await SyncService().saveBackupToICloud(
        entry: entry,
        parent: path.join(SyncService.cloudBackupsFolder, entry.type),
        onProgress: (p) => onUploadProgress(entry, p),
      );

      await ICloudSyncService().gather().catchError((_) => <ICloudFile>[]);
    } finally {
      uploadBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void onUploadProgress(BackupEntry entry, Stream<double> progress) {
    late final StreamSubscription<double> subscription;

    void cancel() {
      uploading = null;
      subscription.cancel();

      if (mounted) {
        setState(() {});
      }
    }

    subscription = progress.listen(
      (double progress) {
        uploading = (entry.id, progress);

        if (mounted) {
          setState(() {});
        }

        if (progress >= 1.0) {
          cancel();
        }
      },
      onError: (_) => cancel(),
      onDone: () => cancel(),
      cancelOnError: true,
    );

    setState(() {
      uploading = (entry.id, 0.0);
    });
  }
}

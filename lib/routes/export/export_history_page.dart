import "dart:io";

import "package:flow/entity/backup_entry.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/services/sync.dart";
import "package:flow/services/sync/icloud_syncer.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/utils/extensions/backup_entry.dart";
import "package:flow/widgets/export/export_history/backup_entry_card.dart";
import "package:flow/widgets/export/export_history/no_backups.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/icloud_failed_error_box.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:path/path.dart" as path;

class ExportHistoryPage extends StatefulWidget {
  const ExportHistoryPage({super.key});

  @override
  State<ExportHistoryPage> createState() => _ExportHistoryPageState();
}

class _ExportHistoryPageState extends State<ExportHistoryPage> {
  bool uploadBusy = false;
  late final bool uploadEnabled;

  bool iCloudSyncWorkingFine = true;

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

    TransitiveLocalPreferences().iCloudSyncWorkingFine.addListener(
      _updateICloudSyncWorkingFine,
    );
    _updateICloudSyncWorkingFine();
  }

  @override
  void dispose() {
    TransitiveLocalPreferences().iCloudSyncWorkingFine.removeListener(
      _updateICloudSyncWorkingFine,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("sync.export.history".t(context))),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: ICloudSyncer().filesCache,
          builder: (context, iCloudFiles, _) {
            return StreamBuilder<List<BackupEntry>>(
              stream: qb()
                  .watch(triggerImmediately: true)
                  .map((event) => event.find()),
              builder: (context, snapshot) {
                final List<BackupEntry>? backupEntries = snapshot.data;

                const Widget separator = SizedBox(height: 16.0);

                backupEntries?.addAll(
                  iCloudFiles
                      .where(
                        (iCloudFile) => !backupEntries.any(
                          (file) =>
                              ICloudSyncer().resolvePath(file.filePath) ==
                              iCloudFile.relativePath,
                        ),
                      )
                      .map(
                        (iCloudFile) => BackupEntry(
                          filePath: iCloudFile.relativePath,
                          type: BackupEntryType.other.value,
                          fileExt: path
                              .extension(iCloudFile.relativePath)
                              .replaceAll(r"^\.", "")
                              .toLowerCase(),
                        ),
                      ),
                );

                return switch ((backupEntries?.length ?? 0, snapshot.hasData)) {
                  (0, true) => const NoBackups(),
                  (_, true) => Column(
                    children: [
                      if (ICloudSyncer.supported && !iCloudSyncWorkingFine)
                        ICloudFailedErrorBox(),
                      Expanded(
                        child: SlidableAutoCloseBehavior(
                          child: ListView.separated(
                            itemBuilder: (context, index) {
                              final BackupEntry entry = backupEntries[index];

                              final bool canUpload =
                                  uploadEnabled &&
                                  // !uploadBusy &&
                                  entry.canUploadToCloud;

                              return BackupEntryCard(
                                entry: entry,
                                dismissibleKey: ValueKey(entry.id),
                                onUpload: canUpload
                                    ? (() => upload(entry))
                                    : null,
                                uploadProgress: uploading?.$1 == entry.id
                                    ? uploading?.$2
                                    : null,
                              );
                            },
                            separatorBuilder: (context, index) => separator,
                            itemCount: backupEntries!.length,
                          ),
                        ),
                      ),
                    ],
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

      await SyncService().putToAll(
        entry,
        onProgress: (p) => onUploadProgress(entry, p),
      );
    } finally {
      uploadBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void onUploadProgress(BackupEntry entry, double progress) {
    uploading = (entry.id, progress);
    if (mounted) {
      setState(() {});
    }
  }

  void _updateICloudSyncWorkingFine() {
    if (!ICloudSyncer.supported) return;
    if (!ICloudSyncer().syncing) return;

    iCloudSyncWorkingFine = TransitiveLocalPreferences().iCloudSyncWorkingFine
        .get();
    if (mounted) {
      setState(() {});
    }
  }
}

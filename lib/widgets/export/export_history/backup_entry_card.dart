import "package:flow/entity/backup_entry.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/services/icloud_sync.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/backup_entry.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class BackupEntryCard extends StatelessWidget {
  final BackupEntry entry;

  final BorderRadius borderRadius;
  final EdgeInsets padding;

  final Key? dismissibleKey;

  final Function()? onUpload;

  final double? uploadProgress;

  const BackupEntryCard({
    super.key,
    required this.entry,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    this.dismissibleKey,
    this.onUpload,
    this.uploadProgress,
  });

  @override
  Widget build(BuildContext context) {
    final int? fileSize = getFileSize();

    final Widget listTile = InkWell(
      borderRadius: borderRadius,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: padding,
            child: Row(
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: FlowIcon(entry.icon, size: 48.0, plated: true),
                    ),
                    if (existsOnCloud)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colorScheme.surface.withAlpha(0xC0),
                          ),
                          child: Icon(
                            Symbols.cloud_done_rounded,
                            color: context.flowColors.income,
                            size: 24.0,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.backupEntryType.localizedNameContext(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelLarge,
                      ),
                      Text(
                        [
                          entry.createdDate.toMoment().calendar(),
                          entry.fileExt,
                          fileSize?.humanReadableBinarySize,
                        ].nonNulls.join(" • "),
                        style: context.textTheme.bodyMedium?.semi(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Builder(
                  builder: (context) {
                    return IconButton(
                      onPressed: () {
                        if (fileSize == null) {
                          context.showErrorToast(
                            error: "error.sync.fileNotFound".t(context),
                          );
                          return;
                        }

                        context.showFileShareSheet(
                          subject: "sync.export.save.shareTitle".t(context, {
                            "type": entry.fileExt,
                            "date": entry.createdDate.toMoment().lll,
                          }),
                          filePath: entry.filePath,
                        );
                      },
                      icon:
                          fileSize != null
                              ? const Icon(Symbols.save_alt_rounded)
                              : Icon(
                                Symbols.error_circle_rounded,
                                color: context.flowColors.expense,
                              ),
                    );
                  },
                ),
                const SizedBox(width: 8.0),
              ],
            ),
          ),
          if (uploadProgress != null)
            LinearProgressIndicator(
              value: uploadProgress,
              minHeight: 4.0,
              color: context.flowColors.income,
              backgroundColor: context.colorScheme.surface.withAlpha(0xC0),
            ),
        ],
      ),
    );

    return Slidable(
      key: dismissibleKey,
      groupTag: "backup_entry_card",
      startActionPane:
          (fileSize != null &&
                  fileSize > 0 &&
                  onUpload != null &&
                  entry.correspondingFile == null)
              ? ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) => onUpload!(),
                    icon: Symbols.cloud_upload_rounded,
                    backgroundColor: context.flowColors.income,
                  ),
                ],
              )
              : null,
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => delete(context),
            icon: Symbols.delete_forever_rounded,
            backgroundColor: context.flowColors.expense,
          ),
        ],
      ),
      child: listTile,
    );
  }

  Future<void> delete(BuildContext context) async {
    final String title = entry.backupEntryType.localizedNameContext(context);

    final confirmation = await context.showConfirmationSheet(
      isDeletionConfirmation: true,
      title: "general.delete.confirmName".t(context, title),
    );

    if (confirmation == true) {
      final bool deleted = await entry.delete();

      if (!context.mounted) return;

      if (!deleted) {
        context.showErrorToast(error: "error.sync.fileDeleteFailed".t(context));
      }
    }
  }

  int? getFileSize() {
    final int? localFileSize = entry.getFileSizeSync();

    if (localFileSize != null) {
      return localFileSize;
    }

    if (!ICloudSyncService.supported) {
      return null;
    }

    try {
      return ICloudSyncService().filesCache.value
          .firstWhereOrNull(
            (file) => file.relativePath == entry.iCloudRelativePath,
          )
          ?.sizeInBytes;
    } catch (e) {
      return null;
    }
  }

  bool get existsOnCloud {
    if (entry.iCloudRelativePath == null) {
      return false;
    }

    if (!ICloudSyncService.supported) {
      return false;
    }

    try {
      return ICloudSyncService().filesCache.value.any(
        (file) =>
            file.relativePath == entry.iCloudRelativePath &&
            file.contentChangeDate.startOfSecond().toUtc() ==
                entry.iCloudChangeDate?.startOfSecond().toUtc(),
      );
    } catch (e) {
      return false;
    }
  }
}

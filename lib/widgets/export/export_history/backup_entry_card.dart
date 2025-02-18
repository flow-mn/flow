import "dart:io";

import "package:flow/entity/backup_entry.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:share_plus/share_plus.dart";

class BackupEntryCard extends StatelessWidget {
  final BackupEntry entry;

  final BorderRadius borderRadius;
  final EdgeInsets padding;

  final Key? dismissibleKey;

  const BackupEntryCard({
    super.key,
    required this.entry,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    this.dismissibleKey,
  });

  @override
  Widget build(BuildContext context) {
    final int? fileSize = entry.getFileSizeSync();

    final Widget listTile = InkWell(
      borderRadius: borderRadius,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            FlowIcon(entry.icon, size: 48.0, plated: true),
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
                      fileSize?.binarySize,
                    ].nonNulls.join(" • "),
                    style: context.textTheme.bodyMedium?.semi(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            IconButton(
              onPressed: () => showShareSheet(context, fileSize != null),
              icon:
                  fileSize != null
                      ? const Icon(Symbols.save_alt_rounded)
                      : Icon(
                        Symbols.error_circle_rounded,
                        color: context.flowColors.expense,
                      ),
            ),
            const SizedBox(width: 8.0),
          ],
        ),
      ),
    );

    return Slidable(
      key: dismissibleKey,
      groupTag: "backup_entry_card",
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

  Future<void> showShareSheet(BuildContext context, bool exists) async {
    if (!exists) {
      context.showErrorToast(error: "sync.export.fileDeleted".t(context));
      return;
    }

    if (Platform.isLinux) {
      // openUrl(Uri.parse("file://$filePath"));
      Process.runSync("xdg-open", [File(entry.filePath).parent.path]);
      return;
    }

    final box = context.findRenderObject() as RenderBox?;

    final origin =
        box == null ? Rect.zero : box.localToGlobal(Offset.zero) & box.size;

    await Share.shareXFiles(
      [XFile(entry.filePath)],
      sharePositionOrigin: origin,
      subject: "sync.export.save.shareTitle".t(context, {
        "type": entry.fileExt,
        "date": entry.createdDate.toMoment().lll,
      }),
    );
  }

  Future<void> delete(BuildContext context) async {
    final String title = entry.backupEntryType.localizedNameContext(context);

    final confirmation = await context.showConfirmDialog(
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
}

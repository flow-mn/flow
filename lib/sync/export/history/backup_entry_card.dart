import 'dart:io';

import 'package:flow/entity/backup_entry.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/l10n/named_enum.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/toast.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flow/widgets/general/surface.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:share_plus/share_plus.dart';

class BackupEntryCard extends StatelessWidget {
  final BackupEntry entry;

  final BorderRadius borderRadius;

  const BackupEntryCard({
    super.key,
    required this.entry,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
  });

  @override
  Widget build(BuildContext context) {
    final bool fileExists = entry.existsSync();

    return Surface(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (context) => InkWell(
        borderRadius: borderRadius,
        child: Row(
          children: [
            FlowIcon(
              entry.icon,
              size: 48.0,
              plated: true,
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
                  ),
                  Text(
                    "${entry.fileExt} • ${entry.createdDate.toMoment().calendar()}",
                    style: context.textTheme.bodyMedium?.semi(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            IconButton(
              onPressed: () => showShareSheet(context, fileExists),
              icon: fileExists
                  ? const Icon(Symbols.save_alt_rounded)
                  : Icon(
                      Symbols.error_circle_rounded_error,
                      color: context.flowColors.expense,
                    ),
            ),
            const SizedBox(width: 8.0),
          ],
        ),
      ),
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

    await Share.shareXFiles([XFile(entry.filePath)],
        sharePositionOrigin: origin,
        subject: "sync.export.save.shareTitle".t(context, {
          "type": entry.fileExt,
          "date": entry.createdDate.toMoment().lll,
        }));
  }
}

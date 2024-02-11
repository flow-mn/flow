import 'dart:io';

import 'package:flow/entity/backup_entry.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/l10n/named_enum.dart';
import 'package:flow/theme/theme.dart';
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
    return Surface(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (context) => InkWell(
        borderRadius: borderRadius,
        child: Row(
          children: [
            FlowIcon(
              entry.icon,
              size: 32.0,
              plated: true,
            ),
            const SizedBox(width: 12.0),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${entry.backupEntryType.localizedNameContext(context)} ${entry.fileExt}",
                ),
                Text(
                  entry.createdDate.toMoment().calendar(),
                  style: context.textTheme.bodyMedium?.semi(context),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: () => showShareSheet(context),
              icon: const Icon(Symbols.save_alt_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showShareSheet(BuildContext context) async {
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
        subject: "sync.export.share".t(context, entry.fileExt));
  }
}

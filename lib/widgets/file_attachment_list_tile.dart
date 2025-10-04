import "dart:async";
import "dart:io";

import "package:file_saver/file_saver.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/entity/file_attachment.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/file_attachment.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/directional_slidable.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:open_filex/open_filex.dart";

class FileAttachmentListTile extends StatefulWidget {
  final FileAttachment fileAttachment;
  final FutureOr<void> Function()? onDelete;
  final FutureOr<void> Function()? onShare;
  final Key? dismissibleKey;

  const FileAttachmentListTile({
    super.key,
    required this.fileAttachment,
    this.dismissibleKey,
    this.onDelete,
    this.onShare,
  });

  @override
  State<FileAttachmentListTile> createState() => _FileAttachmentListTileState();
}

class _FileAttachmentListTileState extends State<FileAttachmentListTile> {
  int? sizeInBytes;
  bool? fileExists;

  @override
  void initState() {
    super.initState();

    _inspectFile();
  }

  @override
  void didUpdateWidget(covariant FileAttachmentListTile oldWidget) {
    if (oldWidget.fileAttachment.id != widget.fileAttachment.id ||
        oldWidget.fileAttachment.filePath != widget.fileAttachment.filePath) {
      sizeInBytes = null;
      fileExists = null;
      _inspectFile();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final String subtitle = [
      widget.fileAttachment.createdDate.toMoment().toLocal().lll,
      sizeInBytes?.humanReadableBinarySize,
    ].whereType<String>().join(" • ");

    final List<SlidableAction> endActions = [
      if (widget.onDelete != null)
        SlidableAction(
          onPressed: (context) => widget.onDelete,
          icon: Symbols.delete_forever_rounded,
          backgroundColor: context.flowColors.expense,
        ),
    ];

    final List<SlidableAction> startActions = [
      if (widget.onShare != null)
        SlidableAction(
          onPressed: (context) => widget.onShare,
          icon: Symbols.share_rounded,
          backgroundColor: context.colorScheme.primary,
        ),
    ];

    return DirectionalSlidable(
      key: widget.dismissibleKey,
      startActions: startActions,
      endActions: endActions,
      child: ListTile(
        leading: FlowIcon(
          fileExists != false
              ? FlowIconData.icon(widget.fileAttachment.icon)
              : FlowIconData.icon(Symbols.error_circle_rounded),
          size: 24.0,
          color: fileExists == false ? context.colorScheme.error : null,
        ),
        title: Text(widget.fileAttachment.displayName),
        subtitle: Text(subtitle),
        onTap: open,
      ),
    );
  }

  void _inspectFile() async {
    final File file = widget.fileAttachment.file;

    final bool exists = await file.exists();

    fileExists = exists;

    if (!mounted) {
      return;
    }

    if (mounted) {
      setState(() {});
    }

    if (!exists) return;

    final int size = await file.length();

    sizeInBytes = size;

    if (mounted) {
      setState(() {});
    }
  }

  void open() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await OpenFilex.open(widget.fileAttachment.filePath);
      return;
    }

    final String savedPath = await FileSaver.instance.saveFile(
      filePath: widget.fileAttachment.filePath,
      name: widget.fileAttachment.fileName,
    );
    if (Platform.isLinux) {
      Process.runSync("xdg-open", [File(savedPath).parent.path]);
    }
    if (Platform.isMacOS) {
      Process.runSync("open", [File(savedPath).parent.path]);
    }
    if (Platform.isWindows) {
      Process.runSync("explorer", [File(savedPath).parent.path]);
    }
  }
}

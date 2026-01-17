import "package:flow/entity/file_attachment.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/routes/transaction_page/section.dart";
import "package:flow/services/file_attachment.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/file_attachment_add_list_tile.dart";
import "package:flow/widgets/file_attachment_list_tile.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/sheets/select_file_attachment_sheet.dart";
import "package:flutter/material.dart";
import "package:share_plus/share_plus.dart";

class FilesSection extends StatefulWidget {
  final List<FileAttachment>? attachments;
  final Function(List<XFile> files) onAdd;
  final Function(FileAttachment file) onRemove;

  const FilesSection({
    super.key,
    required this.onAdd,
    this.attachments,
    required this.onRemove,
  });

  @override
  State<FilesSection> createState() => FilesSectionState();
}

class FilesSectionState extends State<FilesSection> {
  int? totalSizeInBytes;

  @override
  void initState() {
    super.initState();

    _recalculateTotalSize();
  }

  @override
  void didUpdateWidget(covariant FilesSection oldWidget) {
    if (widget.attachments != oldWidget.attachments) {
      _recalculateTotalSize();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAttachments = widget.attachments?.isNotEmpty ?? false;

    return Section(
      title: "transaction.attachments".t(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FileAttachmentAddListTile(onTap: pickFile),
          ...?widget.attachments?.map(
            (file) => FileAttachmentListTile(
              fileAttachment: file,
              onDelete: () => delete(file),
              onShare: () => share(file),
            ),
          ),
          if (hasAttachments) ...[
            const SizedBox(height: 12.0),
            Frame(
              child: InfoText(
                child: Text(
                  "transaction.attachments.warning".t(
                    context,
                    totalSizeInBytes?.humanReadableBinarySize ?? "?",
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> pickFile() async {
    final List<XFile>? files = await showModalBottomSheet(
      context: context,
      builder: (context) => const SelectFileAttachmentSheet(),
    );
    if (files != null) {
      widget.onAdd(files);
    }
  }

  void share(FileAttachment file) async {
    try {
      final bool exists = await file.file.exists().catchError((_) => false);

      if (!exists) {
        throw Exception("File does not exist");
      }

      if (mounted) {
        final String title = file.name ?? "fileAttachment.share".t(context);

        await context.showFileShareSheet(
          filePath: file.file.path,
          subject: title,
        );
      }
    } catch (e) {
      if (!mounted) return;
      context.showErrorToast(error: "error.sync.fileNotFound".t(context));
    }
  }

  void delete(FileAttachment file) async {
    final bool? confirmation = await context.showConfirmationSheet(
      isDeletionConfirmation: true,
      title: "fileAttachment.delete".t(context),
      child: Text("fileAttachment.delete".t(context)),
    );

    if (confirmation != true || !mounted) return;

    try {
      await FileAttachmentService().deleteIfOrphan(file);
      if (mounted) {
        context.showToast(text: "fileAttachment.delete.success".t(context));
      }
    } catch (e) {
      if (!mounted) return;
      context.showErrorToast(error: "error.sync.fileNotFound".t(context));
    } finally {
      widget.onRemove(file);
    }
  }

  void _recalculateTotalSize() {
    int sum = 0;

    for (final FileAttachment attachment in (widget.attachments ?? [])) {
      try {
        sum += attachment.file.lengthSync();
      } catch (e) {
        // Ignore
      }
    }

    totalSizeInBytes = sum;
    setState(() {});
  }
}

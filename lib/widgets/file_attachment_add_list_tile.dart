import "package:cross_file/cross_file.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/sheets/select_file_attachment_sheet.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class FileAttachmentAddListTile extends StatelessWidget {
  final Function(List<XFile> files) onFilesPicked;

  const FileAttachmentAddListTile({super.key, required this.onFilesPicked});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FlowIcon(FlowIconData.icon(Symbols.add_rounded), size: 24.0),
      title: Text("fileAttachment.add".t(context)),
      onTap: () => pickFile(context),
    );
  }

  void pickFile(BuildContext context) async {
    final List<XFile>? files = await showModalBottomSheet(
      context: context,
      builder: (context) => const SelectFileAttachmentSheet(),
    );
    if (files != null) {
      onFilesPicked(files);
    }
  }
}

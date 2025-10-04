import "dart:io";

import "package:flow/l10n/flow_localizations.dart";
import "package:flow/utils/pick_file.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with a List of [XFile]
class SelectFileAttachment extends StatefulWidget {
  const SelectFileAttachment({super.key});

  @override
  State<SelectFileAttachment> createState() => _SelectFileAttachmentState();
}

class _SelectFileAttachmentState extends State<SelectFileAttachment> {
  @override
  void initState() {
    super.initState();

    if (!(Platform.isIOS || Platform.isAndroid)) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        pickFromFiles();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text("fileAttachment.file".t(context)),
            leading: const Icon(Symbols.files_rounded),
            onTap: pickFromFiles,
          ),
          if (Platform.isIOS || Platform.isAndroid)
            ListTile(
              title: Text("fileAttachment.takePhoto".t(context)),
              leading: const Icon(Symbols.photo_camera_rounded),
              onTap: takePhoto,
            ),
          if (Platform.isIOS || Platform.isAndroid)
            ListTile(
              title: Text("fileAttachment.photos".t(context)),
              leading: const Icon(Symbols.image_rounded),
              onTap: pickImages,
            ),
        ],
      ),
    );
  }

  void pickFromFiles() async {
    final List<XFile>? files = await pickFiles();

    if (mounted) {
      context.pop(files);
    }
  }

  void pickImages() async {
    final List<XFile>? files = await pickMultipleMediaFiles();

    if (mounted) {
      context.pop(files);
    }
  }

  void takePhoto() async {
    final XFile? file = await pickImage(source: ImageSource.camera);

    if (mounted) {
      context.pop(file == null ? null : [file]);
    }
  }
}

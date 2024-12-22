import "dart:async";
import "dart:developer";
import "dart:io";
import "dart:ui" as ui;

import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:path/path.dart" as path;
import "package:uuid/uuid.dart";

class SelectImageFlowIconSheet extends StatefulWidget {
  final FlowIconData? initialValue;

  final double iconSize;

  const SelectImageFlowIconSheet({
    super.key,
    this.initialValue,
    required this.iconSize,
  });

  @override
  State<SelectImageFlowIconSheet> createState() =>
      _SelectImageFlowIconSheetState();
}

class _SelectImageFlowIconSheetState extends State<SelectImageFlowIconSheet> {
  late final VoidCallback? cleanUpImage;

  ImageFlowIcon? value;

  bool busy = false;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue is ImageFlowIcon
        ? widget.initialValue as ImageFlowIcon
        : null;

    if (value != null) {
      final String initialImagePath = value!.imagePath;

      cleanUpImage = () {
        // If the image hasn't changed, no need to delete it.
        if (value != null) {
          if (value!.imagePath == initialImagePath) {
            return;
          }
        }

        final File oldImage = File(
          path.join(
            ObjectBox.appDataDirectory,
            initialImagePath,
          ),
        );

        unawaited(oldImage.exists().then((_) {
          unawaited(oldImage.delete());
        }));
      };
    } else {
      cleanUpImage = null;
    }
  }

  @override
  void dispose() {
    if (cleanUpImage != null) {
      cleanUpImage!();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet(
      title: Text("flowIcon.type.image".t(context)),
      trailing: ModalOverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(value),
            icon: const Icon(Symbols.check_rounded),
            label: Text(
              "general.done".t(context),
            ),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24.0),
          FlowIcon(
            value ?? FlowIconData.icon(Symbols.image_rounded),
            size: widget.iconSize,
            plated: true,
            onTap: updatePicture,
          ),
          const SizedBox(height: 8.0),
          TextButton.icon(
            onPressed: updatePicture,
            icon: const Icon(Symbols.add_photo_alternate_rounded),
            label: Text(
              "flowIcon.type.image.pick".t(context),
            ),
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }

  void updatePicture() async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      final cropped = await pickAndCropSquareImage(context, maxDimension: 256);
      if (cropped == null) {
        // Error toast is handled in `pickAndCropSquareImage`
        return;
      }

      final byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();

      if (bytes == null) throw "";

      final fileName = "${const Uuid().v4()}.png";
      final file = File(path.join(
        ObjectBox.imagesDirectory,
        fileName,
      ));
      await file.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);

      value = ImageFlowIcon("images/$fileName");
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      log("[Select Icon Sheet] uploadPicture has failed due to: $e");
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }
}

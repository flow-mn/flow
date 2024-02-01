import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/general/bottom_sheet_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> openUrl(
  Uri uri, [
  LaunchMode mode = LaunchMode.externalApplication,
]) async {
  final canOpen = await canLaunchUrl(uri);
  if (!canOpen) return false;

  try {
    return await launchUrl(uri);
  } catch (e) {
    log("[Flow] Failed to launch uri ($uri) due to $e");
    return false;
  }
}

void numpadHaptic() {
  HapticFeedback.mediumImpact();
}

Future<File?> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result == null) {
    return null;
  }

  return File(result.files.single.path!);
}

extension CustomDialogs on BuildContext {
  Future<bool?> showConfirmDialog({
    Function(bool?)? callback,
    String? title,
    bool isDeletionConfirmation = false,
  }) async {
    final bool? result = await showModalBottomSheet(
      context: this,
      builder: (context) => BottomSheetFrame(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16.0),
            Text(
              title ?? "general.areYouSure".t(context),
              style: context.textTheme.headlineSmall,
            ),
            if (isDeletionConfirmation) ...[
              const SizedBox(height: 8.0),
              Text(
                "general.delete.permanentWarning".t(context),
                style: context.textTheme.bodySmall?.semi(context),
              ),
            ],
            const SizedBox(height: 16.0),
            ButtonBar(
              children: [
                ElevatedButton(
                  onPressed: () => context.pop(false),
                  child: Text(
                    "general.cancel".t(context),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => context.pop(false),
                  child: Text(
                    isDeletionConfirmation
                        ? "general.delete".t(context)
                        : "general.confirm".t(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (callback != null) {
      callback(result);
    }
    return null;
  }
}

Future<XFile?> pickImage({
  ImageSource source = ImageSource.gallery,
  double? maxWidth,
  double? maxHeight,
}) async {
  final xfile = ImagePicker().pickImage(
    source: source,
    maxHeight: maxHeight,
    maxWidth: maxWidth,
    requestFullMetadata: false,
    imageQuality: 100,
  );

  return xfile;
}

import "dart:io";
import "dart:ui" as ui;

import "package:file_picker/file_picker.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/utils/crop_square_image_page.dart";
import "package:flow/utils/extensions/toast.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";
import "package:logging/logging.dart";
import "package:path_provider/path_provider.dart";

final Logger _log = Logger("PickFile");

Future<File?> pickImportFile({String? dialogTitle}) async {
  await _clearPickerCache();

  FilePickerResult? result = await FilePicker.platform.pickFiles(
    dialogTitle: dialogTitle ?? "sync.import.pickFile".tr(),
    initialDirectory: await getApplicationDocumentsDirectory()
        .then<String?>((value) => value.path)
        .catchError((_) => null),
    type: FileType.any,
    allowMultiple: false,
  );

  if (result == null) {
    return null;
  }

  return File(result.files.single.path!);
}

Future<List<XFile>?> pickFiles() async {
  await _clearPickerCache();

  FilePickerResult? result = await FilePicker.platform.pickFiles(
    dialogTitle: "fileAttachment.pick".tr(),
    initialDirectory: await getApplicationDocumentsDirectory()
        .then<String?>((value) => value.path)
        .catchError((_) => null),
    type: FileType.any,
    allowMultiple: true,
  );

  if (result == null) {
    return null;
  }

  return result.files.map((platformFile) => platformFile.xFile).toList();
}

/// Android only, on iOS the plugin clears the whole temp directory itself
Future<void> _clearPickerCache() async {
  if (!Platform.isAndroid) return;

  try {
    await FilePicker.platform.clearTemporaryFiles();
  } catch (e) {
    _log.warning("Failed to clear file picker cache", e);
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

Future<List<XFile>?> pickMultipleMediaFiles({
  double? maxWidth,
  double? maxHeight,
  int? limit,
}) async {
  final xFiles = await ImagePicker().pickMultipleMedia(
    maxHeight: maxHeight,
    maxWidth: maxWidth,
    requestFullMetadata: false,
    imageQuality: 99,
    limit: limit,
  );

  return xFiles;
}

Future<ui.Image?> pickAndCropSquareImage(
  BuildContext context, {
  double? maxDimension,
}) async {
  final xfile = await pickImage(maxWidth: 512, maxHeight: 512);

  if (xfile == null) {
    if (context.mounted) {
      context.showErrorToast(error: "error.input.noImagePicked".t(context));
    }
    return null;
  }
  if (!context.mounted) return null;

  final cropped = await context.push<ui.Image>(
    "/utils/cropsquare",
    extra: CropSquareImagePageProps(file: File(xfile.path)),
  );

  if (cropped == null) {
    if (context.mounted) {
      context.showErrorToast(error: "error.input.cropFailed".t(context));
    }
    return null;
  }

  return cropped;
}

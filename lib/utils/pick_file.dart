import "dart:io";
import "dart:ui" as ui;

import "package:file_picker/file_picker.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/utils/crop_square_image_page.dart";
import "package:flow/utils/extensions/toast.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";
import "package:path_provider/path_provider.dart";

Future<File?> pickJsonOrZipFile({String? dialogTitle}) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    dialogTitle: dialogTitle ?? "Select a backup file",
    initialDirectory: await getApplicationDocumentsDirectory()
        .then<String?>((value) => value.path)
        .catchError((_) => null),
    allowedExtensions: ["json", "zip", "csv"],
    type: FileType.custom,
    allowMultiple: false,
  );

  if (result == null) {
    return null;
  }

  return File(result.files.single.path!);
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

  final image = Image.file(File(xfile.path));

  final cropped = await context.push<ui.Image>(
    "/utils/cropsquare",
    extra: CropSquareImagePageProps(image: image),
  );

  if (cropped == null) {
    if (context.mounted) {
      context.showErrorToast(error: "error.input.cropFailed".t(context));
    }
    return null;
  }

  return cropped;
}

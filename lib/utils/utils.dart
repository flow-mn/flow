import "dart:io";
import "dart:typed_data";
import "dart:ui" as ui;

import "package:file_picker/file_picker.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/utils/crop_square_image_page.dart";
import "package:flow/utils/extensions/toast.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:http/http.dart" as http;
import "package:image_picker/image_picker.dart";
import "package:logging/logging.dart";
import "package:url_launcher/url_launcher.dart";

export "csv_parser.dart";
export "extensions.dart";
export "is_desktop.dart";
export "jasonable.dart";
export "line_break_normalizer.dart";
export "number_formatting.dart";
export "open_url.dart";
export "optional.dart";
export "pick_file.dart";
export "shortcut.dart";
export "should_execute_scheduled_task.dart";
export "simple_query_sorter.dart";
export "time_and_range.dart";

final Logger _log = Logger("Flow");

Future<bool> openUrl(
  Uri uri, [
  LaunchMode mode = LaunchMode.externalApplication,
]) async {
  try {
    return await launchUrl(uri);
  } catch (e) {
    _log.warning("Failed to launch uri ($uri)", e);
    return false;
  }
}

Future<File?> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

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
  final double dimensionAllowedDimension = maxDimension ?? 512;

  final xfile = await pickImage(
    maxWidth: dimensionAllowedDimension,
    maxHeight: dimensionAllowedDimension,
  );

  if (xfile == null) {
    if (context.mounted) {
      context.showErrorToast(error: "error.input.noImagePicked".t(context));
    }
    return null;
  }
  if (!context.mounted) return null;

  final ui.Image? cropped = await context.push<ui.Image>(
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

Future<Uint8List?> downloadInternetImage(String? uri) async {
  try {
    final Uri parsed = Uri.parse(uri!);
    if (parsed.scheme != "http" && parsed.scheme != "https") {
      throw StateError("Only HTTP(S) URIs are supported");
    }
    if (!await _isNetworkImage(uri)) {
      throw StateError("The provided URI does not point to an image");
    }

    final response = await http.get(parsed);
    if (response.statusCode != 200) {
      throw StateError("Failed to download image: ${response.statusCode}");
    }
    return response.bodyBytes;
  } catch (e) {
    _log.warning("downloadInternetImage has failed due to", e);
  }

  return null;
}

Future<bool> _isNetworkImage(String imageUrl) async {
  try {
    final response = await http.head(
      Uri.parse(imageUrl),
    ); // Use http.head for efficiency
    if (response.statusCode == 200) {
      final contentType = response.headers["content-type"];
      return contentType != null && contentType.startsWith("image/");
    }
    return false;
  } catch (e) {
    return false;
  }
}

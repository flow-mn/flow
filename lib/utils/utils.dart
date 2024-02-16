import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/routes/utils/crop_square_image_page.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/toast.dart';
import 'package:flow/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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

Future<File?> pickJsonFile({String? dialogTitle}) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    dialogTitle: dialogTitle ?? "Select a backup file",
    initialDirectory: await getApplicationDocumentsDirectory()
        .then<String?>((value) => value.path)
        .catchError((_) => null),
    allowedExtensions: ["json"],
    type: FileType.custom,
    allowMultiple: false,
  );

  if (result == null) {
    return null;
  }

  return File(result.files.single.path!);
}

extension CustomDialogs on BuildContext {
  Future<bool?> showConfirmDialog({
    Function(bool?)? callback,
    String? title,
    String? mainActionLabelOverride,
    bool isDeletionConfirmation = false,
    Widget? child,
  }) async {
    final bool? result = await showModalBottomSheet(
      context: this,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              title ?? "general.areYouSure".t(context),
              style: context.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          if (child != null || isDeletionConfirmation) ...[
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: child ??
                  Text(
                    "general.delete.permanentWarning".t(context),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.flowColors.expense,
                    ),
                    textAlign: TextAlign.center,
                  ),
            ),
          ],
          const SizedBox(height: 16.0),
          ButtonBar(
            children: [
              Button(
                onTap: () => context.pop(false),
                child: Text(
                  "general.cancel".t(context),
                ),
              ),
              Button(
                onTap: () => context.pop(true),
                child: Text(
                  mainActionLabelOverride ??
                      (isDeletionConfirmation
                          ? "general.delete".t(context)
                          : "general.confirm".t(context)),
                  style: isDeletionConfirmation
                      ? TextStyle(color: context.flowColors.expense)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (callback != null) {
      callback(result);
    }

    return result;
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

Future<ui.Image?> pickAndCropSquareImage(
  BuildContext context, {
  double? maxDimension,
}) async {
  final xfile = await pickImage(
    maxWidth: 512,
    maxHeight: 512,
  );

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

bool isDesktop() {
  return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}

// Ongoing issue about lack of `popUntil`
// https://github.com/flutter/flutter/issues/131625
extension GoRouterExt on GoRouter {
  void popUntil(bool Function(GoRoute) predicate) {
    List routeStacks = [...routerDelegate.currentConfiguration.routes];

    for (int i = routeStacks.length - 1; i >= 0; i--) {
      RouteBase route = routeStacks[i];
      if (route is GoRoute) {
        if (predicate(route)) break;
        if (i != 0 && routeStacks[i - 1] is ShellRoute) {
          RouteMatchList matchList = routerDelegate.currentConfiguration;
          restore(matchList.remove(matchList.matches.last));
        } else {
          pop();
        }
      }
    }
  }
}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));

  E? firstWhereOrNull(bool Function(E element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

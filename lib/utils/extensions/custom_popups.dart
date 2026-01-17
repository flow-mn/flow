import "dart:io";

import "package:file_saver/file_saver.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:path/path.dart";
import "package:share_plus/share_plus.dart";

extension CustomPopups on BuildContext {
  Future<bool?> showConfirmationSheet({
    Function(bool?)? callback,
    String? title,
    String? mainActionLabelOverride,
    bool isDeletionConfirmation = false,
    Widget? child,
  }) async {
    final bool? result = await showModalBottomSheet(
      context: this,
      builder: (context) => ModalSheet(
        title: Text(title ?? "general.areYouSure".t(context)),
        trailing: ModalOverflowBar(
          alignment: .end,
          children: [
            Button(
              onTap: () => context.pop(false),
              child: Text("general.cancel".t(context)),
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
        child:
            child ??
            (isDeletionConfirmation
                ? Text(
                    "general.delete.permanentWarning".t(context),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.flowColors.expense,
                    ),
                    textAlign: TextAlign.center,
                  )
                : null),
      ),
    );

    if (callback != null) {
      callback(result);
    }

    return result;
  }

  /// Returns the saved path on desktop, null on mobile
  Future<String?> showFileShareSheet({
    required String subject,
    required String filePath,
  }) async {
    if (Platform.isMacOS || Platform.isLinux) {
      final String savedPath = await FileSaver.instance.saveFile(
        filePath: filePath,
        name: basename(filePath),
      );
      if (Platform.isLinux) {
        Process.runSync("xdg-open", [File(savedPath).parent.path]);
      }
      if (Platform.isMacOS) {
        Process.runSync("open", [File(savedPath).parent.path]);
      }
      return savedPath;
    }

    final RenderBox? renderBox = findRenderObject() as RenderBox?;

    final origin = renderBox == null
        ? Rect.zero
        : renderBox.localToGlobal(Offset.zero) & renderBox.size;

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath)],
        sharePositionOrigin: origin,
        subject: subject,
      ),
    );

    return null;
  }

  Future<ShareResult> showUriShareSheet({required Uri uri}) async {
    final RenderBox? renderBox = findRenderObject() as RenderBox?;
    final origin = renderBox == null
        ? Rect.zero
        : renderBox.localToGlobal(Offset.zero) & renderBox.size;

    if (Platform.isIOS || Platform.isAndroid) {
      return await SharePlus.instance.share(
        ShareParams(uri: uri, sharePositionOrigin: origin),
      );
    }

    return await SharePlus.instance.share(
      ShareParams(text: uri.toString(), sharePositionOrigin: origin),
    );
  }

  static final CustomTimeRange _pickDateDefaultBounds = CustomTimeRange(
    DateTime.fromMicrosecondsSinceEpoch(0),
    DateTime(4000),
  );

  Future<DateTime?> pickDate([DateTime? initial, TimeRange? bounds]) async {
    bounds =
        (bounds ?? _pickDateDefaultBounds).intersect(_pickDateDefaultBounds) ??
        _pickDateDefaultBounds;

    final DateTime initialDate = DateTime.fromMicrosecondsSinceEpoch(
      (initial ?? DateTime.now()).microsecondsSinceEpoch.clamp(
        bounds.from.microsecondsSinceEpoch,
        bounds.to.microsecondsSinceEpoch,
      ),
    );

    return await showDatePicker(
      context: this,
      initialDate: initialDate,
      firstDate: bounds.from,
      lastDate: bounds.to,
    );
  }

  Future<DateTime?> pickTime({DateTime? anchor, TimeOfDay? initial}) async {
    anchor ??= DateTime.now();

    final TimeOfDay initialTime = initial ?? TimeOfDay.fromDateTime(anchor);

    final TimeOfDay? time = await showTimePicker(
      context: this,
      initialTime: initial ?? initialTime,
    );

    if (time == null) return null;

    return anchor.date.add(Duration(hours: time.hour, minutes: time.minute));
  }

  Future<void> showImagePreview({
    File? file,
    String? url,
    Uint8List? bytes,
  }) async {
    assert(file != null || url != null || bytes != null);

    late final ImageProvider imageProvider;

    if (file != null) {
      imageProvider = FileImage(file);
    } else if (url != null) {
      imageProvider = NetworkImage(url);
    } else if (bytes != null) {
      imageProvider = MemoryImage(bytes);
    } else {
      throw ArgumentError("One of file, url or bytes must be provided.");
    }

    await showGeneralDialog(
      context: this,
      pageBuilder: (context, animation, secondaryAnimation) {
        void tryPop() {
          if (context.mounted) {
            context.pop();
          }
        }

        return CallbackShortcuts(
          bindings: {SingleActivator(LogicalKeyboardKey.escape): tryPop},
          child: Transform.translate(
            offset: Offset(0.0, 1.0 - secondaryAnimation.value),
            child: Container(
              color: const Color(0x80000000),
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: InteractiveViewer(
                        minScale: 1.0,
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Image(image: imageProvider),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20.0,
                      left: 20.0,
                      child: IconButton(
                        onPressed: tryPop,
                        icon: Icon(Symbols.close_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

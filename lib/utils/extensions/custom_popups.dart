import "dart:io";

import "package:file_saver/file_saver.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
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
      builder:
          (context) => ModalSheet(
            title: Text(title ?? "general.areYouSure".t(context)),
            trailing: ModalOverflowBar(
              alignment: MainAxisAlignment.end,
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
                    style:
                        isDeletionConfirmation
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

    final origin =
        renderBox == null
            ? Rect.zero
            : renderBox.localToGlobal(Offset.zero) & renderBox.size;

    await Share.shareXFiles(
      [XFile(filePath)],
      sharePositionOrigin: origin,
      subject: subject,
    );

    return null;
  }

  Future<ShareResult> showUriShareSheet({required Uri uri}) async {
    final RenderBox? renderBox = findRenderObject() as RenderBox?;
    final origin =
        renderBox == null
            ? Rect.zero
            : renderBox.localToGlobal(Offset.zero) & renderBox.size;

    if (Platform.isIOS || Platform.isAndroid) {
      return await Share.shareUri(uri, sharePositionOrigin: origin);
    }

    return await Share.share(uri.toString(), sharePositionOrigin: origin);
  }
}

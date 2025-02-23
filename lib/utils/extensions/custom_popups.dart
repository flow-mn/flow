import "dart:io";

import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
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

  Future<void> showShareSheet({
    required String subject,
    required String filePath,
    required RenderBox? renderBox,
  }) async {
    if (Platform.isLinux) {
      Process.runSync("xdg-open", [File(filePath).parent.path]);
      return;
    }

    final origin =
        renderBox == null
            ? Rect.zero
            : renderBox.localToGlobal(Offset.zero) & renderBox.size;

    await Share.shareXFiles(
      [XFile(filePath)],
      sharePositionOrigin: origin,
      subject: subject,
    );
  }
}

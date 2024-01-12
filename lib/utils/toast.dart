import 'package:flow/l10n/localized_exception.dart';
import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:oktoast/oktoast.dart';

extension ToastHelper on BuildContext {
  ToastFuture showErrorToast({required dynamic error, Widget? icon}) =>
      showToast(
        text: switch (error) {
          LocalizedException localizedException =>
            localizedException.localizedString(this),
          String errorText => errorText,
          _ => error.toString(),
        },
        icon: icon,
        error: true,
      );

  ToastFuture showToast({
    required String text,
    bool error = false,
    Widget? icon,
  }) {
    icon ??= Icon(
      Symbols.error_circle_rounded_error_rounded,
      color: colorScheme.error,
    );

    final Widget contents = Material(
      elevation: 2.0,
      borderRadius: BorderRadius.circular(16.0),
      type: MaterialType.card,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12.0),
            Flexible(child: Text(text)),
          ],
        ),
      ),
    );

    if (error) {
      HapticFeedback.heavyImpact();
    }

    return showToastWidget(
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: contents,
      ),
      position: const ToastPosition(align: Alignment.topCenter),
    );
  }
}

import "package:flow/l10n/localized_exception.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:toastification/toastification.dart";

extension ToastHelper on BuildContext {
  ToastificationItem showErrorToast({required dynamic error, Widget? icon}) =>
      showToast(
        text: switch (error) {
          LocalizedException localizedException => localizedException
              .localizedString(this),
          String errorText => errorText,
          _ => error.toString(),
        },
        icon: icon,
        type: ToastificationType.error,
      );

  ToastificationItem showToast({
    required String text,
    ToastificationType type = ToastificationType.success,
    Widget? icon,
  }) {
    if (icon == null) {
      if (type == ToastificationType.success) {
        icon = Icon(Symbols.check_rounded, color: flowColors.income);
      } else {
        icon = Icon(Symbols.error_circle_rounded, color: colorScheme.error);
      }
    }

    if (type == ToastificationType.error) {
      if (LocalPreferences().enableHapticFeedback.get()) {
        HapticFeedback.heavyImpact();
      }
    }

    return toastification.show(
      context: this,
      title: Text(text),
      type: type,
      icon: icon,
      autoCloseDuration: const Duration(seconds: 5),
      alignment: Alignment.topCenter,
      primaryColor: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      showProgressBar: false,
      style: ToastificationStyle.flat,
      boxShadow: [
        BoxShadow(
          color: colorScheme.onSurface.withAlpha(0x40),
          offset: const Offset(0.0, 1.0),
          blurRadius: 4.0,
          spreadRadius: -1.5,
        ),
      ],
    );
  }
}

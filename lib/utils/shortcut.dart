import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";

bool _shouldUseMeta() => Platform.isMacOS || Platform.isIOS;

/// A SingleActivator that gets triggered if [key] is pressed with
/// * `Meta` for macOS and iOS (iPadOS)
/// * `Control` for other platforms
///
/// It's also possible to pass [shift] and [alt] to the constructor.
osSingleActivator(
  LogicalKeyboardKey key, [
  bool shift = false,
  bool alt = false,
]) {
  final meta = _shouldUseMeta();
  final control = !meta;

  return SingleActivator(
    key,
    control: control,
    meta: meta,
    shift: shift,
    alt: alt,
  );
}

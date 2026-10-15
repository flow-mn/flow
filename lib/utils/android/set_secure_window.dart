import "dart:io";

import "package:flutter/services.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("SecureWindow");

const MethodChannel _channel = MethodChannel("mn.flow.flow/window");

/// Toggles `FLAG_SECURE`, which hides the app from screenshots and the
/// recents screen. No-op on other platforms.
Future<void> setSecureWindow(bool secure) async {
  if (!Platform.isAndroid) return;

  try {
    await _channel.invokeMethod("setSecure", secure);
  } catch (error, stackTrace) {
    _log.warning("Failed to set secure window flag", error, stackTrace);
  }
}

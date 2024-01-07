import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flow/prefs.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> openUrl(
  Uri uri, [
  LaunchMode mode = LaunchMode.externalApplication,
]) async {
  final canOpen = await canLaunchUrl(uri);
  if (!canOpen) return false;

  try {
    launchUrl(uri);
  } catch (e) {
    log("[Flow] Failed to launch uri ($uri) due to $e");
    return false;
  }

  return true;
}

void numpadHaptic() {
  if (LocalPreferences().enableNumpadHapticFeedback.get()) {
    HapticFeedback.mediumImpact();
  }
}

Future<File?> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result == null) {
    return null;
  }

  return File(result.files.single.path!);
}

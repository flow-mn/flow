import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:flow/sync/export/export_v1.dart';
import 'package:flow/sync/sync.dart';
import 'package:flow/utils.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';

Future<bool> export([bool csv = false]) async {
  // Sharing [XFile]s aren't supported yet on Linux and Windows.
  //
  // https://pub.dev/packages/share_plus#platform-support
  final bool isShareSupported =
      !(Platform.isLinux || Platform.isWindows || Platform.isFuchsia);

  final backupContent = switch ((csv, latestSyncModelVersion)) {
    (true, 1) => await generateCSVContentV1(),
    (false, 1) => await generateBackupContentV1(),
    _ => throw UnimplementedError(),
  };
  final savedFilePath = await saveBackupFile(
    backupContent,
    isShareSupported,
    fileExt: csv ? "csv" : "json",
  );
  return await showFileSaveDialog(savedFilePath, isShareSupported);
}

/// Returns file path after successfully saving it
Future<String> saveBackupFile(
  String backupContent,
  bool isShareSupported, {
  required String fileExt,
}) async {
  // Save to cache if it's possible to share later.
  // Otherwise, save to documents directory, and reveal the file on system.
  final Directory saveDir = isShareSupported
      ? await getApplicationCacheDirectory()
      : await getApplicationDocumentsDirectory();

  final String dateTime = Moment.now().lll.replaceAll(RegExp("\\s"), "_");
  final String randomValue = math.Random().nextInt(2 ^ 29).toRadixString(36);
  final String filename = "flow_backup_${dateTime}_$randomValue.$fileExt";

  log("[Flow Sync] Writing to ${path.join(saveDir.path, filename)}");

  final File f = File(path.join(saveDir.path, filename));
  f.createSync(recursive: true);
  f.writeAsStringSync(backupContent);

  log("[Flow Sync] Write successful. See file at: ${f.path}");

  return f.path;
}

/// Returns whether the file was saved/revealed successfully
Future<bool> showFileSaveDialog(
    String savedFilePath, bool isShareSupported) async {
  if (isShareSupported) {
    final shareResult = await Share.shareXFiles(
      [XFile(savedFilePath)],
      subject: path.basename(savedFilePath),
      text: "Backup for Flow",
    );

    return shareResult.status == ShareResultStatus.success;
  } else {
    return await openUrl(
      Uri(
        scheme: "file",
        path: path.dirname(savedFilePath),
      ),
    );
  }
}

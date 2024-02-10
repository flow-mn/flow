import 'dart:io';

import 'package:flow/objectbox.dart';

Future<void> testCleanupObject({
  required ObjectBox instance,
  required String directory,
  bool cleanUp = true,
}) async {
  instance.store.close();

  if (cleanUp) {
    await Directory(directory).delete(recursive: true);
  }
}

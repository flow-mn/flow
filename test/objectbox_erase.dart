import 'dart:io';

import 'package:flow/objectbox.dart';

Future<void> testCleanupObject({
  required ObjectBox instance,
  required String directory,
}) async {
  instance.store.close();
  await Directory(directory).delete(recursive: true);
}

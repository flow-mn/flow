import "dart:developer";
import "dart:io";

import "package:flow/entity/profile.dart";
import "package:flow/objectbox.dart";
import "package:path/path.dart" as path;

void nonImportantMigrateProfileImagePath() async {
  try {
    final String? profileUuid =
        ObjectBox().box<Profile>().getAll().firstOrNull?.uuid;

    if (profileUuid == null) {
      throw "Profile UUID is null";
    }

    final File old = File(path.join(
      ObjectBox.appDataDirectory,
      "$profileUuid.png",
    ));

    if (!old.existsSync()) {
      throw "Old profile image path doesn't exist";
    }

    await old.copy(path.join(
      ObjectBox.imagesDirectory,
      "$profileUuid.png",
    ));

    await old.delete();
  } catch (e) {
    log("[Flow] Failed to migrate profile image path due to:\n$e");
  }
}

import "dart:developer";
import "dart:io";

import "package:flow/entity/profile.dart";
import "package:flow/entity/user_preferences.dart";
import "package:flow/objectbox.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:path/path.dart" as path;
import "package:shared_preferences/shared_preferences.dart";

void nonImportantMigrateProfileImagePath() async {
  try {
    final String? profileUuid =
        ObjectBox().box<Profile>().getAll().firstOrNull?.uuid;

    if (profileUuid == null) {
      throw "Profile UUID is null";
    }

    final File old = File(
      path.join(ObjectBox.appDataDirectory, "$profileUuid.png"),
    );

    if (!old.existsSync()) {
      throw "Old profile image path doesn't exist";
    }

    await old.copy(path.join(ObjectBox.imagesDirectory, "$profileUuid.png"));

    await old.delete();
  } catch (e) {
    log("[Flow] Failed to migrate profile image path due to:\n$e");
  }
}

void migrateLocalPrefsRequirePendingTransactionConfrimation() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? oldValue = prefs.getBool(
      "flow.requirePendingTransactionConfrimation",
    );

    if (oldValue == null) return;

    await LocalPreferences().pendingTransactions.requireConfrimation.set(
      oldValue,
    );
  } catch (e) {
    log(
      "[Flow] Failed to migrate requirePendingTransactionConfrimation due to:\n$e",
    );
  }
}

void migrateLocalPrefsUserPreferencesRegardingTransferStuff() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool? combineTransfers = prefs.getBool(
      "flow.combineTransferTransactions",
    );
    final bool? excludeTransfersFromFlow = prefs.getBool(
      "flow.excludeTransferFromFlow",
    );

    final UserPreferences userPreferences =
        ObjectBox().box<UserPreferences>().getAll().firstOrNull ??
        UserPreferences();

    if (combineTransfers != null) {
      userPreferences.combineTransfers = combineTransfers;
    }
    if (excludeTransfersFromFlow != null) {
      userPreferences.excludeTransfersFromFlow = excludeTransfersFromFlow;
    }

    ObjectBox().box<UserPreferences>().put(userPreferences);
  } catch (e) {
    log(
      "[Flow] Failed to migrate user preferences regarding transfer stuff due to:\n$e",
    );
  }
}

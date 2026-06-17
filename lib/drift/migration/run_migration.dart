import "package:flow/drift/flow_drift.dart";
import "package:flow/drift/migration/objectbox_to_drift.dart";
import "package:logging/logging.dart";
import "package:shared_preferences/shared_preferences.dart";

final Logger _log = Logger("DriftMigration");

/// Bump the suffix if the harness changes in a way that needs a re-copy.
const String _migrationDoneKey = "flow.migration.objectbox_to_drift.v1";

/// Transparently copies existing ObjectBox data into the Drift/PowerSync DB
/// exactly once so users never migrate by hand.
///
/// Safe to call on every launch: it no-ops once the copy has succeeded, only
/// READS ObjectBox (never mutates it — zero risk to existing data), and
/// swallows errors so a failure can't break startup; the app keeps running on
/// ObjectBox and the copy retries next launch. The completion flag is set only
/// after a fully successful run.
Future<void> migrateObjectBoxToDriftIfNeeded() async {
  try {
    final SharedPreferencesWithCache prefs =
        await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(),
        );

    if (prefs.getBool(_migrationDoneKey) == true) return;

    _log.info("Starting one-time ObjectBox → Drift/PowerSync migration");

    final FlowDrift flow = await FlowDrift.initialize();
    await ObjectBoxToDriftMigration(flow.db).run();

    await prefs.setBool(_migrationDoneKey, true);
    _log.info("ObjectBox → Drift/PowerSync migration complete");
  } catch (e, stackTrace) {
    _log.severe(
      "ObjectBox → Drift/PowerSync migration failed; will retry next launch",
      e,
      stackTrace,
    );
  }
}

import "dart:io";

import "package:drift_sqlite_async/drift_sqlite_async.dart";
import "package:flow/drift/flow_database.dart";
import "package:flow/drift/flow_schema.dart";
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";
import "package:powersync/powersync.dart";

/// Owns Flow's SQLite database: a [PowerSyncDatabase] (the engine) with a
/// [FlowDatabase] (Drift, for type-safe access) attached on top via
/// [SqliteAsyncDriftConnection].
///
/// Stage 1 is **local-only**: [connect] is never called, so PowerSync behaves
/// as a plain local SQLite DB and queues no remote sync. Wiring a backend
/// connector is a later stage. Mirrors the singleton shape of [ObjectBox] so
/// the rest of the app can adopt it incrementally.
class FlowDrift {
  static FlowDrift? _instance;
  static Future<FlowDrift>? _initializing;

  /// The PowerSync engine. Use for raw SQL / sync control; use [db] for
  /// type-safe Drift queries against the same connection.
  final PowerSyncDatabase powerSync;

  /// Type-safe Drift access over the same [powerSync] connection.
  final FlowDatabase db;

  FlowDrift._(this.powerSync, this.db);

  factory FlowDrift() {
    final FlowDrift? instance = _instance;
    if (instance == null) {
      throw StateError(
        "FlowDrift is not initialized. Call FlowDrift.initialize() first.",
      );
    }
    return instance;
  }

  static bool get isInitialized => _instance != null;

  /// Opens the PowerSync database and attaches Drift. Pass [customPath] to
  /// place the DB file in a specific directory (used by the migration harness
  /// and tests); defaults to the app support directory.
  static Future<FlowDrift> initialize({String? customPath}) {
    // Memoize the in-flight future so concurrent callers share one open and
    // can't race past a null-check to open the PowerSync DB twice. On failure,
    // clear the cache so a later call retries instead of replaying the error.
    return _initializing ??= _open(customPath).catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      _initializing = null;
      Error.throwWithStackTrace(error, stackTrace);
    });
  }

  static Future<FlowDrift> _open(String? customPath) async {
    final String dbPath = customPath ?? await _defaultDatabasePath();

    final PowerSyncDatabase powerSync = PowerSyncDatabase(
      schema: flowSchema,
      path: dbPath,
    );
    await powerSync.initialize();

    // Local-only for Stage 1: deliberately NOT calling powerSync.connect().
    // The data lives in local SQLite until a backend connector is wired up.

    final FlowDatabase db = FlowDatabase(SqliteAsyncDriftConnection(powerSync));

    return _instance = FlowDrift._(powerSync, db);
  }

  static Future<String> _defaultDatabasePath() async {
    final Directory dir = await getApplicationSupportDirectory();
    return path.join(dir.path, "flow_powersync.db");
  }

  Future<void> close() async {
    await db.close();
    await powerSync.close();
    _instance = null;
    _initializing = null;
  }
}

class GDriveSyncService {
  static GDriveSyncService? _instance;

  factory GDriveSyncService() => _instance ??= GDriveSyncService._internal();

  GDriveSyncService._internal() {
    // Constructor
  }
}

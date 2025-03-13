import "package:icloud_storage_sync/icloud_storage_sync.dart";

class ICloudSyncService {
  static ICloudSyncService? _instance;
  static IcloudStorageSync? _plugin;

  factory ICloudSyncService() {
    if (_instance == null) {
      throw Exception("Failed to create ICloudSyncService");
    }

    return _instance!;
  }

  ICloudSyncService._internal() {
    // Constructor
  }

  static Future<void> initialize() {
    _plugin = IcloudStorageSync();
    
    _plugin!.gather(containerId: containerId)
  }
}

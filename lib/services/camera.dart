import "package:camera/camera.dart";

class CameraService {
  static CameraService? _instance;
  static List<CameraDescription>? cameras;

  static bool get initialized => _instance != null;

  factory CameraService() {
    if (_instance == null) {
      throw Exception("Failed to create CameraService");
    }

    return _instance!;
  }

  CameraService._internal();

  static Future<void> initialize() async {
    if (_instance != null) return;

    cameras = await availableCameras().catchError(
      (error) => const <CameraDescription>[],
    );
    _instance ??= CameraService._internal();
  }

  static Future<void> ensureInitialized() async {
    if (!initialized) {
      await CameraService.initialize();
    }
  }
}

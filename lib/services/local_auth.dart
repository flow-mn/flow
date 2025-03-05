import "dart:io";

import "package:flow/l10n/extensions.dart";
import "package:local_auth/local_auth.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("LocalAuthService");

class LocalAuthService {
  static late final LocalAuthentication _localAuth;
  static bool _available = false;
  static bool get available => _available;

  static LocalAuthService? _instance;

  factory LocalAuthService() {
    if (_instance == null) {
      _log.warning(
        "Tried to use without initializing, call LocalAuthService.initialize() first",
      );
      throw Exception(
        "Tried to use without initializing, call LocalAuthService.initialize() first",
      );
    }

    return _instance!;
  }

  static bool get platformSupported => Platform.isIOS || Platform.isAndroid;

  LocalAuthService._internal();

  static Future<void> initialize() async {
    if (_instance != null) {
      _log.warning("Already initialized, skipping");
      return;
    }

    _localAuth = LocalAuthentication();
    _instance = LocalAuthService._internal();
    _available =
        platformSupported &&
        await _localAuth
            .getAvailableBiometrics()
            .then((biometrics) {
              return biometrics.contains(BiometricType.fingerprint) ||
                  biometrics.contains(BiometricType.face) ||
                  biometrics.contains(BiometricType.strong);
            })
            .catchError((error) {
              _log.severe(
                "Error while checking biometrics availability: $error",
              );
              return false;
            });

    _log.fine("Local auth service initialized, available: $_available");
  }

  Future<bool> authenticate() async {
    _log.fine("Initiating authentication with biometrics");

    try {
      final bool success = await _localAuth.authenticate(
        localizedReason: "general.unlockToOpen".tr(),
        options: AuthenticationOptions(
          sensitiveTransaction: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      _log.fine("Authentication result: $success");

      return success;
    } catch (e) {
      _log.severe("Error while authenticating: $e");
      return false;
    }
  }
}

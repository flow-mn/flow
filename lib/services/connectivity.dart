import "dart:async";
import "dart:io";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/widgets.dart";

class ConnectivityService {
  static ConnectivityService? _instance;

  final ValueNotifier<bool> _onlineStatus = ValueNotifier<bool>(false);
  ValueNotifier<bool> get onlineStatus => _onlineStatus;

  bool get isOnline => _onlineStatus.value;

  factory ConnectivityService() {
    if (_instance == null) {
      throw Exception("Failed to create ConnectivityService");
    }

    return _instance!;
  }

  ConnectivityService._internal();

  static void initialize() {
    if (_instance != null) return;

    _instance = ConnectivityService._internal();

    unawaited(_instance!.checkOnlineStatus());

    Connectivity().onConnectivityChanged.listen(
      (_) => unawaited(_instance!.checkOnlineStatus()),
    );
  }

  static Future<bool> connectToGoogle() async =>
      await Socket.connect("google.com", 80, timeout: Duration(seconds: 5))
          .then((socket) {
            socket.destroy();
            return true;
          })
          .catchError((error) {
            return false;
          });

  /// Returns whether the device can connect to google.com over TCP.
  Future<bool> checkOnlineStatus() async {
    final bool online = await connectToGoogle();

    _onlineStatus.value = online;

    return online;
  }
}

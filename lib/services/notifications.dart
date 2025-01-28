import "dart:developer";
import "dart:io";

import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:flutter_timezone/flutter_timezone.dart";
import "package:moment_dart/moment_dart.dart";
import "package:timezone/timezone.dart";

import "package:timezone/data/latest.dart" as tz;

class NotificationsService {
  static NotificationsService? _instance;
  static final String _fallbackTimezone = "Etc/UTC";

  bool _ready = false;
  bool get ready => _ready;

  bool? _available;
  bool get available => _available == true;

  String? _timezone;

  final List<Function(NotificationResponse)> _registeredCallbacks = [];

  late final FlutterLocalNotificationsPlugin pluginInstance;

  factory NotificationsService() =>
      _instance ??= NotificationsService._internal();

  NotificationsService._internal();

  void addCallback(Function(NotificationResponse) callback) {
    _registeredCallbacks.add(callback);
  }

  void removeCallback(Function(NotificationResponse) callback) {
    _registeredCallbacks.remove(callback);
  }

  Future<void> initialize() async {
    try {
      _timezone = await FlutterTimezone.getLocalTimezone();
      print("_timezone: $_timezone");
    } catch (error) {
      _timezone = _fallbackTimezone;
      log("Failed to get local timezone", error: error);
    }

    try {
      tz.initializeTimeZones();
    } catch (e) {}

    try {
      pluginInstance = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings("ic_launcher");

      final DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();

      final LinuxInitializationSettings initializationSettingsLinux =
          LinuxInitializationSettings(defaultActionName: "Open notification");

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux,
      );

      _available = await pluginInstance.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      );
    } finally {
      _ready = true;
    }
  }

  void debugSchedule() async {
    final TZDateTime dateTime =
        _getTZDateTime(Moment.now().startOfNextMinute());

    try {
      await pluginInstance.zonedSchedule(
        0,
        "Test 1",
        null,
        dateTime,
        NotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: "/profile",
      );
    } catch (e) {
      log("Failed to schedule notification", error: e);
    }
  }

  void debugShow() async {
    try {
      await pluginInstance.show(
        0,
        "Test 1",
        null,
        NotificationDetails(),
        payload: "/profile",
      );
    } catch (e) {
      log("Failed to show notification", error: e);
    }
  }

  TZDateTime _getTZDateTime(DateTime dateTime) {
    late final Location location;

    try {
      location = getLocation(_timezone ?? _fallbackTimezone);
    } catch (e) {
      location = UTC;
    }

    return TZDateTime.from(dateTime, location);
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) {
    for (final callback in _registeredCallbacks) {
      try {
        callback(response);
      } catch (error) {
        log("Failed to call notification callback", error: error);
      }
    }
  }

  void requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          pluginInstance.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    } else if (Platform.isIOS || Platform.isMacOS) {
      await pluginInstance
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await pluginInstance
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }
}

import "dart:developer";
import "dart:io";

import "package:flow/entity/transaction.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:flutter_timezone/flutter_timezone.dart";
import "package:moment_dart/moment_dart.dart";
import "package:timezone/data/latest.dart" as tz;
import "package:timezone/timezone.dart";
import "package:window_manager/window_manager.dart";

class NotificationsService {
  static NotificationsService? _instance;
  static final String _fallbackTimezone = "Etc/UTC";

  static final String windowsNotificationGuid =
      "f342887a-2ea1-41b1-94cf-51d70a46ce73";

  bool _ready = false;
  bool get ready => _ready;

  bool? _available;
  bool get available => _available == true;

  String? _timezone;

  final List<Function(NotificationResponse)> _registeredCallbacks = [];

  late final FlutterLocalNotificationsPlugin pluginInstance;

  late final NotificationAppLaunchDetails? notificationAppLaunchDetails;

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
    } catch (error) {
      _timezone = _fallbackTimezone;
      log("[NotificationsService] Failed to get local timezone", error: error);
    }

    try {
      tz.initializeTimeZones();
    } catch (e) {
      // silent fail
    }

    try {
      pluginInstance = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings("@mipmap/ic_launcher");

      final DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        notificationCategories: [
          DarwinNotificationCategory("planned-transaction-reminder"),
        ],
      );

      final LinuxInitializationSettings initializationSettingsLinux =
          LinuxInitializationSettings(defaultActionName: "Open notification");

      final WindowsInitializationSettings initializationSettingsWindows =
          WindowsInitializationSettings(
        appName: "Flow",
        appUserModelId: "TODO @sadespresso",
        guid: windowsNotificationGuid,
      );

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux,
        windows: initializationSettingsWindows,
      );

      _available = await pluginInstance.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      );

      try {
        notificationAppLaunchDetails =
            await pluginInstance.getNotificationAppLaunchDetails();

        log("[NotificationsService] NotificationAppLaunchDetails: $notificationAppLaunchDetails");
      } catch (e) {
        notificationAppLaunchDetails = null;
        log(
          "[NotificationsService] NotificationAppLaunchDetails failed",
          error: e,
        );
      }
    } finally {
      _ready = true;
    }
  }

  /// Upon failure, returns an empty list
  Future<List<PendingNotificationRequest>> fetchAllNotification() async {
    try {
      return await pluginInstance.pendingNotificationRequests();
    } catch (e) {
      return <PendingNotificationRequest>[];
    }
  }

  Future<void> purgeNotificationsByIds(List<int> ids) async {
    for (final int id in ids) {
      try {
        await pluginInstance.cancel(id);
      } catch (e) {
        log(
          "[NotificationsService] Failed to cancel notification ($id)",
          error: e,
        );
      }
    }
  }

  Future<void> scheduleForPlannedTransaction(Transaction transaction) async {
    if (transaction.transactionDate.isBefore(DateTime.now())) {
      log("[NotificationsService] ignoring scheduling for past date");
      return;
    }

    final TZDateTime dateTime = _getTZDateTime(transaction.transactionDate);

    try {
      final NotificationDetails details = NotificationDetails(
        android: AndroidNotificationDetails(
          "planned-transaction-reminder",
          "Planned Transaction Reminder",
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.timeSensitive,
          categoryIdentifier: "planned-transaction-reminder",
        ),
        macOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.timeSensitive,
          categoryIdentifier: "planned-transaction-reminder",
        ),
        linux: LinuxNotificationDetails(
          icon: AssetsLinuxIcon("assets/images/flow.png"),
          urgency: LinuxNotificationUrgency.normal,
          category: LinuxNotificationCategory.imReceived,
          actions: [
            LinuxNotificationAction(
              key: "open",
              label: "Open notification",
            ),
          ],
        ),
        windows: WindowsNotificationDetails(),
      );

      await pluginInstance.zonedSchedule(
        transaction.id,
        transaction.title ?? "🚨",
        transaction.money.formatMoney(),
        dateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      log("[NotificationsService] Failed to schedule notification", error: e);
    }
  }

  void debugSchedule() async {
    final TZDateTime dateTime =
        _getTZDateTime(Moment.now().startOfNextMinute());

    try {
      await pluginInstance.zonedSchedule(
        51,
        "Test 1",
        null,
        dateTime,
        NotificationDetails(
          linux: LinuxNotificationDetails(
            icon: AssetsLinuxIcon("assets/images/flow.png"),
            urgency: LinuxNotificationUrgency.normal,
            category: LinuxNotificationCategory.imReceived,
            actions: [
              LinuxNotificationAction(
                key: "open",
                label: "Open notification",
              ),
            ],
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: "/profile",
      );
    } catch (e) {
      log("[NotificationsService] Failed to schedule notification", error: e);
    }
  }

  void debugShow() async {
    try {
      await pluginInstance.show(
        0,
        "Test 1",
        null,
        NotificationDetails(
          android: AndroidNotificationDetails(
            "default",
            "default",
            importance: Importance.max,
          ),
        ),
        payload: "/profile",
      );
    } catch (e) {
      log("[NotificationsService] Failed to show notification", error: e);
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
    try {
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        windowManager.isFocused().then((focused) {
          if (!focused) {
            windowManager.focus();
          }
        }).catchError((error) {
          log(
            "[NotificationsService] Failed to check window focus",
            error: error,
          );
        });
      }
    } catch (e) {
      log(
        "[NotificationsService] Failed to check/request window focus",
        error: e,
      );
    }

    for (final callback in _registeredCallbacks) {
      try {
        callback(response);
        log("response.actionId: ${response.actionId}, ${response.id}, $response");
      } catch (error) {
        log("[NotificationsService] Failed to call notification callback",
            error: error);
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

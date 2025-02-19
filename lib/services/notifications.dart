import "dart:developer";
import "dart:io";
import "dart:math" as math;

import "package:flow/data/flow_notification_payload.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/pending_transactions.dart";
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

  int _count = 0;

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
        final NotificationAppLaunchDetails? launchDetails =
            await pluginInstance.getNotificationAppLaunchDetails();

        notificationAppLaunchDetails =
            launchDetails?.didNotificationLaunchApp == true
                ? launchDetails
                : null;

        log(
          "[NotificationsService] NotificationAppLaunchDetails: $notificationAppLaunchDetails",
        );
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

    if (_available != true) return;

    if (PendingTransactionsLocalPreferences().notify.get()) {
      try {
        final bool? permissionGranted = await hasPermissions();

        if (permissionGranted == null) return;

        if (!permissionGranted) {
          requestPermissions();
        }
      } catch (e) {
        log(
          "[NotificationsService] Failed to check or request permissions",
          error: e,
        );
      }
    }

    _count = await fetchAllNotification()
        .then((x) => x.length)
        .catchError((error) => 0);
  }

  /// Upon failure, returns an empty list
  Future<List<PendingNotificationRequest>> fetchAllNotification() async {
    try {
      return await pluginInstance.pendingNotificationRequests();
    } catch (e) {
      return <PendingNotificationRequest>[];
    }
  }

  /// Upon failure, does nothing
  Future<void> cancelAllNotifications() async {
    try {
      return await pluginInstance.cancelAll();
    } catch (e) {
      // Silent fail
    }
  }

  Future<List<PendingNotificationRequest>> getSchedules() async {
    try {
      return await pluginInstance.pendingNotificationRequests();
    } catch (e) {
      return [];
    }
  }

  Future<void> scheduleForPlannedTransaction(
    Transaction transaction, [
    Duration? earlyReminder,
  ]) async {
    final Moment now = Moment.now();

    if (transaction.transactionDate.isBefore(now)) {
      log("[NotificationsService] ignoring scheduling for past date");
      return;
    }

    final TZDateTime dateTime = _getTZDateTime(
      earlyReminder == null
          ? transaction.transactionDate
          : transaction.transactionDate.subtract(earlyReminder),
    );

    try {
      final NotificationDetails details = NotificationDetails(
        android: AndroidNotificationDetails(
          "planned-transaction-reminder",
          "Planned Transaction Reminder",
          channelDescription: "Reminds you about a planned transaction",
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          styleInformation: DefaultStyleInformation(false, false),
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
            LinuxNotificationAction(key: "open", label: "Open notification"),
          ],
        ),
        windows: WindowsNotificationDetails(),
      );

      await pluginInstance.zonedSchedule(
        _count++,
        transaction.title ?? "transaction.fallbackTitle".tr(),
        "${transaction.money.formatMoney()}, ${now.from(now)}",
        dateTime,
        details,
        payload:
            FlowNotificationPayload(
              itemType: FlowNotificationPayloadItemType.transaction,
              id: transaction.id.toString(),
            ).serialized,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      log("[NotificationsService] Failed to schedule notification", error: e);
    }
  }

  void debugSchedule() async {
    final TZDateTime dateTime = _getTZDateTime(
      Moment.now().startOfNextMinute(),
    );

    try {
      await pluginInstance.zonedSchedule(
        math.Random().nextInt(10000) + 1,
        "Test 1",
        null,
        dateTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            "debug",
            "Debug",
            importance: Importance.max,
          ),
          linux: LinuxNotificationDetails(
            icon: AssetsLinuxIcon("assets/images/flow.png"),
            urgency: LinuxNotificationUrgency.normal,
            category: LinuxNotificationCategory.imReceived,
            actions: [
              LinuxNotificationAction(key: "open", label: "Open notification"),
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
            "debug",
            "Debug",
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
        windowManager
            .isFocused()
            .then((focused) {
              if (!focused) {
                windowManager.focus();
              }
            })
            .catchError((error) {
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
        log(
          "response.actionId: ${response.actionId}, ${response.id}, $response",
        );
      } catch (error) {
        log(
          "[NotificationsService] Failed to call notification callback",
          error: error,
        );
      }
    }
  }

  void requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          pluginInstance
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      await androidImplementation?.requestNotificationsPermission();
    } else if (Platform.isIOS || Platform.isMacOS) {
      await pluginInstance
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await pluginInstance
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<bool?> hasPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          pluginInstance
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      try {
        final bool? enabled =
            await androidImplementation?.areNotificationsEnabled();
        if (enabled != true) {
          return false;
        }
        final bool? canSchedule =
            await androidImplementation?.canScheduleExactNotifications();

        return canSchedule == true;
      } catch (e) {
        return false;
      }
    }
    if (Platform.isIOS) {
      final NotificationsEnabledOptions? permissions =
          await pluginInstance
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.checkPermissions();

      if (permissions == null || !permissions.isEnabled) {
        return false;
      }
      return true;
    }
    if (Platform.isMacOS) {
      final NotificationsEnabledOptions? permissions =
          await pluginInstance
              .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin
              >()
              ?.checkPermissions();

      if (permissions == null || !permissions.isEnabled) {
        return false;
      }
      return true;
    }
    return null;
  }
}

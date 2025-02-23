import "dart:async";
import "dart:io";
import "dart:math" as math;

import "package:flow/data/flow_notification_payload.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/pending_transactions.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:flutter_timezone/flutter_timezone.dart";
import "package:logging/logging.dart";
import "package:moment_dart/moment_dart.dart";
import "package:timezone/data/latest.dart" as tz;
import "package:timezone/timezone.dart";
import "package:window_manager/window_manager.dart";

final Logger _log = Logger("NotificationsService");

class NotificationsService {
  static NotificationsService? _instance;
  static final String _fallbackTimezone = "Etc/UTC";

  static final String windowsNotificationGuid =
      "f342887a-2ea1-41b1-94cf-51d70a46ce73";

  static bool get schedulingSupported =>
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

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
      _log.severe("Failed to get local timezone", error);
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
        if (Platform.isLinux) {
          throw Exception("Linux doesn't support notification app launch");
        }

        final NotificationAppLaunchDetails? launchDetails =
            await pluginInstance.getNotificationAppLaunchDetails();

        notificationAppLaunchDetails =
            launchDetails?.didNotificationLaunchApp == true
                ? launchDetails
                : null;
      } catch (e) {
        notificationAppLaunchDetails = null;
        _log.info("NotificationAppLaunchDetails failed", e);
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
        _log.warning("Failed to check or request permissions", e);
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
      _log.info("Ignoring scheduling for past date");
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
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      _log.warning("Failed to schedule notification", e);
    }
  }

  Future<void> clearDailyReminders() async {
    final List<PendingNotificationRequest> scheduledNotifications =
        await getSchedules();

    final List<PendingNotificationRequest> reminders =
        scheduledNotifications.where((x) {
          if (x.payload == null) return false;
          try {
            final FlowNotificationPayload parsedPayload =
                FlowNotificationPayload.parse(x.payload!);

            return parsedPayload.itemType ==
                FlowNotificationPayloadItemType.reminder;
          } catch (e) {
            return false;
          }
        }).toList();

    await Future.wait(
      reminders.map((reminder) async {
        try {
          await pluginInstance.cancel(reminder.id);
        } catch (e) {
          _log.warning("Failed to cancel reminder", e);
        }
      }),
    );
  }

  Future<void> scheduleDailyReminder(Duration time) async {
    await clearDailyReminders();

    if (!schedulingSupported) {
      _log.warning("Scheduling not supported on this platform");
      return;
    }

    final int h = time.abs().inHours;
    final int m = time.abs().inMinutes % 60;

    final int offset = math.Random().nextInt(7);

    for (int i = 0; i < 7; i++) {
      final TZDateTime dateTime = _getTZDateTime(
        Moment.startOfToday()
            .add(Duration(days: i))
            .copyWith(hour: h, minute: m),
      );

      if (dateTime.isBefore(Moment.now())) {
        _log.info("Ignoring scheduling for past date");
        continue;
      }

      try {
        final NotificationDetails details = NotificationDetails(
          android: AndroidNotificationDetails(
            "flow-daily-reminder",
            "Daily Reminder",
            channelDescription: "Reminds you to track your expenses",
            importance: Importance.max,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
            styleInformation: DefaultStyleInformation(false, false),
          ),
          iOS: DarwinNotificationDetails(
            interruptionLevel: InterruptionLevel.timeSensitive,
            categoryIdentifier: "flow-daily-reminder",
          ),
          macOS: DarwinNotificationDetails(
            interruptionLevel: InterruptionLevel.timeSensitive,
            categoryIdentifier: "flow-daily-reminder",
          ),
          linux: LinuxNotificationDetails(
            icon: AssetsLinuxIcon("assets/images/flow.png"),
            urgency: LinuxNotificationUrgency.normal,
            category: LinuxNotificationCategory.imReceived,
            actions: [LinuxNotificationAction(key: "open", label: "Open Flow")],
          ),
          windows: WindowsNotificationDetails(),
        );

        await pluginInstance.zonedSchedule(
          _count++,
          "notifications.reminderText#${1 + ((i + offset) % 7)}".tr(),
          null,
          dateTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } catch (e) {
        _log.warning("Failed to schedule notification", e);
      }
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
      _log.warning("Failed to schedule notification", e);
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
      _log.warning("Failed to show notification", e);
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
              _log.warning("Failed to check window focus", error);
            });
      }
    } catch (e) {
      _log.warning("Failed to check/request window focus", e);
    }

    for (final callback in _registeredCallbacks) {
      try {
        callback(response);
      } catch (error) {
        _log.warning("Failed to call notification callback", error);
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

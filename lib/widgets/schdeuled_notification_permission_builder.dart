import "dart:io";

import "package:flow/services/notifications.dart";
import "package:flutter/widgets.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:permission_handler/permission_handler.dart";

class SchdeuledNotificationPermission {
  final bool hasNotificationPermission;
  final bool hasAlarmPermission;

  bool get hasAllPermissions => hasNotificationPermission && hasAlarmPermission;

  const SchdeuledNotificationPermission({
    required this.hasNotificationPermission,
    required this.hasAlarmPermission,
  });
}

class SchdeuledNotificationPermissionBuilder extends StatefulWidget {
  final Widget Function(
    BuildContext context,
    SchdeuledNotificationPermission permission,
    Widget? child,
  )
  builder;

  final Widget? child;

  const SchdeuledNotificationPermissionBuilder({
    super.key,
    required this.builder,
    this.child,
  });

  @override
  State<SchdeuledNotificationPermissionBuilder> createState() =>
      _SchdeuledNotificationPermissionBuilderState();
}

class _SchdeuledNotificationPermissionBuilderState
    extends State<SchdeuledNotificationPermissionBuilder>
    with WidgetsBindingObserver {
  bool _hasNotificationPermission = false;
  bool _hasAlarmPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _checkAlarmPermission();
    _checkNotificationPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == .resumed) {
      _checkAlarmPermission();
      _checkNotificationPermission();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(
    context,
    SchdeuledNotificationPermission(
      hasNotificationPermission: _hasNotificationPermission,
      hasAlarmPermission: _hasAlarmPermission,
    ),
    widget.child,
  );

  Future<void> _checkNotificationPermission() async {
    try {
      _hasNotificationPermission = await Permission.notification.isGranted;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _checkAlarmPermission() async {
    try {
      if (Platform.isLinux) {
        _hasAlarmPermission = false;
      } else if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            NotificationsService().pluginInstance
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();
        _hasAlarmPermission =
            await androidImplementation?.canScheduleExactNotifications() ??
            false;
      } else {
        _hasAlarmPermission = await Permission.scheduleExactAlarm.isGranted;
      }
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }
}

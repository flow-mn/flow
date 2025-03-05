import "package:flow/services/notifications.dart";
import "package:flutter/material.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";

class DebugScheduledNotificationsPage extends StatefulWidget {
  const DebugScheduledNotificationsPage({super.key});

  @override
  State<DebugScheduledNotificationsPage> createState() =>
      _DebugScheduledNotificationsPageState();
}

class _DebugScheduledNotificationsPageState
    extends State<DebugScheduledNotificationsPage> {
  late final Future<List<PendingNotificationRequest>> _scheduledNotifications;

  @override
  void initState() {
    super.initState();
    _scheduledNotifications = NotificationsService().getSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scheduled Notifications")),
      body: FutureBuilder(
        future: _scheduledNotifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final notifications =
              snapshot.data as List<PendingNotificationRequest>;

          if (notifications.isEmpty) {
            return const Center(child: Text("No scheduled notifications"));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text(notification.title ?? "** Untitled"),
                subtitle: Text(notification.body ?? "** Unbodied"),
              );
            },
          );
        },
      ),
    );
  }
}

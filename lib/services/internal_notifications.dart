import "package:flow/data/internal_nofications/internal_notification.dart";

class InternalNotificationsService {
  static InternalNotificationsService? _instance;

  final List<InternalNotification> _notifications = [];

  factory InternalNotificationsService() =>
      _instance ??= InternalNotificationsService._internal();

  void add(InternalNotification notification) {
    _notifications.add(notification);
  }

  /// Returns the most relevant notification, and deletes it from the pool
  InternalNotification? consume() {
    if (_notifications.isEmpty) {
      return null;
    }
    return null;
  }

  InternalNotificationsService._internal() {
    // Constructor
  }
}

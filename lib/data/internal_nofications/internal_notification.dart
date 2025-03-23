import "package:flow/data/flow_icon.dart";
import "package:flow/entity/backup_entry.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:simple_icons/simple_icons.dart";

enum InternalNotificationPriority {
  low(0),
  medium(10),
  high(20),
  critical(30);

  final int value;

  const InternalNotificationPriority(this.value);
}

abstract class InternalNotification<T> {
  FlowIconData get icon;

  T get payload;

  /// Higher priority notifications will be shown first
  InternalNotificationPriority get priority;
}

class StarOnGitHub extends InternalNotification<Null> {
  @override
  final FlowIconData icon = const IconFlowIcon(SimpleIcons.github);

  @override
  final Null payload = null;

  @override
  final InternalNotificationPriority priority =
      InternalNotificationPriority.low;
}

class RateApp extends InternalNotification<bool> {
  @override
  final FlowIconData icon = const IconFlowIcon(Symbols.star_rounded);

  /// Whether the app can open in-app sheet
  @override
  final bool payload;

  @override
  final InternalNotificationPriority priority =
      InternalNotificationPriority.medium;

  RateApp({required this.payload});
}

class AutoBackupReminder extends InternalNotification<BackupEntry?> {
  @override
  final FlowIconData icon = const IconFlowIcon(Symbols.cloud_upload);

  @override
  final BackupEntry? payload;

  @override
  final InternalNotificationPriority priority =
      InternalNotificationPriority.high;

  AutoBackupReminder({required this.payload});
}

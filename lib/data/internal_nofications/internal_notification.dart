import "package:flow/data/flow_icon.dart";
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

class RateApp extends InternalNotification<Null> {
  @override
  final FlowIconData icon = const IconFlowIcon(Symbols.star_rounded);

  @override
  final Null payload = null;

  @override
  final InternalNotificationPriority priority =
      InternalNotificationPriority.medium;
}

class AutoBackupReminder extends InternalNotification<String> {
  @override
  final FlowIconData icon = const IconFlowIcon(Symbols.cloud_upload);

  /// Path to the generated backup file
  @override
  final String payload;

  @override
  final InternalNotificationPriority priority =
      InternalNotificationPriority.high;

  AutoBackupReminder({required this.payload});
}

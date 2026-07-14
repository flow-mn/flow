import "package:flow/data/budget_progress.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/entity/backup_entry.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:simple_icons_flow/simple_icons_flow.dart";

enum ActionableNotificationPriority {
  low(0),
  medium(10),
  mediumHigh(15),
  high(20),
  critical(30);

  final int value;

  const ActionableNotificationPriority(this.value);
}

abstract class ActionableNotification<T> {
  FlowIconData get icon;

  T get payload;

  /// Higher priority notifications will be shown first
  ActionableNotificationPriority get priority;
}

class TurnOnICloudNotification extends ActionableNotification<Null> {
  @override
  final FlowIconData icon = const IconFlowIcon(SimpleIcons.icloud);

  @override
  final Null payload = null;

  @override
  final ActionableNotificationPriority priority =
      ActionableNotificationPriority.medium;
}

class StarOnGitHub extends ActionableNotification<Null> {
  @override
  final FlowIconData icon = const IconFlowIcon(SimpleIcons.github);

  @override
  final Null payload = null;

  @override
  final ActionableNotificationPriority priority =
      ActionableNotificationPriority.low;
}

class RateApp extends ActionableNotification<bool> {
  @override
  final FlowIconData icon = const IconFlowIcon(Symbols.star_rounded);

  /// Whether the app can open in-app sheet
  @override
  final bool payload;

  @override
  final ActionableNotificationPriority priority =
      ActionableNotificationPriority.medium;

  RateApp({required this.payload});
}

class BudgetAlert extends ActionableNotification<BudgetProgress> {
  @override
  final FlowIconData icon = const IconFlowIcon(Symbols.money_bag_rounded);

  @override
  final BudgetProgress payload;

  @override
  final ActionableNotificationPriority priority =
      ActionableNotificationPriority.mediumHigh;

  BudgetAlert({required this.payload});
}

class AutoBackupReminder extends ActionableNotification<BackupEntry?> {
  @override
  final FlowIconData icon = const IconFlowIcon(Symbols.cloud_upload);

  @override
  final BackupEntry? payload;

  @override
  final ActionableNotificationPriority priority =
      ActionableNotificationPriority.high;

  AutoBackupReminder({required this.payload});
}

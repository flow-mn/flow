import "package:flow/entity/account.dart";
import "package:flow/entity/goal.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/notifications.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("GoalsService");

class GoalsService {
  static GoalsService? _instance;

  // Track which goals have already been notified to avoid duplicate notifications
  final Set<int> _notifiedGoals = {};

  factory GoalsService() => _instance ??= GoalsService._internal();

  GoalsService._internal() {
    // Load previously notified goals
    _notifiedGoals.addAll(_getNotifiedGoalsFromPrefs());
    
    // Watch for transaction changes and check goals
    ObjectBox().box<Transaction>().query().watch().listen((_) {
      _checkAllGoalsForAchievement();
    });
  }

  Future<Goal?> getOne(int id) async {
    return ObjectBox().box<Goal>().getAsync(id);
  }

  Future<List<Goal>> getAll() async {
    return ObjectBox().box<Goal>().getAllAsync();
  }

  Future<List<Goal>> getActiveGoals() async {
    return ObjectBox().box<Goal>().getAllAsync();
  }

  Future<Goal?> findOne(dynamic identifier) async {
    if (identifier is int) {
      return await getOne(identifier);
    }

    if (identifier case String uuid) {
      final q = ObjectBox()
          .box<Goal>()
          .query(Goal_.uuid.equals(uuid))
          .build();

      final Goal? result = await q.findFirstAsync();

      q.close();
      return result;
    }

    return null;
  }

  /// Check if account balance has reached the goal target
  /// Returns true if goal was achieved
  bool checkGoalAchievement(Goal goal, Account account) {
    if (goal.account.targetId != account.id) {
      return false;
    }

    final currentBalance = account.balance.amount;
    final targetBalance = goal.targetBalance;

    // Check if target is reached
    // For positive goals: current >= target
    // For negative goals: current <= target (e.g., credit card limit)
    if (targetBalance >= 0) {
      return currentBalance >= targetBalance;
    } else {
      return currentBalance <= targetBalance;
    }
  }

  /// Check all active goals and notify if any are achieved
  Future<void> _checkAllGoalsForAchievement() async {
    try {
      final List<Goal> goals = await getActiveGoals();
      
      for (final goal in goals) {
        // Skip if already notified
        if (_notifiedGoals.contains(goal.id)) {
          continue;
        }

        final Account? account = goal.account.target;
        if (account == null) {
          continue;
        }

        if (checkGoalAchievement(goal, account)) {
          await _showGoalAchievedNotification(goal, account);
          _notifiedGoals.add(goal.id);
          
          // Persist notification state
          await _saveNotifiedGoalState(goal.id);
        }
      }
    } catch (e) {
      _log.warning("Error checking goals for achievement", e);
    }
  }

  /// Save that a goal has been notified
  Future<void> _saveNotifiedGoalState(int goalId) async {
    final Set<int> notified = _getNotifiedGoalsFromPrefs();
    notified.add(goalId);
    await LocalPreferences().notifiedGoals.set(notified.toList());
  }

  /// Load notified goals from preferences
  Set<int> _getNotifiedGoalsFromPrefs() {
    final List<int>? notified = LocalPreferences().notifiedGoals.get();
    return notified?.toSet() ?? {};
  }

  /// Reset notification state for a goal (e.g., when goal is updated)
  Future<void> resetGoalNotification(int goalId) async {
    _notifiedGoals.remove(goalId);
    final Set<int> notified = _getNotifiedGoalsFromPrefs();
    notified.remove(goalId);
    await LocalPreferences().notifiedGoals.set(notified.toList());
  }

  /// Update or create a goal
  /// Automatically resets notification state if target balance changes
  Future<int> upsertGoal(Goal goal) async {
    final Goal? existing = goal.id > 0 
        ? await ObjectBox().box<Goal>().getAsync(goal.id)
        : null;

    // Reset notification if target balance changed
    if (existing != null && existing.targetBalance != goal.targetBalance) {
      await resetGoalNotification(goal.id);
    }

    return await ObjectBox().box<Goal>().putAsync(goal);
  }

  /// Delete a goal and clean up its notification state
  Future<bool> deleteGoal(int goalId) async {
    await resetGoalNotification(goalId);
    return ObjectBox().box<Goal>().remove(goalId);
  }

  /// Manually check all goals for achievement
  /// Useful for debugging or manual triggers
  Future<void> checkGoalsNow() async {
    await _checkAllGoalsForAchievement();
  }

  /// Show a notification when a goal is achieved
  Future<void> _showGoalAchievedNotification(
    Goal goal,
    Account account,
  ) async {
    final notificationService = NotificationsService();

    if (!notificationService.available) {
      _log.info("Notifications not available, skipping goal notification");
      return;
    }

    try {
      final String title = "Goal Achieved! 🎉";
      final String body = "${goal.name}: ${account.name} reached ${account.balance.formatMoney()}";

      await notificationService.pluginInstance.show(
        goal.id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            "goal-achievement",
            "Goal Achievement",
            channelDescription: "Notifies you when a goal is achieved",
            importance: Importance.max,
            priority: Priority.high,
            category: AndroidNotificationCategory.status,
          ),
          iOS: DarwinNotificationDetails(
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
          macOS: DarwinNotificationDetails(
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
          linux: LinuxNotificationDetails(
            urgency: LinuxNotificationUrgency.normal,
          ),
        ),
      );

      _log.info("Showed goal achievement notification for goal: ${goal.name}");
    } catch (e) {
      _log.warning("Failed to show goal achievement notification", e);
    }
  }
}

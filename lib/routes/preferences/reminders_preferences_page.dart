import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/notifications.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/notifications_permission_missing_reminder.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class RemindersPreferencesPage extends StatefulWidget {
  const RemindersPreferencesPage({super.key});

  @override
  State<RemindersPreferencesPage> createState() =>
      _RemindersPreferencesPageState();
}

class _RemindersPreferencesPageState extends State<RemindersPreferencesPage> {
  bool? hasNotificationsPermissions;

  @override
  void initState() {
    super.initState();

    NotificationsService().hasPermissions().then((value) {
      hasNotificationsPermissions = value;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final Duration? remindDailyAt = UserPreferencesService().remindDailyAt;
    final bool enabled = remindDailyAt != null;

    final int h = remindDailyAt?.inHours ?? 0;
    final int m = (remindDailyAt?.inMinutes ?? 0) % 60;

    final String hhmm = DateTime(1970, 1, 1, h, m).toMoment().LT;

    return Scaffold(
      appBar: AppBar(title: Text("preferences.reminders".t(context))),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!NotificationsService.schedulingSupported) ...[
                const SizedBox(height: 16.0),
                Frame(
                  child: InfoText(
                    child: Text(
                      "preferences.reminders.unsupportedPlatform".t(context),
                    ),
                  ),
                ),
              ],
              if (NotificationsService.schedulingSupported &&
                  hasNotificationsPermissions == false) ...[
                const SizedBox(height: 16.0),
                NotificationPermissionMissingReminder(),
              ],
              if (flowDebugMode &&
                  !NotificationsService.schedulingSupported) ...[
                const SizedBox(height: 16.0),
                Frame(
                  child: InfoText(
                    child: Text(
                      "You're seeing this section because you're in debug mode, and it still wouldn't work on this platform.",
                    ),
                  ),
                ),
              ],
              if (flowDebugMode ||
                  NotificationsService.schedulingSupported) ...[
                const SizedBox(height: 16.0),
                SwitchListTile(
                  title: Text("preferences.reminders.remindDaily".t(context)),
                  subtitle: Text(
                    "preferences.reminders.remindDaily.description".t(context),
                  ),
                  value: enabled,
                  onChanged: toggleRemindDaily,
                ),
                if (enabled) ...[
                  const SizedBox(height: 16.0),
                  ListHeader(
                    "preferences.reminders.remindDaily.time".t(context),
                  ),
                  const SizedBox(height: 8.0),
                  Frame(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8.0),
                      onTap: () => updateRemindDailyAt(h, m),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          hhmm,
                          style: context.textTheme.displayMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Frame(
                    child: InfoText(
                      child: Text(
                        "preferences.reminders.remindDaily.expiryWarning".t(
                          context,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16.0),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void toggleRemindDaily(bool enabled) {
    if (enabled) {
      UserPreferencesService().remindDailyAt = const Duration(hours: 20);
    } else {
      UserPreferencesService().remindDailyAt = null;
    }

    setState(() {});
  }

  void updateRemindDailyAt([int? h, int? m]) async {
    final TimeOfDay initialTime =
        (h != null && m != null)
            ? TimeOfDay(hour: h, minute: m)
            : TimeOfDay.now();

    final TimeOfDay? newTod = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (newTod == null || !mounted) {
      return;
    }

    UserPreferencesService().remindDailyAt = Duration(
      hours: newTod.hour,
      minutes: newTod.minute,
    );

    setState(() {});
  }
}

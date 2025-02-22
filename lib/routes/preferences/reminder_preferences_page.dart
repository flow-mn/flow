import "package:flow/l10n/extensions.dart";
import "package:flow/services/notifications.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class ReminderPreferencesPage extends StatefulWidget {
  const ReminderPreferencesPage({super.key});

  @override
  State<ReminderPreferencesPage> createState() =>
      _ReminderPreferencesPageState();
}

class _ReminderPreferencesPageState extends State<ReminderPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final Duration? remindDailyAt = UserPreferencesService().remindDailyAt;
    final bool enabled = remindDailyAt != null;

    final int h = remindDailyAt?.inHours ?? 0;
    final int m = remindDailyAt?.inMinutes.remainder(60).toInt() ?? 0;

    final String hhmm = DateTime(1970, 1, 1, h, m).toMoment().LT;

    return Scaffold(
      appBar: AppBar(title: Text("preferences.dailyReminder".t(context))),
      body: SafeArea(
        child: SingleChildScrollView(
          child:
              NotificationsService.schedulingSupported
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: InfoText(
                          child: Text(
                            "preferences.dailyReminder.description".t(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      SwitchListTile(
                        value: enabled,
                        onChanged: toggleRemindDaily,
                      ),
                      const SizedBox(height: 16.0),
                      InkWell(
                        child: Text(
                          hhmm,
                          style: context.textTheme.displaySmall,
                        ),
                      ),
                    ],
                  )
                  : Column(
                    children: [
                      const SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: InfoText(
                          child: Text(
                            "preferences.dailyReminder.unsupportedPlatform".t(
                              context,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
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

    if (newTod == null) {
      return;
    }

    UserPreferencesService().remindDailyAt = Duration(
      hours: newTod.hour,
      minutes: newTod.minute,
    );
  }
}

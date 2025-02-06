import "package:flow/l10n/extensions.dart";
import "package:flow/prefs.dart";
import "package:flow/prefs/pending_transactions.dart";
import "package:flow/services/notifications.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class PendingTransactionPreferencesPage extends StatefulWidget {
  const PendingTransactionPreferencesPage({super.key});

  @override
  State<PendingTransactionPreferencesPage> createState() =>
      _PendingTransactionPreferencesPageState();
}

class _PendingTransactionPreferencesPageState
    extends State<PendingTransactionPreferencesPage> {
  late final Future<bool?> _notificationsPermissionGranted;

  @override
  void initState() {
    super.initState();

    _notificationsPermissionGranted = NotificationsService().hasPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final int pendingTransactionsHomeTimeframe =
        LocalPreferences().pendingTransactions.homeTimeframe.get() ??
            PendingTransactionsLocalPreferences.homeTimeframeDefault;
    final bool requirePendingTransactionConfrimation =
        LocalPreferences().requirePendingTransactionConfrimation.get();
    final bool pendingTransactionsUpdateDateUponConfirmation =
        LocalPreferences().pendingTransactions.updateDateUponConfirmation.get();
    final bool notify = LocalPreferences().pendingTransactions.notify.get();
    final int? earlyReminderInSeconds =
        LocalPreferences().pendingTransactions.earlyReminderInSeconds.get();

    return Scaffold(
      appBar: AppBar(
        title: Text("preferences.pendingTransactions".t(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: InfoText(
                  child: Text(
                    "preferences.pendingTransactions.requireConfirmation.description"
                        .t(context),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ListHeader(
                "preferences.pendingTransactions.homeTimeframe".t(context),
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children: [1, 2, 3, 5, 7, 14, 30]
                      .map(
                        (value) => FilterChip(
                          showCheckmark: false,
                          key: ValueKey(value),
                          label: Text(
                            "general.nextNDays".t(context, value),
                          ),
                          onSelected: (bool selected) => selected
                              ? updatePendingTransactionsHomeTimeframe(value)
                              : null,
                          selected: value == pendingTransactionsHomeTimeframe,
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16.0),
              CheckboxListTile.adaptive(
                title: Text(
                  "preferences.pendingTransactions.requireConfirmation"
                      .t(context),
                ),
                value: requirePendingTransactionConfrimation,
                onChanged: updateRequirePendingTransactionConfrimation,
              ),
              if (requirePendingTransactionConfrimation) ...[
                CheckboxListTile.adaptive(
                  title: Text(
                    "preferences.pendingTransactions.updateDateUponConfirmation"
                        .t(context),
                  ),
                  subtitle: Text(
                    "preferences.pendingTransactions.updateDateUponConfirmation.description"
                        .t(context),
                  ),
                  value: pendingTransactionsUpdateDateUponConfirmation,
                  onChanged: updatePendingTransactionsConfirmationDate,
                ),
                FutureBuilder(
                  future: _notificationsPermissionGranted,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.none ||
                        snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.error != null) {
                      return const SizedBox();
                    }

                    final bool notificationsPermissionGranted =
                        snapshot.data != false;
                    final bool showSchedulingUnsupportedNotice =
                        snapshot.data == null;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile.adaptive(
                          title: Text(
                            "preferences.pendingTransactions.notify".t(context),
                          ),
                          enabled: notificationsPermissionGranted,
                          value: notificationsPermissionGranted && notify,
                          onChanged: updateNotify,
                        ),
                        if (!notificationsPermissionGranted) ...[
                          const SizedBox(height: 8.8),
                          Frame(
                            child: InfoText(
                              icon: Symbols.warning_rounded,
                              child: Text(
                                "notifications.permissionNotGranted".t(context),
                              ),
                            ),
                          ),
                        ],
                        if (!showSchedulingUnsupportedNotice) ...[
                          const SizedBox(height: 8.8),
                          Frame(
                            child: InfoText(
                              child: Text(
                                "preferences.pendingTransactions.notify.schedulingUnsupported"
                                    .t(context),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16.0),
                        if (!showSchedulingUnsupportedNotice &&
                            notify &&
                            notificationsPermissionGranted) ...[
                          ListHeader(
                            "preferences.pendingTransactions.notify.earlyReminder"
                                .t(context),
                          ),
                          const SizedBox(height: 8.0),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Wrap(
                              spacing: 12.0,
                              runSpacing: 8.0,
                              children: [
                                null,
                                Duration(minutes: 5),
                                Duration(minutes: 15),
                                Duration(minutes: 30),
                                Duration(hours: 1),
                                Duration(hours: 2),
                                Duration(hours: 6),
                                Duration(hours: 12),
                                Duration(days: 1),
                                Duration(days: 2),
                                Duration(days: 3),
                                Duration(days: 7),
                              ]
                                  .map(
                                    (value) => FilterChip(
                                      showCheckmark: false,
                                      key: ValueKey(value),
                                      label: Text(
                                        value?.toDurationString(
                                              dropPrefixOrSuffix: true,
                                            ) ??
                                            "preferences.pendingTransactions.notify.earlyReminder.none"
                                                .t(context),
                                      ),
                                      onSelected: (bool selected) => selected
                                          ? updateEarlyReminderInSeconds(value)
                                          : null,
                                      selected: (value?.inSeconds ?? 0) ==
                                          (earlyReminderInSeconds ?? 0),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void updatePendingTransactionsHomeTimeframe(int days) async {
    await LocalPreferences().pendingTransactions.homeTimeframe.set(days);

    if (mounted) setState(() {});
  }

  void updateEarlyReminderInSeconds(Duration? duration) async {
    final int? value = duration?.inSeconds;

    if (value == null) {
      await LocalPreferences()
          .pendingTransactions
          .earlyReminderInSeconds
          .remove();
    } else {
      await LocalPreferences()
          .pendingTransactions
          .earlyReminderInSeconds
          .set(value);
    }

    if (mounted) setState(() {});
  }

  void updateRequirePendingTransactionConfrimation(
    bool? requirePendingTransactionConfrimation,
  ) async {
    if (requirePendingTransactionConfrimation == null) return;

    await LocalPreferences()
        .requirePendingTransactionConfrimation
        .set(requirePendingTransactionConfrimation);

    if (mounted) setState(() {});
  }

  void updatePendingTransactionsConfirmationDate(
    bool? newValue,
  ) async {
    if (newValue == null) return;

    await LocalPreferences()
        .pendingTransactions
        .updateDateUponConfirmation
        .set(newValue);

    if (mounted) setState(() {});
  }

  void updateNotify(
    bool? newValue,
  ) async {
    if (newValue == null) return;

    await LocalPreferences().pendingTransactions.notify.set(newValue);

    if (mounted) setState(() {});
  }
}

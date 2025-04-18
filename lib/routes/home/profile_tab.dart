import "dart:async";

import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/icloud_sync.dart";
import "package:flow/services/notifications.dart";
import "package:flow/services/transactions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/home/preferences/profile_card.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:simple_icons/simple_icons.dart";

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _debugDbBusy = false;
  bool _debugPrefsBusy = false;
  bool _debugICloudBusy = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24.0),
          const Center(child: ProfileCard()),
          const SizedBox(height: 24.0),
          ListTile(
            title: Text("accounts".t(context)),
            leading: const Icon(Symbols.wallet_rounded),
            onTap: () => context.push("/accounts"),
          ),
          ListTile(
            title: Text("categories".t(context)),
            leading: const Icon(Symbols.category_rounded),
            onTap: () => context.push("/categories"),
          ),
          ListTile(
            title: Text("preferences.transactions.pending".t(context)),
            leading: const Icon(Symbols.search_activity_rounded),
            onTap: () => context.push("/transactions/pending"),
          ),
          ListTile(
            title: Text("transaction.deleted".t(context)),
            leading: const Icon(Symbols.delete_rounded),
            onTap: () => context.push("/transactions/deleted"),
          ),
          ListTile(
            title: Text("tabs.profile.preferences".t(context)),
            leading: const Icon(Symbols.settings_rounded),
            onTap: () => context.push("/preferences"),
          ),
          ListTile(
            title: Text("tabs.profile.backup".t(context)),
            leading: const Icon(Symbols.hard_drive_rounded),
            onTap: () => context.push("/exportOptions"),
          ),
          ListTile(
            title: Text("tabs.profile.import".t(context)),
            leading: const Icon(Symbols.restore_page_rounded),
            onTap: () => context.push("/import"),
          ),
          const SizedBox(height: 32.0),
          ListHeader("tabs.profile.community".t(context)),
          ListTile(
            title: Text("tabs.profile.joinDiscord".t(context)),
            leading: const Icon(SimpleIcons.discord),
            onTap: () => openUrl(discordInviteLink),
          ),
          ListTile(
            title: Text("tabs.profile.support".t(context)),
            leading: const Icon(Symbols.favorite_rounded),
            onTap: () => context.push("/support"),
          ),
          ListTile(
            title: Text("contributors".t(context)),
            leading: const Icon(Symbols.groups_rounded),
            onTap: () => context.push("/community/contributors"),
          ),
          Builder(
            builder:
                (context) => ListTile(
                  title: Text("tabs.profile.recommend".t(context)),
                  leading: const Icon(Symbols.share_rounded),
                  onTap: () => context.showUriShareSheet(uri: website),
                ),
          ),
          ListTile(
            title: Text("visitGitHubRepo".t(context)),
            leading: const Icon(SimpleIcons.github),
            onTap: () => openUrl(flowGitHubRepoLink),
          ),
          if (flowDebugMode) ...[
            const SizedBox(height: 32.0),
            const ListHeader("Debug options"),
            ListTile(
              title: const Text("Theme test page"),
              leading: const Icon(Symbols.palette_rounded),
              onTap: () => context.push("/_debug/theme"),
            ),
            ListTile(
              title: const Text("View scheduled notifications"),
              leading: const Icon(Symbols.notifications_rounded),
              onTap: () => context.push("/_debug/scheduledNotifications"),
            ),
            ListTile(
              title: const Text("ICloud debug explorer"),
              leading: const Icon(Symbols.cloud_rounded),
              onTap: () => context.push("/_debug/iCloud"),
            ),
            ListTile(
              title: const Text("Schedule debug notification"),
              leading: const Icon(Symbols.notification_add_rounded),
              onTap: () {
                NotificationsService()
                    .debugSchedule(Moment.now().startOfNextMinute())
                    .then((_) {
                      if (context.mounted) {
                        context.showToast(
                          text:
                              "Debug notification scheduled at the start of next minute",
                        );
                      }
                    });
              },
            ),
            ListTile(
              title: const Text("Show debug notification"),
              leading: const Icon(Symbols.notifications_rounded),
              onTap: () => NotificationsService().debugShow(),
              onLongPress:
                  () => Future.delayed(
                    const Duration(seconds: 3),
                    () => NotificationsService().debugShow(),
                  ),
            ),
            ListTile(
              title: const Text("Clear exchange rates cache"),
              onTap: () => clearExchangeRatesCache(),
              leading: const Icon(Symbols.adb_rounded),
            ),
            ListTile(
              title: const Text("Populate objectbox"),
              leading: const Icon(Symbols.adb_rounded),
              onTap: () => ObjectBox().createAndPutDebugData(),
            ),
            ListTile(
              title: Text(
                _debugDbBusy ? "Clearing database" : "Clear objectbox",
              ),
              onTap: () => resetDatabase(),
              leading: const Icon(Symbols.adb_rounded),
            ),
            ListTile(
              title: Text("Clear Shared Preferences"),
              onTap: () => resetPrefs(),
              leading: const Icon(Symbols.adb_rounded),
            ),
            ListTile(
              title: Text("Purge iCloud debug folder"),
              onTap: () => debugPurgeICloud(),
              leading: const Icon(Symbols.adb_rounded),
            ),
            ListTile(
              title: const Text("Jump to setup page"),
              onTap: () => context.pushReplacement("/setup"),
              leading: const Icon(Symbols.settings_rounded),
            ),
          ],
          const SizedBox(height: 64.0),
          Center(
            child: Text("v$appVersion", style: context.textTheme.labelSmall),
          ),
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(8.0),
              onTap: () => openUrl(maintainerGitHubLink),
              child: Opacity(
                opacity: 0.5,
                child: Text(
                  "tabs.profile.withLoveFromTheCreator".t(context),
                  style: context.textTheme.labelSmall,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          const SizedBox(height: 96.0),
        ],
      ),
    );
  }

  void resetDatabase() async {
    if (_debugDbBusy) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("[dev] Reset database?"),
            actions: [
              Button(
                onTap: () => context.pop(true),
                child: const Text("Confirm delete"),
              ),
              Button(
                onTap: () => context.pop(false),
                child: const Text("Cancel"),
              ),
            ],
          ),
    );

    setState(() {
      _debugDbBusy = true;
    });

    TransactionsService().pauseListeners();

    try {
      if (confirm == true) {
        await ObjectBox().eraseMainData();
      }
    } finally {
      TransactionsService().resumeListeners();

      _debugDbBusy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void debugPurgeICloud() async {
    if (_debugICloudBusy) return;
    setState(() {
      _debugICloudBusy = true;
    });
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("[dev] Purge iCloud debug folder?"),
            actions: [
              Button(
                onTap: () => context.pop(true),
                child: const Text("Confirm delete"),
              ),
              Button(
                onTap: () => context.pop(false),
                child: const Text("Cancel"),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await ICloudSyncService().debugPurge();
    } finally {
      _debugICloudBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void resetPrefs() async {
    if (_debugPrefsBusy) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("[dev] Clear Shared Preferences?"),
            actions: [
              Button(
                onTap: () => context.pop(true),
                child: const Text("Confirm clear"),
              ),
              Button(
                onTap: () => context.pop(false),
                child: const Text("Cancel"),
              ),
            ],
          ),
    );

    setState(() {
      _debugPrefsBusy = true;
    });

    try {
      if (confirm == true) {
        final instanceAvecCache = await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(),
        );
        await instanceAvecCache.clear();
      }
    } finally {
      _debugPrefsBusy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void clearExchangeRatesCache() {
    ExchangeRatesService().debugClearCache();
  }
}

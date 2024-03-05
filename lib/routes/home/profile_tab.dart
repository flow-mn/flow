import 'package:flow/constants.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/sync/import.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/toast.dart';
import 'package:flow/utils/utils.dart';
import 'package:flow/widgets/general/button.dart';
import 'package:flow/widgets/general/list_header.dart';
import 'package:flow/widgets/home/prefs/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:simple_icons/simple_icons.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _debugDbBusy = false;

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
            title: Text("categories".t(context)),
            leading: const Icon(Symbols.category_rounded),
            onTap: () => context.push("/categories"),
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
            leading: const Icon(Symbols.settings_backup_restore_rounded),
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
            title: Text("visitGitHubRepo".t(context)),
            leading: const Icon(SimpleIcons.github),
            onTap: () => openUrl(flowGitHubRepoLink),
          ),
          if (flowDebugMode) ...[
            const SizedBox(height: 32.0),
            const ListHeader("Debug options"),
            ListTile(
              title: const Text("Populate objectbox"),
              leading: const Icon(Symbols.adb_rounded),
              onTap: () => ObjectBox().createAndPutDebugData(),
            ),
            ListTile(
              title:
                  Text(_debugDbBusy ? "Clearing database" : "Clear objectbox"),
              onTap: () => resetDatabase(),
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
            child: Text(
              "v$appVersion",
              style: context.textTheme.labelSmall,
            ),
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
      builder: (context) => AlertDialog.adaptive(
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

    try {
      if (confirm == true) {
        await ObjectBox().eraseMainData();
      }
    } finally {
      _debugDbBusy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void import() async {
    try {
      await importBackupV1();
      if (mounted) {
        context.showToast(
          text: "sync.import.successful".t(context),
        );
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast(error: e);
      }
    }
  }
}

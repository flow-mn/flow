import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/sync/import.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/toast.dart';
import 'package:flow/utils/utils.dart';
import 'package:flow/widgets/general/list_header.dart';
import 'package:flow/widgets/home/prefs/profile_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:moment_dart/moment_dart.dart';
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
            onTap: () => {},
          ),
          ListTile(
            title: Text("tabs.profile.supportOnKofi".t(context)),
            leading: const Icon(SimpleIcons.kofi),
            onTap: () => openUrl(Uri.parse("https://ko-fi.com/sadespresso")),
          ),
          ListTile(
            title: Text("tabs.profile.viewProjectOnGitHub".t(context)),
            leading: const Icon(SimpleIcons.github),
            onTap: () => openUrl(Uri.parse("https://github.com/flow-mn/flow")),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 32.0),
            const ListHeader("Debug options"),
            ListTile(
              title: const Text("Populate objectbox"),
              leading: const Icon(Symbols.adb_rounded),
              onTap: () => ObjectBox().populateDummyData(),
            ),
            ListTile(
              title:
                  Text(_debugDbBusy ? "Clearing database" : "Clear objectbox"),
              onTap: () => resetDatabase(),
              leading: const Icon(Symbols.adb_rounded),
            ),
            ListTile(
              title: const Text("Import from backup"),
              onTap: () => import(),
              leading: const Icon(Symbols.import_export_rounded),
            ),
          ],
          const SizedBox(height: 64.0),
          Center(
            child: Text(
              "version indev-1, ${Moment.fromMillisecondsSinceEpoch(1700982217689).calendar()}",
              style: context.textTheme.labelSmall,
            ),
          ),
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(8.0),
              onTap: () => openUrl(Uri.parse("https://github.com/sadespresso")),
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
          ElevatedButton(
            onPressed: () => context.pop(true),
            child: const Text("Confirm delete"),
          ),
          ElevatedButton(
            onPressed: () => context.pop(false),
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
        await ObjectBox().wipeDatabase();
        await ObjectBox.initialize();
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
      if (context.mounted) {
        context.showToast(
          text: "sync.import.successful".t(context),
          error: true,
        );
      }
    } catch (e) {
      if (context.mounted) {
        context.showToast(text: e.toString(), error: true);
      }
    }
  }
}

import "dart:async";
import "dart:developer";
import "dart:io";

import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/sync/icloud_syncer.dart";
import "package:flow/services/sync/syncer.dart";
import "package:flow/sync/import.dart";
import "package:flow/sync/import/base.dart";
import "package:flow/utils/extensions/importer.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/action_card.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/setup/icloud_backup_picker_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:simple_icons/simple_icons.dart";

class SetupOnboardingPage extends StatefulWidget {
  const SetupOnboardingPage({super.key});

  @override
  State<SetupOnboardingPage> createState() => _SetupOnboardingPageState();
}

class _SetupOnboardingPageState extends State<SetupOnboardingPage> {
  bool loading = true;
  bool busy = false;

  List<SyncerItem>? backups = [];

  @override
  void initState() {
    super.initState();

    if (ICloudSyncer().syncing) {
      checkForBackups();
    } else {
      loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("setup.onboarding".t(context))),
      body: (loading || busy)
          ? SafeArea(child: const Spinner.center())
          : SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (backups?.isNotEmpty == true) ...[
                        ActionCard(
                          onTap: () => showICloudBackupModal(),
                          icon: FlowIconData.icon(SimpleIcons.icloud),
                          title: "setup.onboarding.recoverICloudBackup".t(
                            context,
                          ),
                          subtitle:
                              "setup.onboarding.recoverICloudBackup.description"
                                  .t(
                                    context,
                                    backups?.firstOrNull?.inferredBackupDate
                                            ?.toMoment()
                                            .lll ??
                                        "-",
                                  ),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                      ActionCard(
                        onTap: () => context.push("/setup/currency"),
                        icon: FlowIconData.icon(Symbols.wand_stars_rounded),
                        title: "setup.onboarding.freshStart".t(context),
                        subtitle: "setup.onboarding.freshStart.description".t(
                          context,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ActionCard(
                        onTap: () => context.push("/import?setupMode=true"),
                        icon: FlowIconData.icon(Symbols.restore_page_rounded),
                        title: "setup.onboarding.importExisting".t(context),
                        subtitle: "setup.onboarding.importExisting.description"
                            .t(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> waitForICloudInitialUpdate() async {
    if (ICloudSyncer().initialUpdateReceived.value) {
      return;
    }

    final Completer<void> completer = Completer<void>();
    late final Timer timer;

    void listener() {
      if (ICloudSyncer().initialUpdateReceived.value) {
        completer.complete();
      }

      try {
        if (timer.isActive) {
          timer.cancel();
        }
      } catch (e) {
        // silent fail
      }
    }

    try {
      timer = Timer(const Duration(seconds: 15), () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      });
      ICloudSyncer().initialUpdateReceived.addListener(listener);
      return await completer.future;
    } catch (e) {
      // silent fail
    } finally {
      timer.cancel();
      ICloudSyncer().initialUpdateReceived.removeListener(listener);
    }
  }

  Future<void> checkForBackups() async {
    try {
      await waitForICloudInitialUpdate().catchError((e) {});

      backups = await ICloudSyncer().list();
      backups?.sort(
        (a, b) =>
            (b.inferredBackupDate ?? DateTime.fromMicrosecondsSinceEpoch(0))
                .compareTo(
                  a.inferredBackupDate ??
                      DateTime.fromMicrosecondsSinceEpoch(0),
                ),
      );
    } finally {
      loading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void showICloudBackupModal() async {
    try {
      final SyncerItem? result = await showModalBottomSheet(
        context: context,
        builder: (context) => ICloudBackupPickerSheet(backups: backups!),
        isScrollControlled: true,
      );

      if (!mounted) return;

      if (result == null) return;

      setState(() {
        busy = true;
      });

      final File? file = await ICloudSyncer().download(result);

      if (!mounted) return;

      if (file == null) {
        throw "error.sync.fileNotFound".t(context);
      }

      final Importer importer = await importBackup(backupFile: file);

      if (mounted) {
        importer.goToRelevantPage(context, setupMode: true);
      }

      unawaited(LocalPreferences().completedInitialSetup.set(true));
    } catch (e) {
      if (!mounted) return;

      context.showErrorToast(error: e);

      log("Error importing iCloud backup: $e");
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}

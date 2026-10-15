// import "package:flow/constants.dart";
import "package:flow/constants.dart";
import "package:flow/entity/user_preferences.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/transitive.dart";
import "package:flow/routes/preferences/sections/icloud.dart";
import "package:flow/services/sync/icloud_syncer.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class SyncPreferencesPage extends StatefulWidget {
  const SyncPreferencesPage({super.key});

  @override
  State<SyncPreferencesPage> createState() => _SyncPreferencesPageState();
}

class _SyncPreferencesPageState extends State<SyncPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final int? autobackupIntervalInHours =
        UserPreferencesService().autoBackupIntervalInHours;

    final List<int?> options = [null, 12, 24, 48, 72, 168, 336, 720];

    if (autobackupIntervalInHours != null &&
        !options.contains(autobackupIntervalInHours)) {
      options.add(autobackupIntervalInHours);
    }

    final DateTime? lastAutoBackupRanAt = TransitiveLocalPreferences()
        .lastAutoBackupRanAt
        .get();

    return Scaffold(
      appBar: AppBar(title: Text("preferences.sync".t(context))),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              const SizedBox(height: 16.0),
              ListHeader("preferences.sync.autoBackup.interval".t(context)),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children: options
                      .map(
                        (value) => FilterChip(
                          showCheckmark: false,
                          key: ValueKey(value),
                          label: Text(
                            value == null
                                ? "preferences.sync.autoBackup.disabled".t(
                                    context,
                                  )
                                : Duration(hours: value).toDurationString(
                                    dropPrefixOrSuffix: true,
                                    format: value >= 24
                                        ? DurationFormat.dh
                                        : DurationFormat.hm,
                                  ),
                          ),
                          onSelected: (bool selected) => selected
                              ? updateAutoBackupIntervalInHours(value)
                              : null,
                          selected: value == autobackupIntervalInHours,
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 8.0),
              Frame(
                child: InfoText(
                  child: Text(
                    "preferences.sync.autoBackup.interval.description".t(
                      context,
                    ),
                  ),
                ),
              ),
              if (autobackupIntervalInHours != null)
                ValueListenableBuilder<UserPreferences>(
                  valueListenable: UserPreferencesService().valueNotifier,
                  builder: (context, userPreferences, _) =>
                      (ICloudSyncer.supported &&
                          userPreferences.enableICloudSync)
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Frame(
                            child: InfoText(
                              icon: Symbols.warning_rounded,
                              child: Text(
                                "sync.export.onDeviceWarning".t(context),
                              ),
                            ),
                          ),
                        ),
                ),
              const SizedBox(height: 8.0),
              ListTile(
                leading: const Icon(Symbols.history_rounded),
                title: Text("sync.export.history".t(context)),
                subtitle: lastAutoBackupRanAt == null
                    ? null
                    : Text(
                        "preferences.sync.autoBackup.lastBackup".t(
                          context,
                          lastAutoBackupRanAt.toMoment().lll,
                        ),
                      ),
                trailing: const Icon(Symbols.chevron_right_rounded),
                onTap: () => context.push("/export/history"),
              ),
              if (ICloudSyncer.supported || flowDebugMode) ...[
                const SizedBox(height: 16.0),
                if (!ICloudSyncer.supported)
                  Frame(
                    child: InfoText(
                      child: Text(
                        "DEBUG MODE: Even though your currenct device does not support iCloud, following section is shown because you are in debug mode.",
                      ),
                    ),
                  ),
                ICloud(),
              ],
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  void updateAutoBackupIntervalInHours(int? newIntervalInHours) async {
    UserPreferencesService().autoBackupIntervalInHours = newIntervalInHours;

    if (mounted) setState(() {});
  }
}

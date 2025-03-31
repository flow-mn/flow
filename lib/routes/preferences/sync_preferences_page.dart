import "dart:io";

import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/sections/icloud.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flutter/material.dart";
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

    final List<int?> options = [null, 12, 24, 48, 72, 168];

    if (autobackupIntervalInHours != null &&
        !options.contains(autobackupIntervalInHours)) {
      options.add(autobackupIntervalInHours);
    }

    return Scaffold(
      appBar: AppBar(title: Text("preferences.sync".t(context))),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              ListHeader("preferences.sync.autoBackup.interval".t(context)),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children:
                      options
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
                                    ),
                              ),
                              onSelected:
                                  (bool selected) =>
                                      selected
                                          ? updateAutoBackupIntervalInHours(
                                            value,
                                          )
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
              if (Platform.isIOS || Platform.isMacOS) ...[
                const SizedBox(height: 16.0),
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

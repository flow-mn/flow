import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/action_card.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class ExportOptionsPage extends StatefulWidget {
  const ExportOptionsPage({super.key});

  @override
  State<ExportOptionsPage> createState() => _ExportOptionsPageState();
}

class _ExportOptionsPageState extends State<ExportOptionsPage> {
  @override
  Widget build(BuildContext context) {
    final int? autoBackupIntervalInHours =
        UserPreferencesService().autoBackupIntervalInHours;

    final String autoBackupStatus = autoBackupIntervalInHours == null
        ? "general.disabled".t(context)
        : Duration(hours: autoBackupIntervalInHours).toDurationString(
            dropPrefixOrSuffix: true,
            format: autoBackupIntervalInHours >= 24
                ? DurationFormat.dh
                : DurationFormat.hm,
          );

    return Scaffold(
      appBar: AppBar(title: Text("sync.export".t(context))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ActionCard(
                onTap: openSyncPreferences,
                icon: FlowIconData.icon(Symbols.sync_rounded),
                title: "preferences.sync".t(context),
                subtitle:
                    "${"preferences.sync.autoBackup".t(context)}: $autoBackupStatus",
              ),
              const SizedBox(height: 16.0),
              ActionCard(
                onTap: () => context.push("/export/zip"),
                icon: FlowIconData.icon(Symbols.folder_zip_rounded),
                title: "sync.export.asZIP".t(context),
                subtitle: "sync.export.asZIP.description".t(context),
              ),
              const SizedBox(height: 16.0),
              ActionCard(
                onTap: () => context.push("/export/json"),
                icon: FlowIconData.icon(Symbols.database_rounded),
                title: "sync.export.asJSON".t(context),
                subtitle: "sync.export.asJSON.description".t(context),
              ),
              const SizedBox(height: 16.0),
              ActionCard(
                onTap: () => context.push("/export/pdf"),
                icon: FlowIconData.icon(Symbols.picture_as_pdf_rounded),
                title: "sync.export.asPDF".t(context),
                subtitle: "sync.export.asPDF.description".t(context),
              ),
              const SizedBox(height: 16.0),
              ActionCard(
                onTap: () => context.push("/export/csv"),
                icon: FlowIconData.icon(Symbols.table_rounded),
                title: "sync.export.asCSV".t(context),
                subtitle: "sync.export.asCSV.description".t(context),
              ),
              const SizedBox(height: 16.0),
              ActionCard(
                onTap: () => context.push("/export/history"),
                icon: FlowIconData.icon(Symbols.history_rounded),
                title: "sync.export.history".t(context),
                subtitle: "sync.export.history.description".t(context),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  void openSyncPreferences() async {
    await context.push("/preferences/sync");

    if (mounted) setState(() {});
  }
}

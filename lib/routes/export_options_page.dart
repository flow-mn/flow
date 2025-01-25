import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/action_card.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class ExportOptionsPage extends StatefulWidget {
  const ExportOptionsPage({super.key});

  @override
  State<ExportOptionsPage> createState() => _ExportOptionsPageState();
}

class _ExportOptionsPageState extends State<ExportOptionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("sync.export".t(context))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ActionCard(
                onTap: () => context.push("/export/csv"),
                icon: FlowIconData.icon(Symbols.table_rounded),
                title: "sync.export.asCSV".t(context),
                subtitle: "sync.export.asCSV.description".t(context),
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
                onTap: () => context.push("/export/history"),
                icon: FlowIconData.icon(Symbols.history_rounded),
                title: "sync.export.history".t(context),
                subtitle: "sync.export.history.description".t(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flow/data/flow_icon.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/action_card.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

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
                builder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlowIcon(
                        FlowIconData.icon(Symbols.table_rounded),
                        size: 80.0,
                        plated: true,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        "sync.export.asCSV".t(context),
                        style: context.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        "sync.export.asCSV.description".t(context),
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ActionCard(
                onTap: () => context.push("/export/json"),
                builder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlowIcon(
                        FlowIconData.icon(Symbols.database_rounded),
                        size: 80.0,
                        plated: true,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        "sync.export.asJSON".t(context),
                        style: context.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        "sync.export.asJSON.description".t(context),
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

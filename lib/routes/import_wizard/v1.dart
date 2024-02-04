import 'package:flow/l10n/extensions.dart';
import 'package:flow/l10n/named_enum.dart';
import 'package:flow/sync/import/import_v1.dart';
import 'package:flow/widgets/general/spinner.dart';
import 'package:flow/widgets/import_wizard/v1/backup_info.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class ImportWizardV1Page extends StatefulWidget {
  final ImportV1 importer;

  const ImportWizardV1Page({super.key, required this.importer});

  @override
  State<ImportWizardV1Page> createState() => _ImportWizardV1PageState();
}

class _ImportWizardV1PageState extends State<ImportWizardV1Page> {
  ImportV1 get importer => widget.importer;

  dynamic error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("sync.import".t(context)),
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: importer.progressNotifier,
          builder: (context, value, child) => switch (value) {
            ImportV1Progress.waitingConfirmation => BackupInfo(
                importer: importer,
                onTap: _start,
              ),
            ImportV1Progress.error => Text(error.toString()),
            ImportV1Progress.success => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Yeyy"),
                  const SizedBox(height: 16.0),
                  ElevatedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Symbols.chevron_left_rounded),
                    label: Text("general.back".t(context)),
                  ),
                ],
              ),
            _ => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Spinner.center(),
                    Center(
                      child: Text(
                        value.localizedNameContext(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
          },
        ),
      ),
    );
  }

  void _start() async {
    try {
      await importer.execute();
    } catch (e) {
      error = e;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }
}

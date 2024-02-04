import 'package:flow/l10n/named_enum.dart';
import 'package:flow/sync/import/import_v1.dart';
import 'package:flow/widgets/general/spinner.dart';
import 'package:flow/widgets/import/backup_file_info_v1.dart';
import 'package:flutter/material.dart';

class ImportProgressIndicatorV1 extends StatelessWidget {
  final ImportV1 importV1;

  final VoidCallback startFn;

  const ImportProgressIndicatorV1({
    super.key,
    required this.startFn,
    required this.importV1,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: importV1.progressNotifier,
      builder: (context, value, child) => switch (value) {
        ImportV1Progress.waitingConfirmation =>
          BackupFileInfoV1(onTap: () => importV1.execute(), importer: importV1),
        ImportV1Progress.error => const Text("error"),
        ImportV1Progress.success => const Text("Yeyyyyy, success"),
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
    );
  }
}

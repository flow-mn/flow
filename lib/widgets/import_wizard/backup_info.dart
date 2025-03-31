import "package:flow/sync/import/base.dart";
import "package:flow/sync/import/import_csv.dart";
import "package:flow/sync/import/import_v1.dart";
import "package:flow/sync/import/import_v2.dart";
import "package:flow/widgets/import_wizard/csv/backup_info_csv.dart";
import "package:flow/widgets/import_wizard/v1/backup_info_v1.dart";
import "package:flow/widgets/import_wizard/v2/backup_info_v2.dart";
import "package:flutter/widgets.dart";

class BackupInfo extends StatelessWidget {
  final Importer importer;
  final VoidCallback onClickStart;

  const BackupInfo({
    super.key,
    required this.importer,
    required this.onClickStart,
  });

  @override
  Widget build(BuildContext context) => switch (importer) {
    ImportV1 v1 => BackupInfoV1(importer: v1, onClickStart: onClickStart),
    ImportV2 v2 => BackupInfoV2(importer: v2, onClickStart: onClickStart),
    ImportCSV csv => BackupInfoCSV(importer: csv, onClickStart: onClickStart),
    _ => Container(),
  };
}

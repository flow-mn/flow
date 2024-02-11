import 'package:flow/l10n/extensions.dart';
import 'package:flow/sync/import/import_v1.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/button.dart';
import 'package:flow/widgets/general/list_header.dart';
import 'package:flutter/material.dart';

class BackupInfo extends StatelessWidget {
  final VoidCallback onTap;
  final ImportV1 importer;

  const BackupInfo({
    super.key,
    required this.onTap,
    required this.importer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListHeader("sync.import.syncData.parsedEstimate".t(context)),
        ListTile(
          title: Text(
            "sync.import.syncData.parsedEstimate.accountCount".t(
              context,
              importer.data.accounts.length,
            ),
          ),
        ),
        ListTile(
          title: Text(
            "sync.import.syncData.parsedEstimate.transactionCount".t(
              context,
              importer.data.transactions.length,
            ),
          ),
        ),
        ListTile(
          title: Text(
            "sync.import.syncData.parsedEstimate.categoryCount".t(
              context,
              importer.data.categories.length,
            ),
          ),
        ),
        const Spacer(),
        Text(
          "sync.import.eraseWarning".t(context),
          style: context.textTheme.bodyMedium
              ?.copyWith(color: context.flowColors.expense),
        ),
        Button(
          onTap: onTap,
          child: Text(
            "sync.import.start".t(context),
          ),
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }
}

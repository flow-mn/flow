import 'package:flow/entity/backup_entry.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/objectbox/objectbox.g.dart';
import 'package:flow/sync/export/history/backup_entry_card.dart';
import 'package:flow/widgets/general/spinner.dart';
import 'package:flutter/material.dart';

class ExportHistoryPage extends StatefulWidget {
  const ExportHistoryPage({super.key});

  @override
  State<ExportHistoryPage> createState() => _ExportHistoryPageState();
}

class _ExportHistoryPageState extends State<ExportHistoryPage> {
  // Query for today's transaction, newest to oldest
  QueryBuilder<BackupEntry> qb() => ObjectBox()
      .box<BackupEntry>()
      .query()
      .order(BackupEntry_.createdDate, flags: Order.descending);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("sync.export.history".t(context))),
      body: SafeArea(
        child: StreamBuilder<List<BackupEntry>>(
          stream:
              qb().watch(triggerImmediately: true).map((event) => event.find()),
          builder: (context, snapshot) {
            final List<BackupEntry>? backupEntires = snapshot.data;

            const Widget separator = SizedBox(height: 16.0);

            return switch ((backupEntires?.length ?? 0, snapshot.hasData)) {
              (0, true) => const Text("empty"),
              (_, true) => ListView.separated(
                  itemBuilder: (context, index) => BackupEntryCard(
                    entry: backupEntires[index],
                    dismissibleKey: ValueKey(backupEntires[index].id),
                  ),
                  separatorBuilder: (context, index) => separator,
                  itemCount: backupEntires!.length,
                ),
              (_, false) => const Spinner.center(),
            };
          },
        ),
      ),
    );
  }
}

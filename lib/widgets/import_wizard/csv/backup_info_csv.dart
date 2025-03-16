import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/sync/import/import_csv.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/import_wizard/import_item_list_tile.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class BackupInfoCSV extends StatelessWidget {
  final VoidCallback onClickStart;
  final ImportCSV importer;

  const BackupInfoCSV({
    super.key,
    required this.onClickStart,
    required this.importer,
  });

  @override
  Widget build(BuildContext context) {
    final int categoryCount = importer.data.categoryNames.nonNulls.length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: ListHeader("sync.import.syncData.parsedEstimate".t(context)),
          ),
          const SizedBox(height: 16.0),
          ImportItemListTile(
            icon: FlowIconData.icon(Symbols.wallet_rounded),
            label: Text(
              "sync.import.syncData.parsedEstimate.accountCount".t(
                context,
                importer.data.accountNames.length,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          ImportItemListTile(
            icon: FlowIconData.icon(Symbols.list_alt_rounded),
            label: Text(
              "sync.import.syncData.parsedEstimate.transactionCount".t(
                context,
                importer.data.transactions.length,
              ),
            ),
          ),
          if (categoryCount > 0) ...[
            const SizedBox(height: 8.0),
            ImportItemListTile(
              icon: FlowIconData.icon(Symbols.category_rounded),
              label: Text(
                "sync.import.syncData.parsedEstimate.categoryCount".t(
                  context,
                  categoryCount,
                ),
              ),
            ),
          ],
          const Spacer(),
          InfoText(child: Text("sync.import.emergencyBackup".t(context))),
          const SizedBox(height: 16.0),
          Button(
            onTap: onClickStart,
            leading: FlowIcon(FlowIconData.icon(Symbols.download_rounded)),
            child: Text("sync.import.start".t(context)),
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }
}

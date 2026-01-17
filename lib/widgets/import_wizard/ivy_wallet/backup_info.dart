import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/sync/import/external/ivy_wallet_csv.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/import_wizard/import_item_list_tile.dart";
import "package:flow/widgets/scaffold_actions.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class BackupInfoIvyWalletCsv extends StatefulWidget {
  final VoidCallback onClickStart;
  final IvyWalletCsvImporter importer;

  const BackupInfoIvyWalletCsv({
    super.key,
    required this.onClickStart,
    required this.importer,
  });

  @override
  State<BackupInfoIvyWalletCsv> createState() => _BackupInfoIvyWalletCsvState();
}

class _BackupInfoIvyWalletCsvState extends State<BackupInfoIvyWalletCsv> {
  @override
  Widget build(BuildContext context) {
    final int categoryCount =
        widget.importer.data.categoryNames.nonNulls.length;

    return Scaffold(
      appBar: AppBar(title: Text("sync.import".t(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: ListHeader(
                "sync.import.syncData.parsedEstimate".t(context),
              ),
            ),
            const SizedBox(height: 16.0),
            ImportItemListTile(
              icon: FlowIconData.icon(Symbols.wallet_rounded),
              label: Text(
                "sync.import.syncData.parsedEstimate.accountCount".t(
                  context,
                  widget.importer.data.accountNames.length,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            ImportItemListTile(
              icon: FlowIconData.icon(Symbols.list_alt_rounded),
              label: Text(
                "sync.import.syncData.parsedEstimate.transactionCount".t(
                  context,
                  widget.importer.data.transactions.length,
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
            const SizedBox(height: 16.0),
            InfoText(child: Text("sync.import.emergencyBackup".t(context))),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
      bottomNavigationBar: ScaffoldActions(
        children: [
          Button(
            onTap: widget.onClickStart,
            leading: FlowIcon(FlowIconData.icon(Symbols.download_rounded)),
            child: Text("sync.import.start".t(context)),
          ),
        ],
      ),
    );
  }
}

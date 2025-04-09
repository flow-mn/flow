import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/sync/import/import_csv.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/extensions/toast.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/import_wizard/csv/account_currency_list_tile.dart";
import "package:flow/widgets/import_wizard/import_item_list_tile.dart";
import "package:flow/widgets/sheets/select_currency_sheet.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class BackupInfoCSV extends StatefulWidget {
  final VoidCallback onClickStart;
  final ImportCSV importer;

  const BackupInfoCSV({
    super.key,
    required this.onClickStart,
    required this.importer,
  });

  @override
  State<BackupInfoCSV> createState() => _BackupInfoCSVState();
}

class _BackupInfoCSVState extends State<BackupInfoCSV> {
  @override
  Widget build(BuildContext context) {
    final int categoryCount =
        widget.importer.data.categoryNames.nonNulls.length;

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
                widget.importer.data.accountNames.length,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "sync.import.pickCurrencies".t(context),
                style: context.textTheme.labelMedium,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  widget.importer.data.accountNames.map((name) {
                    final String? currency =
                        widget.importer.accountCurrencies[name];
                    return AccountCurrencyListTile(
                      name: name,
                      currency: currency,
                      onTap: () => _setCurrencyFor(name),
                    );
                  }).toList(),
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
          const Spacer(),
          InfoText(child: Text("sync.import.emergencyBackup".t(context))),
          const SizedBox(height: 16.0),
          Button(
            onTap:
                widget.importer.ready
                    ? widget.onClickStart
                    : _showIncompleteToast,
            leading: FlowIcon(FlowIconData.icon(Symbols.download_rounded)),
            child: Text("sync.import.start".t(context)),
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }

  void _showIncompleteToast() {
    context.showErrorToast(
      error: "sync.import.pickCurrencies.incomplete".t(context),
    );
  }

  void _setCurrencyFor(String name) async {
    final currency = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => const SelectCurrencySheet(),
      isScrollControlled: true,
    );

    if (currency == null) return;

    if (widget.importer.accountCurrencies.isEmpty) {
      for (final String name in widget.importer.data.accountNames) {
        widget.importer.accountCurrencies[name] = currency;
      }
    } else {
      widget.importer.accountCurrencies[name] = currency;
    }

    if (mounted) {
      setState(() {});
    }
  }
}

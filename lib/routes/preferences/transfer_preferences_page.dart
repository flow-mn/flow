import "package:flow/l10n/extensions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/home/preferences/transfer_preferences/combine_transfer_radio.dart.dart";
import "package:flutter/material.dart";

class TransferPreferencesPage extends StatefulWidget {
  const TransferPreferencesPage({super.key});

  @override
  State<TransferPreferencesPage> createState() =>
      _TransferPreferencesPageState();
}

class _TransferPreferencesPageState extends State<TransferPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final bool excludeTransferFromFlow =
        UserPreferencesService().excludeTransfersFromFlow;
    final bool combineTransferTransactions =
        UserPreferencesService().combineTransfers;

    return Scaffold(
      appBar: AppBar(title: Text("preferences.transfer".t(context))),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              ListHeader(
                "preferences.transfer.combineTransferTransaction".t(context),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CombineTransferRadio.combine(
                        currentlyUsingCombineMode: combineTransferTransactions,
                        onTap: () => updateCombineTransferTransactions(true),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: CombineTransferRadio.separate(
                        currentlyUsingCombineMode: combineTransferTransactions,
                        onTap: () => updateCombineTransferTransactions(false),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              Frame(
                child: InfoText(
                  child: Text(
                    "preferences.transfer.combineTransferTransaction.combineSupportDisclaimer"
                        .t(context),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              CheckboxListTile /*.adaptive*/ (
                title: Text(
                  "preferences.transfer.excludeTransferFromFlow".t(context),
                ),
                value: excludeTransferFromFlow,
                onChanged: updateExcludeTransferFromFlow,
                subtitle: Text(
                  "preferences.transfer.excludeTransferFromFlow.description".t(
                    context,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  void updateExcludeTransferFromFlow(bool? excludeFromFlow) async {
    if (excludeFromFlow == null) return;

    UserPreferencesService().excludeTransfersFromFlow = excludeFromFlow;

    if (mounted) setState(() {});
  }

  void updateCombineTransferTransactions(bool? combine) async {
    if (combine == null) return;

    UserPreferencesService().combineTransfers = combine;

    if (mounted) setState(() {});
  }
}

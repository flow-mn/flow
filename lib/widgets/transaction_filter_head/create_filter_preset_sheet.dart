import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/transaction_filter_preset.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class CreateFilterPresetSheet extends StatefulWidget {
  final String? initialName;
  final TransactionFilter filter;

  const CreateFilterPresetSheet({
    super.key,
    this.initialName,
    required this.filter,
  });

  @override
  State<CreateFilterPresetSheet> createState() =>
      _CreateFilterPresetSheetState();
}

class _CreateFilterPresetSheetState extends State<CreateFilterPresetSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("transactionFilterPreset.saveAsNew".t(context)),
      trailing: ModalOverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: pop,
            icon: const Icon(Symbols.block_rounded),
            label: Text("general.cancel".t(context)),
          ),
          TextButton.icon(
            onPressed: saveAndPop,
            icon: const Icon(Symbols.check_rounded),
            label: Text("general.done".t(context)),
          ),
        ],
      ),
      scrollableContentMaxHeight: MediaQuery.of(context).size.height * 0.5,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            Frame(
              child: TextField(
                autofocus: true,
                controller: _controller,
                maxLength: TransactionFilterPreset.maxNameLength,
                onSubmitted: (_) => pop(),
                decoration: InputDecoration(
                  hintText: "transactionFilterPreset.saveAsNew.name".t(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int saveAndPop() {
    try {
      return ObjectBox().box<TransactionFilterPreset>().put(
            TransactionFilterPreset(
              name: _controller.text,
              jsonTransactionFilter: widget.filter.serialize(),
            ),
          );
    } finally {
      pop();
    }
  }

  void pop() => context.pop();
}

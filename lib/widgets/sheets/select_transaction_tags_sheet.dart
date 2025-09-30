import "package:flow/entity/transaction_tag.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/transaction_tag_add_chip.dart";
import "package:flow/widgets/transaction_tag_chip.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with a [List<TransactionTag>]
class SelectTransactionTagsSheet extends StatefulWidget {
  final List<TransactionTag> tags;
  final List<String>? initialTagUuids;

  const SelectTransactionTagsSheet({
    super.key,
    required this.tags,
    this.initialTagUuids,
  });

  @override
  State<SelectTransactionTagsSheet> createState() =>
      _SelectTransactionTagsSheetState();
}

class _SelectTransactionTagsSheetState
    extends State<SelectTransactionTagsSheet> {
  late final Set<String> _selectedTagUuids;

  @override
  void initState() {
    super.initState();
    _selectedTagUuids = Set.from(widget.initialTagUuids ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("setup.transactionTags".t(context)),
      trailing: ModalOverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(<TransactionTag>[]),
            icon: const Icon(Symbols.block_rounded),
            label: Text("transactions.query.clearSelection".t(context)),
          ),
          TextButton.icon(
            onPressed: pop,
            icon: const Icon(Symbols.check_rounded),
            label: Text("general.done".t(context)),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Frame(
          child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              TransactionTagAddChip(
                onPressed: () => context.push("/transactionTags/new"),
              ),
              ...widget.tags.map(
                (tag) => TransactionTagChip(
                  tag: tag,
                  selected: _selectedTagUuids.contains(tag.uuid),
                  key: ValueKey(tag.uuid),
                  onPressed: () {
                    if (_selectedTagUuids.contains(tag.uuid)) {
                      _selectedTagUuids.remove(tag.uuid);
                    } else {
                      _selectedTagUuids.add(tag.uuid);
                    }
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void pop() {
    final List<TransactionTag> selectedTags = widget.tags
        .where((tag) => _selectedTagUuids.contains(tag.uuid))
        .toList();

    context.pop(selectedTags);
  }
}

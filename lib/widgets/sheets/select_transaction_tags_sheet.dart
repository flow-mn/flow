import "package:flow/entity/transaction_tag.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/utils/simple_query_sorter.dart";
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
  final bool? showSearchBar;

  /// Use this to get notified when the selection changes.
  /// This will be called whenever a tag is selected or deselected.
  ///
  /// Last value of this callback will be returned when the sheet is popped.
  final ValueChanged<List<TransactionTag>>? onChanged;

  const SelectTransactionTagsSheet({
    super.key,
    required this.tags,
    this.initialTagUuids,
    this.showSearchBar = true,
    this.onChanged,
  });

  @override
  State<SelectTransactionTagsSheet> createState() =>
      _SelectTransactionTagsSheetState();
}

class _SelectTransactionTagsSheetState
    extends State<SelectTransactionTagsSheet> {
  late final Set<String> _selectedTagUuids;

  String _query = "";

  @override
  void initState() {
    super.initState();
    _selectedTagUuids = Set.from(widget.initialTagUuids ?? const []);
  }

  @override
  void didUpdateWidget(covariant SelectTransactionTagsSheet oldWidget) {
    if (widget.initialTagUuids != oldWidget.initialTagUuids) {
      _selectedTagUuids.clear();
      _selectedTagUuids.addAll(widget.initialTagUuids ?? const []);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final bool showSearchBar = widget.showSearchBar ?? widget.tags.length > 12;

    final List<TransactionTag> results = simpleSortByQuery(widget.tags, _query);

    return ModalSheet.scrollable(
      title: Text("setup.transactionTags".t(context)),
      trailing: ModalOverflowBar(
        alignment: .end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(<TransactionTag>[]),
            icon: const Icon(Symbols.block_rounded, fill: 0.0),
            label: Text("transactions.query.clearSelection".t(context)),
          ),
          TextButton.icon(
            onPressed: pop,
            icon: const Icon(Symbols.check_rounded),
            label: Text("general.done".t(context)),
          ),
        ],
      ),
      leading: showSearchBar
          ? Frame(
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: "general.search".t(context),
                  prefixIcon: const Icon(Symbols.search_rounded),
                ),
              ),
            )
          : null,
      child: Frame(
        child: SingleChildScrollView(
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: Wrap(
              spacing: 12.0,
              runSpacing: 8.0,
              children: [
                if (_query.isEmpty)
                  TransactionTagAddChip(onPressed: createAndAdd),
                ...results.map(
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
                      notifyChange();
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void notifyChange() {
    if (widget.onChanged == null) return;

    final List<TransactionTag> selectedTags = widget.tags
        .where((tag) => _selectedTagUuids.contains(tag.uuid))
        .toList();

    widget.onChanged!(selectedTags);
  }

  void pop() {
    final List<TransactionTag> selectedTags = widget.tags
        .where((tag) => _selectedTagUuids.contains(tag.uuid))
        .toList();

    context.pop(selectedTags);
  }

  void createAndAdd() async {
    final TransactionTag? result = await context.push("/transactionTags/new");

    if (result != null) {
      _selectedTagUuids.add(result.uuid);

      if (mounted) {
        setState(() {});
      }
    }
  }
}

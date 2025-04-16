import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/utils/simple_query_sorter.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with [List] of selected [Category]s
class SelectMultiCategorySheet extends StatefulWidget {
  final List<Category> categories;
  final List<String>? selectedUuids;

  /// Defaults to [true] when there are more than 8 categories.
  final bool? showSearchBar;

  const SelectMultiCategorySheet({
    super.key,
    required this.categories,
    this.selectedUuids,
    this.showSearchBar,
  });

  @override
  State<SelectMultiCategorySheet> createState() =>
      _SelectMultiCategorySheetState();
}

class _SelectMultiCategorySheetState extends State<SelectMultiCategorySheet> {
  String _query = "";

  late Set<String> selectedUuids;

  @override
  void initState() {
    super.initState();
    selectedUuids = Set.from(widget.selectedUuids ?? (const []));
  }

  @override
  void didUpdateWidget(covariant SelectMultiCategorySheet oldWidget) {
    if (widget.selectedUuids != oldWidget.selectedUuids) {
      selectedUuids = Set.from(widget.selectedUuids ?? (const []));
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final bool showSearchBar =
        widget.showSearchBar ?? widget.categories.length > 8;

    final List<Category> results = simpleSortByQuery(widget.categories, _query);

    return ModalSheet.scrollable(
      title: Text("transaction.edit.selectCategory.multiple".t(context)),
      trailing: ModalOverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(<Category>[]),
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
      leading:
          showSearchBar
              ? Frame(
                child: TextField(
                  autofocus: true,
                  onChanged: (value) => setState(() => _query = value),
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "general.search".t(context),
                    prefixIcon: const Icon(Symbols.search_rounded),
                  ),
                ),
              )
              : null,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...results.map(
              (category) => CheckboxListTile /*.adaptive*/ (
                key: ValueKey(category.uuid),
                title: Text(category.name),
                value: selectedUuids.contains(category.uuid),
                onChanged: (value) => select(category.uuid, value),
                secondary: FlowIcon(category.icon),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void select(String uuid, bool? selected) {
    if (selected == null) return;

    if (selectedUuids.contains(uuid)) {
      selectedUuids.remove(uuid);
    } else {
      selectedUuids.add(uuid);
    }

    setState(() {});
  }

  void pop() {
    final List<Category> selectedCategories =
        widget.categories
            .where((category) => selectedUuids.contains(category.uuid))
            .toList();

    context.pop(selectedCategories);
  }
}

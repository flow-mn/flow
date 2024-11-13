import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with [List] of selected [Category]s
class SelectMultiCategorySheet extends StatefulWidget {
  final List<Category> categories;
  final List<String>? selectedUuids;

  const SelectMultiCategorySheet({
    super.key,
    required this.categories,
    this.selectedUuids,
  });

  @override
  State<SelectMultiCategorySheet> createState() =>
      _SelectMultiCategorySheetState();
}

class _SelectMultiCategorySheetState extends State<SelectMultiCategorySheet> {
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
            icon: const Icon(Symbols.check),
            label: Text("general.done".t(context)),
          ),
        ],
      ),
      scrollableContentMaxHeight: MediaQuery.of(context).size.height * 0.5,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...widget.categories.map(
              (category) => CheckboxListTile.adaptive(
                title: Text(category.name),
                value: selectedUuids.contains(category.uuid),
                onChanged: (value) => select(category.uuid, value),
                // leading: FlowIcon(category.icon),
                // trailing: const Icon(Symbols.chevron_right_rounded),
                // onTap: () => context.pop(Optional(category)),
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
    final List<Category> selectedCategories = widget.categories
        .where((category) => selectedUuids.contains(category.uuid))
        .toList();

    context.pop(selectedCategories);
  }
}

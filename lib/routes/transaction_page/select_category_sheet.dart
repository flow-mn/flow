import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/utils/optional.dart";
import "package:flow/utils/simple_query_sorter.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with [ValueOr<Category>]
class SelectCategorySheet extends StatefulWidget {
  final List<Category> categories;
  final int? currentlySelectedCategoryId;

  /// Defaults to [true] when there are more than 6 categories.
  final bool? showSearchBar;

  final bool showTrailing;

  const SelectCategorySheet({
    super.key,
    required this.categories,
    this.currentlySelectedCategoryId,
    this.showSearchBar,
    this.showTrailing = true,
  });

  @override
  State<SelectCategorySheet> createState() => _SelectCategorySheetState();
}

class _SelectCategorySheetState extends State<SelectCategorySheet> {
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final bool showSearchBar =
        widget.showSearchBar ?? widget.categories.length > 6;

    final List<Category> results = simpleSortByQuery(widget.categories, _query);

    return ModalSheet.scrollable(
      title: Text("transaction.edit.selectCategory".t(context)),
      trailing: ModalOverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(const Optional<Category>(null)),
            icon: const Icon(Symbols.block_rounded),
            label: Text("category.skip".t(context)),
          ),
        ],
      ),
      leading:
          showSearchBar
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...results.map(
              (category) => ListTile(
                key: ValueKey(category.uuid),
                title: Text(category.name),
                leading: FlowIcon(category.icon),
                trailing: widget.showTrailing ? DirectionalChevron() : null,
                onTap: () => context.pop(Optional(category)),
                selected: widget.currentlySelectedCategoryId == category.id,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flow/entity/category.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/utils/optional.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flow/widgets/general/modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Pops with [ValueOr<Category>]
class SelectCategorySheet extends StatelessWidget {
  final List<Category> categories;
  final int? currentlySelectedCategoryId;

  const SelectCategorySheet({
    super.key,
    required this.categories,
    this.currentlySelectedCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("transaction.edit.selectCategory".t(context)),
      trailing: OverflowBar(
        children: [
          TextButton.icon(
            onPressed: () => context.pop(const Optional<Category>(null)),
            icon: const Icon(Symbols.block_rounded),
            label: Text("category.skip".t(context)),
          ),
        ],
      ),
      scrollableContentMaxHeight: MediaQuery.of(context).size.height * 0.5,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...categories.map(
              (category) => ListTile(
                title: Text(category.name),
                leading: FlowIcon(category.icon),
                trailing: const Icon(Symbols.chevron_right_rounded),
                onTap: () => context.pop(Optional(category)),
                selected: currentlySelectedCategoryId == category.id,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

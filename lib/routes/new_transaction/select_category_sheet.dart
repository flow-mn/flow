import 'package:flow/entity/category.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/value_or.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flow/widgets/general/bottom_sheet_frame.dart';
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
    final double maxHeight = MediaQuery.of(context).size.height * 0.9 -
        MediaQuery.of(context).viewInsets.vertical;

    return BottomSheetFrame(
      scrollable: true,
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SizedBox(
          height: maxHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16.0),
              Text(
                "transaction.edit.selectCategory".t(context),
                style: context.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              ...categories.map(
                (category) => ListTile(
                  title: Text(category.name),
                  leading: FlowIcon(category.icon),
                  trailing: const Icon(Symbols.chevron_right_rounded),
                  onTap: () => context.pop(ValueOr(category)),
                  selected: currentlySelectedCategoryId == category.id,
                ),
              ),
              const SizedBox(height: 8.0),
              ButtonBar(
                children: [
                  TextButton.icon(
                    onPressed: () => context.pop(const ValueOr<Category>(null)),
                    icon: const Icon(Symbols.close_rounded),
                    label: const Text("Skip"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

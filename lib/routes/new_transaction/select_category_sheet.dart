import 'package:flow/entity/category.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/bottom_sheet_frame.dart';
import 'package:flow/widgets/plated_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

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
    return BottomSheetFrame(
      scrollable: true,
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
              leading: PlatedIcon(
                category.icon,
                selected: currentlySelectedCategoryId == category.id,
              ),
              trailing: const Icon(Symbols.chevron_right_rounded),
              onTap: () => context.pop(category),
              selected: currentlySelectedCategoryId == category.id,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flow/entity/category.dart';
import 'package:flow/utils/value_or.dart';
import 'package:flow/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class CategoryPresetCard extends StatelessWidget {
  final Function(bool) onSelect;
  final bool selected;
  final bool preexisting;

  final Category category;

  const CategoryPresetCard({
    super.key,
    required this.onSelect,
    required this.selected,
    required this.category,
    required this.preexisting,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: selected ? 1.0 : 0.46,
      child: CategoryCard(
        category: category,
        onTapOverride: ValueOr(() => onSelect(!selected)),
        showAmount: false,
        trailing: preexisting
            ? null
            : Icon(selected ? Symbols.remove_rounded : Symbols.add_rounded),
      ),
    );
  }
}

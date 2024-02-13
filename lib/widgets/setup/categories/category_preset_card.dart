import 'package:flow/entity/category.dart';
import 'package:flow/widgets/category_card.dart';
import 'package:flutter/material.dart';

class CategoryPresetCard extends StatelessWidget {
  final Function(bool) onSelect;
  final bool selected;

  final Category category;

  const CategoryPresetCard({
    super.key,
    required this.onSelect,
    required this.selected,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: selected ? 1.0 : 0.46,
      duration: const Duration(milliseconds: 200),
      child: CategoryCard(
        category: category,
        onTapOverride: () => onSelect(!selected),
      ),
    );
  }
}

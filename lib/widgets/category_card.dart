import 'package:flow/entity/category.dart';
import 'package:flow/widgets/plated_icon.dart';
import 'package:flow/widgets/surface.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Surface(
      builder: (context) => Row(
        children: [
          PlatedIcon(category.icon),
          const SizedBox(width: 12.0),
          Text(category.name),
          const Spacer(),
        ],
      ),
    );
  }
}

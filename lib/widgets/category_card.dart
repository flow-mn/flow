import 'package:flow/entity/category.dart';
import 'package:flow/entity/transaction.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flow/widgets/general/surface.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryCard extends StatelessWidget {
  final Category category;

  final BorderRadius borderRadius;

  final VoidCallback? onTapOverride;

  const CategoryCard({
    super.key,
    this.onTapOverride,
    required this.category,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
  });

  @override
  Widget build(BuildContext context) {
    return Surface(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (context) => InkWell(
        borderRadius: borderRadius,
        onTap:
            onTapOverride ?? (() => context.push("/category/${category.id}")),
        child: Row(
          children: [
            FlowIcon(
              category.icon,
              size: 32.0,
              plated: true,
            ),
            const SizedBox(width: 12.0),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name),
                Text(
                  category.transactions.sum.money,
                  style: context.textTheme.bodyMedium?.semi(context),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

import "package:flow/data/money.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/prefs.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class CategoryCard extends StatelessWidget {
  final Category category;

  final BorderRadius borderRadius;

  final bool showAmount;

  final Optional<VoidCallback>? onTapOverride;

  final Widget? trailing;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTapOverride,
    this.trailing,
    this.showAmount = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
  });

  @override
  Widget build(BuildContext context) {
    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    return Surface(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (context) => InkWell(
        borderRadius: borderRadius,
        onTap: onTapOverride == null
            ? () => context.push("/category/${category.id}")
            : onTapOverride!.value,
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
                Text(
                  category.name,
                  style: context.textTheme.titleSmall,
                ),
                if (showAmount)
                  Text(
                    Money(category.transactions.sumWithoutCurrency,
                            primaryCurrency)
                        .money,
                    style: context.textTheme.bodyMedium?.semi(context),
                  ),
              ],
            ),
            const Spacer(),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 12.0),
            ],
          ],
        ),
      ),
    );
  }
}

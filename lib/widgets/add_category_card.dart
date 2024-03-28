import 'package:flow/data/flow_icon.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flow/widgets/general/surface.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class AddCategoryCard extends StatelessWidget {
  final VoidCallback? onTapOverride;

  const AddCategoryCard({
    super.key,
    this.onTapOverride,
  });

  static BorderRadius borderRadius = BorderRadius.circular(16.0);

  @override
  Widget build(BuildContext context) {
    return Surface(
      color: context.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (context) => InkWell(
        borderRadius: borderRadius,
        onTap: onTapOverride ?? (() => context.push("/category/new")),
        child: Row(
          children: [
            FlowIcon(
              FlowIconData.icon(Symbols.add_rounded),
              size: 32.0,
              plated: true,
            ),
            const SizedBox(width: 12.0),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("category.new".t(context)),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

import 'package:flow/data/flow_icon.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flow/widgets/general/surface.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class CategoryCardAdd extends StatelessWidget {
  final VoidCallback? onTap;

  const CategoryCardAdd({
    super.key,
    this.onTap,
  });

  static BorderRadius borderRadius = BorderRadius.circular(16.0);

  @override
  Widget build(BuildContext context) {
    return Surface(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (context) => InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
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

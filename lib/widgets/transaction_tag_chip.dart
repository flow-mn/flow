import "dart:math";

import "package:dashed_border/dashed_border.dart";
import "package:flow/entity/transaction_tag.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";

class TransactionTagChip extends StatelessWidget {
  final TransactionTag tag;
  final bool selected;

  final bool isSuggestion;

  final VoidCallback? onPressed;

  const TransactionTagChip({
    super.key,
    required this.tag,
    this.selected = false,
    this.isSuggestion = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final FlowColorScheme? colorScheme = tag.colorScheme;

    final Color borderColor = selected
        ? kTransparent
        : context.colorScheme.outline.withAlpha(0x80);

    final BorderRadius borderRadius = .circular(8.0);

    final Widget child = GestureDetector(
      onTap: onPressed,
      behavior: onPressed != null ? .opaque : .translucent,
      child: Container(
        margin: .symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: selected
              ? context.colorScheme.secondary
              : context.colorScheme.surface,
          borderRadius: borderRadius,
          border: isSuggestion
              ? DashedBorder(
                  color: borderColor,
                  width: 1.0,
                  borderRadius: borderRadius,
                  dashLength: 4.0,
                  dashGap: 4.0,
                )
              : Border.all(color: borderColor, width: 1.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          spacing: 8.0,
          mainAxisSize: .min,
          children: [
            FlowIcon(tag.icon, colorScheme: colorScheme, size: 16.0),
            Text(tag.title, style: context.textTheme.labelLarge),
          ],
        ),
      ),
    );

    if (isSuggestion) {
      return Badge(
        label: Icon(Symbols.star_rounded, color: context.colorScheme.onPrimary),
        backgroundColor: context.colorScheme.primary,
        child: Opacity(opacity: .7, child: child),
      );
    }

    return child;
  }
}

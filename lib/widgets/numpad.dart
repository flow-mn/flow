import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart";

export "numpad_button.dart";

/// By default, numbers, icons inside [NumpadButton]
/// takes 50% of the button width.
const _contentSizeFactor = .5;

class Numpad extends StatelessWidget {
  final int crossAxisCount;
  final List<Widget> children;

  final EdgeInsets padding;

  final double mainAxisSpacing;
  final double crossAxisSpacing;

  /// If not specified, uses [MediaQuery.of(context).size.width]
  final double? width;

  const Numpad({
    super.key,
    required this.children,
    this.width,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.crossAxisCount = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    final width = this.width ?? MediaQuery.of(context).size.width;

    final double totalHorizontalPadding =
        padding.left +
        padding.right +
        (crossAxisCount * (crossAxisSpacing - 1));

    final double itemSize = (width - totalHorizontalPadding) / crossAxisCount;
    final double itemContentSize = itemSize * _contentSizeFactor;

    return IconTheme.merge(
      data: IconThemeData(
        color: context.colorScheme.onSurface,
        size: itemContentSize,
        weight: 500.0,
        fill: 0,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: itemContentSize,
          color: context.colorScheme.onSurface,
          height: 1.0,
        ),
        child: Padding(
          padding: padding,
          child: StaggeredGrid.count(
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            crossAxisCount: crossAxisCount,
            children: children.map((child) => child).toList(),
          ),
        ),
      ),
    );
  }
}

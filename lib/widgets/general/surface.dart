import "package:flutter/material.dart";

class Surface extends StatelessWidget {
  final Color? color;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final double? elevation;
  final ShapeBorder? shape;
  final bool borderOnForeground;
  final Clip? clipBehavior;
  final EdgeInsetsGeometry? margin;
  final bool semanticContainer;
  final WidgetBuilder builder;

  final Color? iconColor;

  const Surface({
    super.key,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.iconColor,
    this.clipBehavior,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
    ),
    this.elevation = 0.0,
    this.margin = EdgeInsets.zero,
    this.borderOnForeground = true,
    this.semanticContainer = true,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final parentTheme = Theme.of(context);

    return Theme(
      data: parentTheme.copyWith(
        cardTheme: CardTheme(
          color: parentTheme.colorScheme.secondary,
        ),
        textTheme: parentTheme.textTheme.apply(
          bodyColor: parentTheme.colorScheme.onSecondary,
          displayColor: parentTheme.colorScheme.onSecondary,
          decorationColor: parentTheme.colorScheme.onSecondary,
        ),
        iconTheme: parentTheme.iconTheme.copyWith(
          color: iconColor ?? parentTheme.colorScheme.onSecondary,
        ),
      ),
      child: Card(
        color: color,
        shadowColor: shadowColor,
        surfaceTintColor: surfaceTintColor,
        elevation: elevation,
        shape: shape,
        borderOnForeground: borderOnForeground,
        clipBehavior: clipBehavior,
        margin: margin,
        semanticContainer: semanticContainer,
        child: Builder(builder: builder),
      ),
    );
  }
}

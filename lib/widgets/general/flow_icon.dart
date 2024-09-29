import "dart:io";

import "package:flow/data/flow_icon.dart";
import "package:flow/objectbox.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:path/path.dart";

class FlowIcon extends StatelessWidget {
  final FlowIconData data;

  final double size;
  final Color? color;

  final bool plated;

  /// Defaults to theme secondary color
  final Color? plateColor;

  final double plateElevation;

  /// Padding outside [size]
  final EdgeInsets platePadding;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final double fill;

  final BorderRadius borderRadius;

  const FlowIcon(
    this.data, {
    super.key,
    this.color,
    this.plateColor,
    this.plateElevation = 0.0,
    this.size = 24.0,
    this.fill = 1.0,
    this.plated = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.platePadding = const EdgeInsets.all(8.0),
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (!plated) return buildChild(context, data);

    final plateColor = this.plateColor ?? context.colorScheme.secondary;

    return Surface(
      builder: (BuildContext context) => InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: platePadding,
          child: buildChild(context, data),
        ),
      ),
      color: plateColor,
      iconColor: context.colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      elevation: plateElevation,
    );
  }

  Widget buildChild(BuildContext context, FlowIconData data) {
    final color = this.color ?? Theme.of(context).iconTheme.color;

    return switch (data) {
      IconFlowIcon icon => Icon(
          icon.iconData,
          size: size,
          color: color,
          fill: fill,
        ),
      ImageFlowIcon image => ClipRRect(
          borderRadius:
              borderRadius.subtract(BorderRadius.circular(platePadding.top)),
          child: Image.file(
            File(join(ObjectBox.appDataDirectory, image.imagePath)),
            width: size,
            height: size,
            errorBuilder: (context, error, stackTrace) => Icon(
              Symbols.error_rounded,
              color: context.flowColors.expense,
              size: size,
            ),
          ),
        ),
      CharacterFlowIcon character => SizedBox.square(
          dimension: size,
          child: Center(
            child: RichText(
              text: TextSpan(
                text: character.character,
                spellOut: false,
                style: TextStyle(
                  overflow: TextOverflow.visible,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                  fontSize: size,
                  height: 1.0,
                  inherit: false,
                  color: color,
                ),
              ),
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      _ => Container(),
    };
  }
}

import "package:flow/prefs/local_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart";

class NumpadButton extends StatelessWidget {
  /// Material color
  final Color? backgroundColor;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  final int crossAxisCellCount;
  final int mainAxisCellCount;

  final double borderRadiusSize;

  /// Ideally an [Icon] or [Text] widget with single character text
  final Widget child;

  const NumpadButton({
    super.key,
    required this.child,
    this.backgroundColor,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.borderRadiusSize = 16.0,
    this.crossAxisCellCount = 1,
    this.mainAxisCellCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(borderRadiusSize);

    return StaggeredGridTile.count(
      crossAxisCellCount: crossAxisCellCount,
      mainAxisCellCount: mainAxisCellCount,
      child: Material(
        textStyle: DefaultTextStyle.of(context).style,
        type: MaterialType.button,
        color: backgroundColor ?? context.colorScheme.secondary,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap == null ? null : onTapHandler,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
          child: Center(child: child),
        ),
      ),
    );
  }

  void onTapHandler() {
    if (LocalPreferences().enableHapticFeedback.get()) {
      HapticFeedback.mediumImpact();
    }

    if (onTap != null) {
      onTap!();
    }
  }
}

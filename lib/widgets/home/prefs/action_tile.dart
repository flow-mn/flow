import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class ActionTile extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final String title;

  final IconData icon;

  final BorderRadius borderRadius;

  const ActionTile({
    super.key,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Surface(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (context) => InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8.0),
              const Icon(Symbols.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

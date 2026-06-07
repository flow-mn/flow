import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

/// A single tile in the Stats bento dashboard.
///
/// A tappable [Surface] with an optional header (icon + uppercase label and a
/// trailing chevron) and a [child] body. Tiles size to a fixed [height] so the
/// bento grid stays predictable across content and locales; previews are
/// expected to fit, not scroll.
class BentoTile extends StatelessWidget {
  /// Short header text, e.g. "Net worth". Rendered uppercase next to [icon].
  final String label;

  final IconData icon;

  /// Tints the icon. Defaults to the theme primary color.
  final Color? accent;

  /// Fixed tile height. Paired tiles in a row should share the same value.
  final double height;

  /// Whether the body is still loading; shows a centered spinner instead.
  final bool busy;

  /// Navigation target. When non-null a chevron is shown and the tile ripples.
  final VoidCallback? onTap;

  final Widget child;

  const BentoTile({
    super.key,
    required this.label,
    required this.icon,
    required this.height,
    required this.child,
    this.accent,
    this.busy = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedAccent = accent ?? context.colorScheme.primary;

    return Surface(
      builder: (context) => InkWell(
        borderRadius: .all(Radius.circular(16.0)),
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: resolvedAccent, size: 18.0),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.flowColors.semi,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (onTap != null)
                      Icon(
                        Symbols.chevron_right_rounded,
                        size: 18.0,
                        color: context.flowColors.semi,
                      ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Expanded(
                  child: busy
                      ? const Spinner.center()
                      : Align(
                          alignment: AlignmentDirectional.topStart,
                          child: child,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

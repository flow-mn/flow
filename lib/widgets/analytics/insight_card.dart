import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";

/// A narrative "insight" card used by the analytics lab pages.
///
/// Renders a Flow [Surface] with an optional pill label + icon, a rich
/// [title] line, an optional [subtitle], and an optional [child] for a small
/// inline visualization (mini bars, a bullet chart, etc.).
class InsightCard extends StatelessWidget {
  final IconData? icon;

  /// Short uppercase pill text, e.g. "Budget".
  final String? label;

  /// Tints the icon and pill. Defaults to the theme primary color.
  final Color? accent;

  final Widget title;
  final String? subtitle;
  final Widget? child;

  final VoidCallback? onTap;

  const InsightCard({
    super.key,
    this.icon,
    this.label,
    this.accent,
    required this.title,
    this.subtitle,
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedAccent = accent ?? context.colorScheme.primary;
    final bool hasHeader = icon != null || label != null;

    return Surface(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      builder: (context) => InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasHeader) ...[
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: resolvedAccent, size: 20.0),
                      const SizedBox(width: 8.0),
                    ],
                    if (label != null)
                      _buildPill(context, label!, resolvedAccent),
                  ],
                ),
                const SizedBox(height: 10.0),
              ],
              DefaultTextStyle.merge(
                style: context.textTheme.titleSmall ?? const TextStyle(),
                child: title,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4.0),
                Text(
                  subtitle!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSecondary.withAlpha(0xb0),
                  ),
                ),
              ],
              if (child != null) ...[const SizedBox(height: 12.0), child!],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPill(BuildContext context, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: accent.withAlpha(0x28),
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Text(
        label.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          color: accent,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

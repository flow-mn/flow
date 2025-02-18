import "package:flow/data/flow_icon.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";

class ActionCard extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final FlowIconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  final BorderRadius borderRadius;

  const ActionCard({
    super.key,
    this.onTap,
    this.onLongPress,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    required this.title,
    this.icon,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Surface(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        builder:
            (context) => InkWell(
              borderRadius: borderRadius,
              onTap: onTap,
              onLongPress: onLongPress,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (icon != null) ...[
                      FlowIcon(icon!, size: 80.0, plated: true),
                      const SizedBox(height: 8.0),
                    ],
                    Text(title, style: context.textTheme.headlineSmall),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4.0),
                      Text(subtitle!, style: context.textTheme.bodyMedium),
                    ],
                    if (trailing != null) ...[
                      const SizedBox(height: 8.0),
                      trailing!,
                    ],
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

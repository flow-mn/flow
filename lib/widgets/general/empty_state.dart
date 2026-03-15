import "package:flow/data/flow_icon.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/widgets.dart";

class EmptyState extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
  final FlowIconData? icon;
  final Widget? title;
  final Widget? subtitle;

  const EmptyState({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(32.0),
      child: Center(
        child: Column(
          spacing: 12.0,
          mainAxisSize: MainAxisSize.min,
          children: [
            ?leading,
            if (icon != null)
              FlowIcon(icon!, size: 96.0, color: context.colorScheme.primary),
            if (title != null)
              DefaultTextStyle(
                textAlign: TextAlign.center,
                style: context.textTheme.headlineMedium!,
                child: title!,
              ),
            if (subtitle != null)
              Padding(
                padding: const .symmetric(horizontal: 8.0),
                child: DefaultTextStyle(
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium!,
                  child: subtitle!,
                ),
              ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

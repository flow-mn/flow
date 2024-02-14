import 'package:flow/theme/theme.dart';
import 'package:flutter/material.dart';

class ModalSheet extends StatelessWidget {
  final Widget? title;

  final Widget? child;

  final Widget? leading;
  final Widget? trailing;

  final double leadingSpacing;
  final double trailingSpacing;

  final double topSpacing;
  final double titleSpacing;

  final bool scrollable;

  /// Portion of `MediaQuery.of(context).size.height`
  ///
  /// Defaults to 0.5
  final double contentHeightExtent;

  const ModalSheet({
    super.key,
    this.title,
    this.child,
    this.leading,
    this.trailing,
    this.contentHeightExtent = 0.5,
    this.topSpacing = 16.0,
    this.titleSpacing = 16.0,
    this.leadingSpacing = 8.0,
    this.trailingSpacing = 8.0,
    required this.scrollable,
  });

  @override
  Widget build(BuildContext context) {
    final Widget? title = this.title == null
        ? null
        : DefaultTextStyle(
            style: context.textTheme.headlineSmall!,
            child: this.title!,
          );

    final Widget? content = switch ((child, scrollable)) {
      (null, _) => null,
      (Widget child, false) => child,
      (Widget scrollableChild, true) => ConstrainedBox(
          constraints: BoxConstraints.loose(
            Size(
              double.infinity,
              MediaQuery.of(context).size.height * contentHeightExtent,
            ),
          ),
          child: scrollableChild,
        ),
    };

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: topSpacing),
          if (title != null) title,
          if (title != null && (leading != null || content != null))
            SizedBox(height: titleSpacing),
          if (leading != null) ...[
            leading!,
            SizedBox(height: leadingSpacing),
          ],
          if (content != null) content,
          if (trailing != null) ...[
            SizedBox(height: trailingSpacing),
            trailing!,
          ],
        ],
      ),
    );
  }
}

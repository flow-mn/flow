import 'dart:math';

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

  /// If [scrollableContentMaxHeight] is less than [this], [this] will be used instead of max height.
  ///
  /// Scroll content height: `math.max(scrollableContentMaxHeight, minScrollableContentHeight)`
  final double minScrollableContentHeight;
  final double scrollableContentMaxHeight;

  const ModalSheet({
    super.key,
    this.title,
    this.child,
    this.leading,
    this.trailing,
    this.topSpacing = 16.0,
    this.titleSpacing = 16.0,
    this.leadingSpacing = 8.0,
    this.trailingSpacing = 8.0,
  })  : scrollable = false,
        scrollableContentMaxHeight = 0,
        minScrollableContentHeight = 0;

  const ModalSheet.scrollable({
    super.key,
    this.title,
    this.child,
    this.leading,
    this.trailing,
    this.minScrollableContentHeight = 280.0,
    this.topSpacing = 16.0,
    this.titleSpacing = 16.0,
    this.leadingSpacing = 8.0,
    this.trailingSpacing = 8.0,
    required this.scrollableContentMaxHeight,
  }) : scrollable = true;

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
      (Widget scrollableChild, true) => AnimatedContainer(
          constraints: BoxConstraints.loose(
            Size(
              double.infinity,
              max(minScrollableContentHeight, scrollableContentMaxHeight),
            ),
          ),
          duration: const Duration(milliseconds: 200),
          child: scrollableChild,
        ),
    };

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SafeArea(
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
      ),
    );
  }
}

import "dart:math";

import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

class ModalSheet extends StatelessWidget {
  final Widget? title;

  final Widget? child;

  final Widget? leading;
  final Widget? trailing;

  final double leadingSpacing;
  final double trailingSpacing;

  /// Defaults to `40.0`
  ///
  /// Set this to `0.0` to make bottom sheet contact with the system navigation
  /// bar
  ///
  /// This has no effect when [scrollable] is `false`
  final double topMargin;
  final double titleSpacing;

  final bool scrollable;

  /// If [scrollableContentMaxHeight] is less than [this], [this] will be used instead of max height.
  ///
  /// Scroll content height: `math.max(scrollableContentMaxHeight, minScrollableContentHeight)`
  ///
  /// Defaults to `64.0`
  final double minScrollableContentHeight;
  final double scrollableContentMaxHeight;

  const ModalSheet({
    super.key,
    this.title,
    this.child,
    this.leading,
    this.trailing,
    this.topMargin = 40.0,
    this.titleSpacing = 16.0,
    this.leadingSpacing = 8.0,
    this.trailingSpacing = 8.0,
  }) : scrollable = false,
       scrollableContentMaxHeight = 0,
       minScrollableContentHeight = 0;

  /// [scrollableContentMaxHeight] defaults to 50% of the screen height.
  ///
  /// Setting [scrollableContentMaxHeight] to `0.0` will result in the default behaviour.
  const ModalSheet.scrollable({
    super.key,
    this.title,
    this.child,
    this.leading,
    this.trailing,
    this.minScrollableContentHeight = 64.0,
    this.topMargin = 40.0,
    this.titleSpacing = 16.0,
    this.leadingSpacing = 8.0,
    this.trailingSpacing = 8.0,
    this.scrollableContentMaxHeight = 0.0,
  }) : scrollable = true;

  @override
  Widget build(BuildContext context) {
    final Widget? title =
        this.title == null
            ? null
            : DefaultTextStyle(
              style: context.textTheme.headlineSmall!,
              textAlign: TextAlign.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: this.title!,
              ),
            );

    return Container(
      padding: MediaQuery.of(context).viewInsets,
      constraints: BoxConstraints.loose(
        Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height - topMargin,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (scrollable)
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                width: 30.0,
                height: 6.0,
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurface.withAlpha(0x80),
                  borderRadius: BorderRadius.circular(24.0),
                ),
              ),
            SizedBox(height: titleSpacing),
            if (title != null) title,
            if (title != null && (leading != null || child != null))
              SizedBox(height: titleSpacing),
            if (leading != null) ...[
              leading!,
              SizedBox(height: leadingSpacing),
            ],
            if (child != null)
              Flexible(
                child: Builder(builder: (context) => buildContent(context)),
              ),
            if (trailing != null) ...[
              SizedBox(height: trailingSpacing),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    if (!scrollable) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: child,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxScrollableContentHeight =
            scrollableContentMaxHeight == 0.0
                ? (MediaQuery.of(context).size.height * 0.5)
                : scrollableContentMaxHeight;

        return AnimatedContainer(
          constraints: BoxConstraints.loose(
            Size(
              double.infinity,
              min(
                max(minScrollableContentHeight, maxScrollableContentHeight),
                constraints.maxHeight,
              ),
            ),
          ),
          duration: const Duration(milliseconds: 200),
          child: child,
        );
      },
    );
  }
}

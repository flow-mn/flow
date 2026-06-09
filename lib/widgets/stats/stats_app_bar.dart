import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

/// The shared app bar for full-screen analytics pages.
///
/// A flat surface bar that only lifts a hairline shadow once content scrolls
/// under it. Extracted so the six stats pages share one definition instead of
/// each repeating the same elevation/tint configuration.
class StatsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const StatsAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      elevation: 0.0,
      scrolledUnderElevation: 1.0,
      centerTitle: false,
      shadowColor: context.colorScheme.onSurface.withAlpha(0x40),
      backgroundColor: context.colorScheme.surface,
      surfaceTintColor: kTransparent,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

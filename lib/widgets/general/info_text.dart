import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class InfoText extends StatelessWidget {
  /// Centers the text and icon vertically instead of top
  final bool singleLine;

  final Widget child;

  final IconData icon;

  const InfoText({
    super.key,
    required this.child,
    this.singleLine = false,
    this.icon = Symbols.info_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          singleLine ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          fill: 0,
          color: context.flowColors.semi,
          size: 16.0,
        ),
        const SizedBox(width: 4.0),
        Flexible(
          child: DefaultTextStyle(
            style: context.textTheme.bodySmall!.semi(context),
            child: child,
          ),
        ),
      ],
    );
  }
}

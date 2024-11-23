import "package:auto_size_text/auto_size_text.dart";
import "package:flow/data/money.dart";
import "package:flutter/material.dart";

class MoneyTextRaw extends StatelessWidget {
  final String text;
  final Money? money;

  /// When true, renders [AutoSizeText]
  ///
  /// When false, renders [Text]
  final bool autoSize;

  /// Pass an [AutoSizeGroup] to synchronize
  /// fontSize among multiple [AutoSizeText]s
  final AutoSizeGroup? autoSizeGroup;

  final int maxLines;

  final TextAlign? textAlign;
  final TextStyle? style;

  final VoidCallback? onTap;

  const MoneyTextRaw({
    super.key,
    this.money,
    required this.text,
    this.autoSize = false,
    this.autoSizeGroup,
    required this.maxLines,
    this.textAlign,
    this.style,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final Widget child = autoSize
        ? AutoSizeText(
            text,
            group: autoSizeGroup,
            style: style,
            maxLines: maxLines,
            textAlign: textAlign,
            semanticsLabel: money?.toSemanticLabel() ?? text,
          )
        : Text(
            text,
            style: style,
            maxLines: maxLines,
            textAlign: textAlign,
            semanticsLabel: money?.toSemanticLabel() ?? text,
          );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    }

    return child;
  }
}

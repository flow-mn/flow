import "package:flutter/material.dart";

/// Renders a localized [template] containing a single `{value}` token, with the
/// substituted [value] styled via [valueStyle] (bold by default) and the rest
/// of the sentence in the ambient text style.
///
/// Lets narrative analytics copy stay translatable — the whole sentence lives
/// in one l10n key — while still emphasizing the dynamic part.
class EmphasizedText extends StatelessWidget {
  final String template;
  final String value;
  final TextStyle? valueStyle;

  const EmphasizedText({
    super.key,
    required this.template,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    const String token = "{value}";
    final int index = template.indexOf(token);

    if (index < 0) {
      return Text(template.replaceAll(token, value));
    }

    final String before = template.substring(0, index);
    final String after = template.substring(index + token.length);

    return Text.rich(
      TextSpan(
        children: [
          if (before.isNotEmpty) TextSpan(text: before),
          TextSpan(
            text: value,
            style: valueStyle ?? const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (after.isNotEmpty) TextSpan(text: after),
        ],
      ),
    );
  }
}

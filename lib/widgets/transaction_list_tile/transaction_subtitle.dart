import "package:flutter/material.dart";

class TransactionSubtitle extends StatelessWidget {
  final List<InlineSpan> components;

  const TransactionSubtitle({super.key, required this.components});

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    const TextSpan divider = TextSpan(text: " • ");

    final List<InlineSpan> orderedComponents = [
      for (int i = 0; i < components.length; i++) ...[
        if (i != 0) divider,
        components[i],
      ],
    ];

    return RichText(
      text: TextSpan(
        children: textDirection == TextDirection.ltr
            ? orderedComponents
            : orderedComponents.reversed.toList(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

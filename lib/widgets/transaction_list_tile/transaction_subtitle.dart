import "package:flutter/material.dart";

class TransactionSubtitle extends StatelessWidget {
  final List<InlineSpan> components;

  const TransactionSubtitle({super.key, required this.components});

  @override
  Widget build(BuildContext context) {
    const TextSpan divider = TextSpan(text: " • ");

    return RichText(
      text: TextSpan(
        children: [
          for (int i = 0; i < components.length; i++) ...[
            if (i != 0) divider,
            components[i],
          ],
        ],
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

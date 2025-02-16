import "package:flow/data/transaction_filter.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

/// Renders a row of [TransactionFilterChip]s.
class TransactionFilterHead extends StatelessWidget {
  final TransactionFilter value;

  /// Usually List of [TransactionFilterChip]s
  final List<Widget> filterChips;

  final EdgeInsets? padding;

  const TransactionFilterHead({
    super.key,
    required this.filterChips,
    this.value = TransactionFilter.empty,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];

    for (final chip in filterChips) {
      children.add(chip);
      children.add(const SizedBox(width: 12.0));
    }

    if (children.isNotEmpty && children.last is SizedBox) {
      children.removeLast();
    }

    return Container(
      height: 48.0,
      width: double.infinity,
      color: context.colorScheme.surface,
      child: SingleChildScrollView(
        padding: padding,
        scrollDirection: Axis.horizontal,
        child: Row(children: children),
      ),
    );
  }
}

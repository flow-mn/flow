import 'package:flow/data/transactions_filter.dart';
import 'package:flutter/material.dart';

/// Renders a row of [TransactionFilterChip]s.
class TransactionFilterHead extends StatelessWidget {
  final TransactionFilter value;

  /// Usually List of [TransactionFilterChip]s
  final List<Widget> filterChips;

  const TransactionFilterHead({
    super.key,
    required this.filterChips,
    this.value = TransactionFilter.empty,
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

    return SizedBox(
      height: 48.0,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: children,
        ),
      ),
    );
  }
}

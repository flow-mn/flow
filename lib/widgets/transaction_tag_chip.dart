import "package:flow/entity/transaction_tag.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";

class TransactionTagChip extends StatelessWidget {
  final TransactionTag tag;
  final bool selected;

  final VoidCallback? onPressed;

  const TransactionTagChip({
    super.key,
    required this.tag,
    this.selected = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final FlowColorScheme? colorScheme = tag.colorScheme;

    return InputChip(
      label: Text(tag.title),
      selected: selected,
      onPressed: onPressed ?? () {},
      showCheckmark: false,
      avatar: FlowIcon(tag.icon, colorScheme: colorScheme, size: 16.0),
    );
  }
}

import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class TransactionTagAddChip extends StatelessWidget {
  final VoidCallback? onPressed;

  const TransactionTagAddChip({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text("transaction.tags.new".t(context)),
      selected: false,
      onPressed: onPressed ?? () {},
      showCheckmark: false,
      avatar: FlowIcon(FlowIconData.icon(Symbols.add_rounded), size: 16.0),
    );
  }
}

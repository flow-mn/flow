import "package:flow/data/flow_icon.dart";
import "package:flow/entity/transaction_tag.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/widgets/transaction_tag_chip.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class TransactionTagAddChip extends StatelessWidget {
  final String? title;

  final VoidCallback? onPressed;

  const TransactionTagAddChip({super.key, this.onPressed, this.title});

  @override
  Widget build(BuildContext context) {
    return TransactionTagChip(
      tag: TransactionTag(
        title: title ?? "transaction.tags.new".t(context),
        iconCode: FlowIconData.icon(Symbols.add_rounded).toString(),
      ),
      selected: false,
      isSuggestion: false,
      onPressed: onPressed ?? () {},
    );
  }
}

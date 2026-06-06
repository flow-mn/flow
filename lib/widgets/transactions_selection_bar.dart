import "package:flow/l10n/extensions.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/transactions_selection_controller.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";

/// Persistent bottom overlay shown while [controller.active].
class TransactionsSelectionBottomBar extends StatelessWidget {
  final TransactionsSelectionController controller;
  final VoidCallback onClose;
  final VoidCallback onNext;
  final VoidCallback onSelectAll;

  const TransactionsSelectionBottomBar({
    super.key,
    required this.controller,
    required this.onClose,
    required this.onNext,
    required this.onSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = controller.count > 0;

    return Material(
      color: context.colorScheme.surfaceContainerHigh,
      elevation: 8.0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 8.0,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Symbols.close_rounded),
                tooltip: "general.cancel".t(context),
                onPressed: onClose,
              ),
              const SizedBox(width: 4.0),
              Expanded(
                child: Text(
                  "transaction.bulk.selected".t(context, controller.count),
                  style: context.textTheme.titleMedium?.semi(context),
                ),
              ),
              IconButton(
                icon: const Icon(Symbols.select_all_rounded),
                tooltip: "transaction.bulk.selectAll".t(context),
                onPressed: onSelectAll,
              ),
              const SizedBox(width: 4.0),
              FilledButton.icon(
                onPressed: hasSelection ? onNext : null,
                icon: const Icon(Symbols.arrow_forward_rounded),
                label: Text("general.next".t(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

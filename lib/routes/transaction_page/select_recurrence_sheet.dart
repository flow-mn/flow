import "package:flow/l10n/extensions.dart";
import "package:flow/routes/transaction_page/select_recurrence.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:recurrence/recurrence.dart";

/// Pops with a [Recurrence] if the user saves, otherwise pops with `null`
class SelectRecurrenceSheet extends StatefulWidget {
  final Recurrence? initialValue;

  final TimeRange? startBounds;

  const SelectRecurrenceSheet({super.key, this.initialValue, this.startBounds});

  @override
  State<SelectRecurrenceSheet> createState() => _SelectRecurrenceSheetState();
}

class _SelectRecurrenceSheetState extends State<SelectRecurrenceSheet> {
  Recurrence? _recurrence;

  @override
  void initState() {
    super.initState();
    _recurrence = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("transaction.recurring.setup".t(context)),
      trailing: ModalOverflowBar(
        alignment: .end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Symbols.close_rounded),
            label: Text("general.cancel".t(context)),
          ),
          TextButton.icon(
            onPressed: () => context.pop(_recurrence),
            icon: const Icon(Symbols.check_rounded),
            label: Text("general.save".t(context)),
          ),
        ],
      ),
      child: SelectRecurrence(
        onChanged: (value) => setState(() => _recurrence = value),
        startBounds: widget.startBounds,
        initialValue: widget.initialValue,
      ),
    );
  }
}

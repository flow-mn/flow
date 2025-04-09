import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

enum RecurrenceMode {
  everyDay("everyDay"),
  everyWeek("everyWeek"),
  every2Week("every2Week"),
  everyMonth("everyMonth"),
  everyYear("everyYear"),
  custom("custom");

  final String value;

  const RecurrenceMode(this.value);
}

class SelectRecurrenceModeSheet extends StatelessWidget {
  const SelectRecurrenceModeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("select.recurrence".t(context)),
      trailing: ModalOverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(null),
            icon: const Icon(Symbols.close_rounded),
            label: Text("general.cancel".t(context)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                ActionChip(
                  label: Text("select.recurrence.everyMonth".t(context)),
                  onPressed: () => context.pop(RecurrenceMode.everyMonth),
                ),
                ActionChip(
                  label: Text("select.recurrence.everyWeek".t(context)),
                  onPressed: () => context.pop(RecurrenceMode.everyWeek),
                ),
                ActionChip(
                  label: Text("select.recurrence.every2Week".t(context)),
                  onPressed: () => context.pop(RecurrenceMode.every2Week),
                ),
                ActionChip(
                  label: Text("select.recurrence.everyYear".t(context)),
                  onPressed: () => context.pop(RecurrenceMode.everyYear),
                ),
                ActionChip(
                  label: Text("select.recurrence.everyDay".t(context)),
                  onPressed: () => context.pop(RecurrenceMode.everyDay),
                ),
                ActionChip(
                  label: Text("select.recurrence.custom".t(context)),
                  onPressed: () => context.pop(RecurrenceMode.custom),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

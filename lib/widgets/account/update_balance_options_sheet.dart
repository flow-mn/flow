import "package:flow/l10n/extensions.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Pops with [ValueOr<DateTime>]
class UpdateBalanceOptionsSheet extends StatelessWidget {
  const UpdateBalanceOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("account.updateBalance.chooseUpdateMode".t(context)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("account.updateBalance.updateCurrent".t(context)),
              // leading: FlowIcon(category.icon),
              trailing: const Icon(Symbols.chevron_right_rounded),
              onTap: () => context.pop(Optional<DateTime>(null)),
            ),
            ListTile(
              title: Text("account.updateBalance.updateAtDate".t(context)),
              subtitle: Text(
                "account.updateBalance.updateAtDate.description".t(context),
              ),
              // leading: FlowIcon(category.icon),
              trailing: const Icon(Symbols.chevron_right_rounded),
              onTap: () => _selectDateAndTimeAndPop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDateAndTimeAndPop(BuildContext context) async {
    final DateTime? dateResult = await showDatePicker(
      context: context,
      firstDate: Moment.minValue,
      lastDate: Moment.maxValue,
    );

    if (dateResult == null) return;
    if (!context.mounted) return;

    final TimeOfDay? timeResult = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (timeResult == null) return;
    if (!context.mounted) return;

    context.pop(
      Optional<DateTime>(
        dateResult.copyWith(hour: timeResult.hour, minute: timeResult.minute),
      ),
    );
  }
}

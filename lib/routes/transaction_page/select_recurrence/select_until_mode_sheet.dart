import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/routes/transaction_page/select_recurrence.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

/// Pops with a [RecurrenceUntilMode]
class SelectUntilModeSheet extends StatelessWidget {
  const SelectUntilModeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("select.recurrence.until".t(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: RecurrenceUntilMode.values
            .map(
              (value) => ListTile(
                title: Text(value.localizedNameContext(context)),
                onTap: () {
                  context.pop(value);
                },
                trailing: const DirectionalChevron(),
              ),
            )
            .toList(),
      ),
    );
  }
}

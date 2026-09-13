import "package:flow/data/flow_button_type.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class SelectFlowButtonTypeSheet extends StatelessWidget {
  final List<FlowButtonType> types;

  const SelectFlowButtonTypeSheet({super.key, required this.types});

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("transaction.new".t(context)),
      trailing: ModalOverflowBar(
        alignment: .end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(null),
            icon: const Icon(Symbols.close_rounded),
            label: Text("general.cancel".t(context)),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: types
              .map(
                (value) => ListTile(
                  leading: Icon(value.icon),
                  title: Text(value.localizedNameContext(context)),
                  trailing: const LeChevron(),
                  onTap: () => context.pop(value),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

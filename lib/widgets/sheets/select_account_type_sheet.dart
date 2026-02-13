import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class SelectAccountTypeSheet extends StatelessWidget {
  final AccountType? currentlySelected;

  const SelectAccountTypeSheet({super.key, this.currentlySelected});

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("account.type".t(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: AccountType.values
            .where((value) => value != AccountType.creditLine)
            .map(
              (value) => ListTile(
                title: Text(value.localizedNameContext(context)),
                selected: currentlySelected == value,
                trailing: const LeChevron(),
                onTap: () => context.pop(value),
              ),
            )
            .toList(),
      ),
    );
  }
}

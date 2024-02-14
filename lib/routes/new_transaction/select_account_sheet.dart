import 'package:flow/entity/account.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flow/widgets/general/modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Pops with [Account]
class SelectAccountSheet extends StatelessWidget {
  final List<Account> accounts;
  final int? currentlySelectedAccountId;

  const SelectAccountSheet({
    super.key,
    required this.accounts,
    this.currentlySelectedAccountId,
  });

  @override
  Widget build(BuildContext context) {
    return ModalSheet(
      scrollable: false,
      title: Text("transaction.edit.selectAccount".t(context)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...accounts.map(
              (account) => ListTile(
                title: Text(account.name),
                leading: FlowIcon(account.icon),
                trailing: const Icon(Symbols.chevron_right_rounded),
                onTap: () => context.pop(account),
                selected: currentlySelectedAccountId == account.id,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

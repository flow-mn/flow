import 'package:flow/entity/account.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/general/bottom_sheet_frame.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

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
    return BottomSheetFrame(
      scrollable: true,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 16.0),
        Text(
          "transaction.edit.selectAccount".t(context),
          style: context.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16.0),
        ...accounts.map(
          (account) => ListTile(
            title: Text(account.name),
            leading: Icon(account.icon),
            trailing: const Icon(Symbols.chevron_right_rounded),
            onTap: () => context.pop(account),
            selected: currentlySelectedAccountId == account.id,
          ),
        ),
      ]),
    );
  }
}

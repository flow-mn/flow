import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with [Account]
class SelectAccountSheet extends StatelessWidget {
  final List<Account> accounts;
  final int? currentlySelectedAccountId;

  final String? titleOverride;

  const SelectAccountSheet({
    super.key,
    required this.accounts,
    this.currentlySelectedAccountId,
    this.titleOverride,
  });

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text(titleOverride ?? "transaction.edit.selectAccount".t(context)),
      scrollableContentMaxHeight: MediaQuery.of(context).size.height * .5,
      trailing: accounts.isEmpty
          ? ModalOverflowBar(
              alignment: MainAxisAlignment.end,
              children: [
                Button(
                  onTap: () => context.pop(),
                  child: Text(
                    "general.cancel".t(context),
                  ),
                ),
              ],
            )
          : null,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (accounts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "transaction.edit.selectAccount.noPossibleChoice".t(context),
                  textAlign: TextAlign.center,
                ),
              ),
            ...accounts.map(
              (account) => ListTile(
                title: Text(account.name),
                subtitle: MoneyText(
                  account.balance,
                  tapToToggleAbbreviation: true,
                  initiallyAbbreviated: false,
                  autoSize: true,
                  overrideObscure: false,
                ),
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

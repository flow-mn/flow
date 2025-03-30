import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/utils/simple_query_sorter.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with [Account]
class SelectAccountSheet extends StatefulWidget {
  final List<Account> accounts;
  final int? currentlySelectedAccountId;

  final String? titleOverride;

  final bool showBalance;

  final bool showTrailing;

  /// Defaults to [true] when there are more than 8 categories.
  final bool? showSearchBar;

  const SelectAccountSheet({
    super.key,
    required this.accounts,
    this.currentlySelectedAccountId,
    this.titleOverride,
    this.showSearchBar,
    this.showBalance = false,
    this.showTrailing = true,
  });

  @override
  State<SelectAccountSheet> createState() => _SelectAccountSheetState();
}

class _SelectAccountSheetState extends State<SelectAccountSheet> {
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final bool showSearchBar =
        widget.showSearchBar ?? widget.accounts.length > 8;

    final List<Account> results = simpleSortByQuery(widget.accounts, _query);

    return ModalSheet.scrollable(
      title: Text(
        widget.titleOverride ?? "transaction.edit.selectAccount".t(context),
      ),
      trailing:
          widget.accounts.isEmpty
              ? ModalOverflowBar(
                alignment: MainAxisAlignment.end,
                children: [
                  Button(
                    onTap: () => context.pop(),
                    child: Text("general.cancel".t(context)),
                  ),
                ],
              )
              : null,
      leading:
          showSearchBar
              ? Frame(
                child: TextField(
                  autofocus: true,
                  onChanged: (value) => setState(() => _query = value),
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "general.search".t(context),
                    prefixIcon: const Icon(Symbols.search_rounded),
                  ),
                ),
              )
              : null,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (results.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "transaction.edit.selectAccount.noPossibleChoice".t(context),
                  textAlign: TextAlign.center,
                ),
              ),
            ...results.map(
              (account) => ListTile(
                key: ValueKey(account.uuid),
                title: Text(account.name),
                subtitle:
                    widget.showBalance
                        ? MoneyText(
                          account.balance,
                          initiallyAbbreviated: false,
                          autoSize: true,
                          overrideObscure: false,
                        )
                        : null,
                leading: FlowIcon(account.icon),
                trailing:
                    widget.showTrailing
                        ? const Icon(Symbols.chevron_right_rounded)
                        : null,
                onTap: () => context.pop(account),
                selected: widget.currentlySelectedAccountId == account.id,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

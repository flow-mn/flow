import 'package:flow/entity/account.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/widgets/general/modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Pops with [List] of selected [Account]s
class SelectMultiAccountSheet extends StatefulWidget {
  final List<Account> accounts;
  final List<String>? selectedUuids;

  final String? titleOverride;

  const SelectMultiAccountSheet({
    super.key,
    required this.accounts,
    this.titleOverride,
    this.selectedUuids,
  });

  @override
  State<SelectMultiAccountSheet> createState() =>
      _SelectMultiAccountSheetState();
}

class _SelectMultiAccountSheetState extends State<SelectMultiAccountSheet> {
  late Set<String> selectedUuids;

  @override
  void initState() {
    super.initState();
    selectedUuids = Set.from(widget.selectedUuids ?? (const []));
  }

  @override
  void didUpdateWidget(SelectMultiAccountSheet oldWidget) {
    if (widget.selectedUuids != oldWidget.selectedUuids) {
      selectedUuids = Set.from(widget.selectedUuids ?? (const []));
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text(
          widget.titleOverride ?? "transaction.edit.selectAccount".t(context)),
      scrollableContentMaxHeight: MediaQuery.of(context).size.height * .5,
      trailing: OverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(<Account>[]),
            icon: const Icon(Symbols.block_rounded),
            label: Text("transactions.query.clearSelection".t(context)),
          ),
          TextButton.icon(
            onPressed: pop,
            icon: const Icon(Symbols.check),
            label: Text("general.done".t(context)),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.accounts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "transaction.edit.selectAccount.noPossibleChoice".t(context),
                  textAlign: TextAlign.center,
                ),
              ),
            ...widget.accounts.map(
              (account) => CheckboxListTile.adaptive(
                title: Text(account.name),
                // leading: FlowIcon(account.icon),
                // trailing: const Icon(Symbols.chevron_right_rounded),
                // onTap: () => context.pop(account),
                value: selectedUuids.contains(account.uuid),
                onChanged: (value) => select(account.uuid, value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void select(String uuid, bool? selected) {
    if (selected == null) return;

    if (selectedUuids.contains(uuid)) {
      selectedUuids.remove(uuid);
    } else {
      selectedUuids.add(uuid);
    }

    setState(() {});
  }

  void pop() {
    final List<Account> selectedAccounts = widget.accounts
        .where((account) => selectedUuids.contains(account.uuid))
        .toList();

    context.pop(selectedAccounts);
  }
}

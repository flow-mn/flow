import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/utils/simple_query_sorter.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with [List] of selected [Account]s
class SelectMultiAccountSheet extends StatefulWidget {
  final List<Account> accounts;
  final List<String>? selectedUuids;

  final String? titleOverride;

  /// Defaults to [true] when there are more than 8 accounts.
  final bool? showSearchBar;

  const SelectMultiAccountSheet({
    super.key,
    required this.accounts,
    this.titleOverride,
    this.selectedUuids,
    this.showSearchBar,
  });

  @override
  State<SelectMultiAccountSheet> createState() =>
      _SelectMultiAccountSheetState();
}

class _SelectMultiAccountSheetState extends State<SelectMultiAccountSheet> {
  String _query = "";

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
    final bool showSearchBar =
        widget.showSearchBar ?? widget.accounts.length > 8;

    final List<Account> results = simpleSortByQuery(widget.accounts, _query);

    return ModalSheet.scrollable(
      title: Text(
        widget.titleOverride ?? "transaction.edit.selectAccount".t(context),
      ),
      trailing: ModalOverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(<Account>[]),
            icon: const Icon(Symbols.block_rounded),
            label: Text("transactions.query.clearSelection".t(context)),
          ),
          TextButton.icon(
            onPressed: pop,
            icon: const Icon(Symbols.check_rounded),
            label: Text("general.done".t(context)),
          ),
        ],
      ),
      leading:
          showSearchBar
              ? Frame(
                child: TextField(
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
              (account) => CheckboxListTile(
                key: ValueKey(account.uuid),
                title: Text(account.name),
                value: selectedUuids.contains(account.uuid),
                onChanged: (value) => select(account.uuid, value),
                secondary: FlowIcon(account.icon),
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
    final List<Account> selectedAccounts =
        widget.accounts
            .where((account) => selectedUuids.contains(account.uuid))
            .toList();

    context.pop(selectedAccounts);
  }
}

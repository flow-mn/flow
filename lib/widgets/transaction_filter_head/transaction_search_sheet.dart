import "package:flow/data/transactions_filter.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with [TransactionSearchData]
class TransactionSearchSheet extends StatefulWidget {
  final TransactionSearchData? searchData;

  const TransactionSearchSheet({super.key, this.searchData});

  @override
  State<TransactionSearchSheet> createState() => _TransactionSearchSheetState();
}

class _TransactionSearchSheetState extends State<TransactionSearchSheet> {
  late TransactionSearchData _searchData;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _searchData = widget.searchData ?? const TransactionSearchData();
    _controller = TextEditingController(text: _searchData.keyword);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("transactions.query.filter.keyword".t(context)),
      trailing: OverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: clear,
            icon: const Icon(Symbols.block_rounded),
            label: Text("transactions.query.filter.keyword.clear".t(context)),
          ),
          TextButton.icon(
            onPressed: pop,
            icon: const Icon(Symbols.check),
            label: Text("general.done".t(context)),
          ),
        ],
      ),
      scrollableContentMaxHeight: MediaQuery.of(context).size.height * 0.5,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                autofocus: true,
                controller: _controller,
                onSubmitted: (_) => pop(),
                decoration: InputDecoration(
                  hintText: "transactions.query.filter.keyword.hint".t(context),
                  prefixIcon: const Icon(Symbols.search_rounded),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _updateText() {
    _searchData = _searchData.copyWithOptional(
      keyword: Optional(_controller.text),
    );

    if (!mounted) return;

    setState(() {});
  }

  void clear() {
    _updateText();
    context.pop(const TransactionSearchData());
  }

  void pop() {
    _updateText();
    context.pop(_searchData);
  }
}

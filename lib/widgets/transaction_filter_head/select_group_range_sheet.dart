import "package:flow/data/transaction_filter.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with [TransactionSearchData]
class SelectGroupRangeSheet extends StatefulWidget {
  final TransactionGroupRange? selected;

  const SelectGroupRangeSheet({super.key, this.selected});

  @override
  State<SelectGroupRangeSheet> createState() => _SelectGroupRangeSheetState();
}

class _SelectGroupRangeSheetState extends State<SelectGroupRangeSheet> {
  late TransactionGroupRange _selected;

  @override
  void initState() {
    _selected = widget.selected ?? TransactionGroupRange.day;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("transactions.query.filter.groupBy".t(context)),
      trailing: ModalOverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: pop,
            icon: const Icon(Symbols.check_rounded),
            label: Text("general.done".t(context)),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Frame(
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children:
                  TransactionGroupRange.values
                      .map(
                        (range) => ChoiceChip(
                          label: Text(range.localizedNameContext(context)),
                          selected: _selected == range,
                          onSelected:
                              (value) => _updateRange(value ? range : null),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _updateRange(TransactionGroupRange? value) {
    if (value == null) {
      return;
    }

    _selected = value;

    if (!mounted) return;

    setState(() {});
  }

  void pop() {
    context.pop(_selected);
  }
}

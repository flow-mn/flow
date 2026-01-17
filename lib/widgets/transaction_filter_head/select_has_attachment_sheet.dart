import "package:flow/l10n/extensions.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with an [Optional]\<bool> indicating whether to filter for transactions
class SelectHasAttachmentSheet extends StatefulWidget {
  final bool? initialSelected;

  const SelectHasAttachmentSheet({super.key, this.initialSelected});

  @override
  State<SelectHasAttachmentSheet> createState() =>
      _SelectHasAttachmentSheetState();
}

class _SelectHasAttachmentSheetState extends State<SelectHasAttachmentSheet> {
  bool? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
  }

  @override
  void didUpdateWidget(covariant SelectHasAttachmentSheet oldWidget) {
    if (widget.initialSelected != oldWidget.initialSelected) {
      _selected = widget.initialSelected;
    }
    super.didUpdateWidget(oldWidget);
  }

  String suffix(bool? value) => switch (value) {
    null => ".all".t(context),
    true => "#true".t(context),
    false => "#false".t(context),
  };

  @override
  Widget build(BuildContext context) {
    return ModalSheet(
      title: Text("transactions.query.filter.hasAttachments".t(context)),
      trailing: ModalOverflowBar(
        alignment: .end,
        children: [
          TextButton.icon(
            onPressed: pop,
            icon: const Icon(Symbols.check_rounded),
            label: Text("general.done".t(context)),
          ),
        ],
      ),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Wrap(
          spacing: 12.0,
          runSpacing: 8.0,
          children: [null, true, false]
              .map(
                (value) => ChoiceChip(
                  label: Text(
                    "transactions.query.filter.hasAttachments${suffix(value)}"
                        .t(context),
                  ),
                  selected: _selected == value,
                  onSelected: (selected) {
                    setState(() {
                      _selected = value;
                    });
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void pop() {
    context.pop(Optional<bool>(_selected));
  }
}

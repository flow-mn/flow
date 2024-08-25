import "package:flow/l10n/flow_localizations.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";

class YearSelectorSheet extends StatefulWidget {
  final DateTime? initialDate;

  const YearSelectorSheet({
    super.key,
    this.initialDate,
  });

  @override
  State<YearSelectorSheet> createState() => _YearSelectorSheetState();
}

class _YearSelectorSheetState extends State<YearSelectorSheet> {
  late final TextEditingController _yearController;

  @override
  void initState() {
    super.initState();

    final DateTime current = widget.initialDate ?? DateTime.now();

    _yearController = TextEditingController(text: current.year.toString());
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet(
      title: Text("general.timeSelector.select.year".t(context)),
      trailing: OverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => setState(() {
              final DateTime now = DateTime.now();
              _yearController.text = now.year.toString();
            }),
            child: Text(
              "general.timeSelector.now".t(context),
            ),
          ),
          Button(
            onTap: pop,
            child: Text(
              "general.done".t(context),
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _yearController,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            autofocus: true,
            onSubmitted: (_) => pop(),
          )
        ],
      ),
    );
  }

  void pop() {
    final int? year = int.tryParse(_yearController.text);

    if (year == null || year <= 0 || year > 3000) {
      context.pop(null);
    } else {
      context.pop(DateTime(year));
    }
  }
}

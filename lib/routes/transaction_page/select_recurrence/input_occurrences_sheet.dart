import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class InputOccurrencesSheet extends StatefulWidget {
  final int? initialValue;

  const InputOccurrencesSheet({super.key, this.initialValue});

  @override
  State<InputOccurrencesSheet> createState() => _InputOccurrencesSheetState();
}

class _InputOccurrencesSheetState extends State<InputOccurrencesSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue?.toString() ?? "1",
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("select.recurrence.occurrences".t(context)),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12.0,
        crossAxisAlignment: .start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, value, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    spacing: 12.0,
                    children: [3, 4, 6, 7, 14, 21, 30, 36, 48]
                        .map(
                          (value) => FilterChip(
                            showCheckmark: false,
                            key: ValueKey(value),
                            label: Text(
                              "select.recurrence.occurrences.n".t(
                                context,
                                value.toString(),
                              ),
                            ),
                            onSelected: (bool selected) {
                              if (selected) {
                                _controller.text = value.toString();
                              }
                            },
                            selected: value.toString() == _controller.text,
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),
          Frame(
            child: TextField(
              controller: _controller,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => pop(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: "select.recurrence.occurrences.times.prefix".t(
                  context,
                ),
                suffixText: "select.recurrence.occurrences.times.suffix".t(
                  context,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void pop() {
    context.pop((int.tryParse(_controller.text) ?? 1).clamp(1, 1000000));
  }
}

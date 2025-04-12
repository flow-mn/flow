import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";
import "package:recurrence/recurrence.dart";

class SelectRecurrenceSheet extends StatefulWidget {
  final Recurrence? initialValue;

  const SelectRecurrenceSheet({super.key, this.initialValue});

  @override
  State<SelectRecurrenceSheet> createState() => SelectRecurrenceSheetState();
}

class SelectRecurrenceSheetState extends State<SelectRecurrenceSheet> {
  late Recurrence recurrence;

  @override
  void initState() {
    super.initState();

    recurrence =
        widget.initialValue ??
        Recurrence(range: TimeRange.allTime(), rules: []);
  }

  @override
  void didUpdateWidget(SelectRecurrenceSheet oldWidget) {
    if (oldWidget.initialValue != widget.initialValue) {
      recurrence =
          widget.initialValue ??
          Recurrence(range: TimeRange.allTime(), rules: []);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("select.recurrence.select".t(context)),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

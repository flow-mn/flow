import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/sheets/select_recurrence_mode_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
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

  void pop() {
    context.pop(recurrence);
  }

  void _addRecurrence(RecurrenceMode? mode, DateTime? anchor) {
    if (mode == null) return;

    void addSimple(RecurrenceRule addRule) {
      if (!recurrence.rules.any(
        (rule) => rule.serialize() == addRule.serialize(),
      )) {
        recurrence = Recurrence(
          range: recurrence.range,
          rules: [...recurrence.rules, addRule],
        );
      }
    }

    switch (mode) {
      case RecurrenceMode.everyDay:
        return addSimple(IntervalRecurrenceRule(data: const Duration(days: 1)));
      case RecurrenceMode.everyWeek:
        // Select day of week, then proceed adding
        throw UnimplementedError();
      case RecurrenceMode.every2Week:
        // Select day of week, then proceed adding
        throw UnimplementedError();
      case RecurrenceMode.everyMonth:
        // Select day of month, then proceed adding
        throw UnimplementedError();
      case RecurrenceMode.everyYear:
        // Select month and day, then proceed adding
        throw UnimplementedError();
      case RecurrenceMode.custom:
        // Define custom recurrence rules
        throw UnimplementedError();
    }
  }
}

import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/prefs/custom_cycles.dart";
import "package:flow/widgets/sheets/select_time_range_mode_sheet.dart";
import "package:flow/utils/time_and_range.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

final Map<TransactionFilterTimeRange, TimeRangeMode> filterRangeToModeMapping =
    {
      TransactionFilterTimeRange.last30Days: TimeRangeMode.last30Days,
      TransactionFilterTimeRange.thisWeek: TimeRangeMode.thisWeek,
      TransactionFilterTimeRange.thisMonth: TimeRangeMode.thisMonth,
      TransactionFilterTimeRange.thisYear: TimeRangeMode.thisYear,
      TransactionFilterTimeRange.allTime: TimeRangeMode.allTime,
      TransactionFilterTimeRange.currentCycle(): TimeRangeMode.currentCycle,
    };

Future<TransactionFilterTimeRange?> showTransactionFilterTimeRangeSelectorSheet(
  BuildContext context, {
  TransactionFilterTimeRange? initialValue,
}) async {
  final TimeRangeSelection? selection = await showModalBottomSheet<TimeRangeSelection>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => SelectTimeRangeModeSheet(
      initialValue: initialValue != null
          ? filterRangeToModeMapping[initialValue]
          : null,
      customCycles: CustomCyclePreferences().cycles,
    ),
  );

  if (selection == null) return null;
  if (!context.mounted) return null;

  if (selection.mode == TimeRangeMode.addCycle) {
    final CustomCycle? saved = await showModalBottomSheet<CustomCycle>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddEditCustomCycleSheet(),
    );
    if (saved == null) return null;
    return TransactionFilterTimeRange.customCycle(saved.id);
  }

  if (selection.mode == TimeRangeMode.editCycle && selection.cycleId != null) {
    final CustomCycle? current = CustomCyclePreferences().cycleById(selection.cycleId!);
    if (current == null) return null;
    final CustomCycle? saved = await showModalBottomSheet<CustomCycle>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddEditCustomCycleSheet(initialCycle: current),
    );
    if (saved == null) return null;
    return TransactionFilterTimeRange.customCycle(saved.id);
  }

  if (selection.mode == TimeRangeMode.deleteCycle && selection.cycleId != null) {
    await CustomCyclePreferences().deleteCycle(selection.cycleId!);
    return null;
  }

  if (selection.mode == TimeRangeMode.customCycle && selection.cycleId != null) {
    final CustomCycle? cycle = CustomCyclePreferences().cycleById(selection.cycleId!);
    if (cycle == null) return null;

    final DateTime? month = await showMonthPickerSheet(
      context,
      initialDate: initialValue?.range?.from,
    );

    if (month == null) {
      return TransactionFilterTimeRange.customCycle(cycle.id);
    }

    return TransactionFilterTimeRange.customCycleForMonth(cycle.id, month);
  }

  return switch (selection.mode) {
    TimeRangeMode.last30Days => TransactionFilterTimeRange.last30Days,
    TimeRangeMode.thisWeek => TransactionFilterTimeRange.thisWeek,
    TimeRangeMode.thisMonth => TransactionFilterTimeRange.thisMonth,
    TimeRangeMode.thisYear => TransactionFilterTimeRange.thisYear,
    TimeRangeMode.currentCycle => TransactionFilterTimeRange.currentCycle(),
    TimeRangeMode.allTime => TransactionFilterTimeRange.allTime,
    TimeRangeMode.byYear when context.mounted =>
      await showYearPickerSheet(
        context,
        initialDate: initialValue?.range?.from,
      ).then(
        (value) => value == null
            ? null
            : TransactionFilterTimeRange.fromTimeRange(
                YearTimeRange.fromDateTime(value),
              ),
      ),
    TimeRangeMode.byMonth when context.mounted =>
      await showMonthPickerSheet(
        context,
        initialDate: initialValue?.range?.from,
      ).then(
        (value) => value == null
            ? null
            : TransactionFilterTimeRange.fromTimeRange(
                MonthTimeRange.fromDateTime(value),
              ),
      ),
    TimeRangeMode.custom when context.mounted =>
      await showDateRangePicker(
        context: context,
        firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
        lastDate: DateTime(4000),
        initialDateRange: initialValue?.range is CustomTimeRange
            ? DateTimeRange(
                start: initialValue!.range!.from,
                end: initialValue.range!.to,
              )
            : null,
      ).then(
        (value) => value == null
            ? null
            : TransactionFilterTimeRange.fromTimeRange(
                CustomTimeRange(value.start.startOfDay(), value.end.endOfDay()),
              ),
      ),
    _ => null,
  };
}

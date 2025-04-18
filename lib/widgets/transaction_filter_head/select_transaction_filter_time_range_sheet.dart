import "package:flow/data/transactions_filter/time_range.dart";
import "package:flow/widgets/sheets/select_time_range_mode_sheet.dart";
import "package:flow/widgets/utils/time_and_range.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

Future<TransactionFilterTimeRange?> showTransactionFilterTimeRangeSelectorSheet(
  BuildContext context, {
  TransactionFilterTimeRange? initialValue,
}) async {
  final TimeRangeMode? mode = await showModalBottomSheet<TimeRangeMode>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => const SelectTimeRangeModeSheet(),
  );

  if (mode == null) return null;
  if (!context.mounted) return null;

  return switch (mode) {
    TimeRangeMode.last30Days => TransactionFilterTimeRange.last30Days,
    TimeRangeMode.thisWeek => TransactionFilterTimeRange.thisWeek,
    TimeRangeMode.thisMonth => TransactionFilterTimeRange.thisMonth,
    TimeRangeMode.thisYear => TransactionFilterTimeRange.thisYear,
    TimeRangeMode.allTime => TransactionFilterTimeRange.allTime,
    TimeRangeMode.byYear when context.mounted => await showYearPickerSheet(
      context,
      initialDate:
          initialValue?.range is YearTimeRange
              ? initialValue!.range!.from
              : null,
    ).then(
      (value) =>
          value == null
              ? null
              : TransactionFilterTimeRange.fromTimeRange(
                YearTimeRange.fromDateTime(value),
              ),
    ),
    TimeRangeMode.byMonth when context.mounted => await showMonthPickerSheet(
      context,
    ).then(
      (value) =>
          value == null
              ? null
              : TransactionFilterTimeRange.fromTimeRange(
                MonthTimeRange.fromDateTime(value),
              ),
    ),
    TimeRangeMode.custom when context.mounted => await showDateRangePicker(
      context: context,
      firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
      lastDate: DateTime(4000),
      initialDateRange:
          initialValue?.range is CustomTimeRange
              ? DateTimeRange(
                start: initialValue!.range!.from,
                end: initialValue.range!.to,
              )
              : null,
    ).then(
      (value) =>
          value == null
              ? null
              : TransactionFilterTimeRange.fromTimeRange(
                CustomTimeRange(value.start.startOfDay(), value.end.endOfDay()),
              ),
    ),
    _ => null, // context.mounted == true
  };
}

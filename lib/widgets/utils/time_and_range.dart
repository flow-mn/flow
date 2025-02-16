import "package:flow/widgets/month_selector_sheet.dart";
import "package:flow/widgets/select_time_range_mode_sheet.dart";
import "package:flow/widgets/year_selector_sheet.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

Future<DateTime?> showMonthPickerSheet(
  BuildContext context, {
  DateTime? initialDate,
}) => showModalBottomSheet<DateTime>(
  context: context,
  isScrollControlled: true,
  builder: (context) => MonthSelectorSheet(initialDate: initialDate),
);

Future<DateTime?> showYearPickerSheet(
  BuildContext context, {
  DateTime? initialDate,
}) => showModalBottomSheet<DateTime>(
  context: context,
  isScrollControlled: true,
  builder: (context) => YearSelectorSheet(initialDate: initialDate),
);

Future<TimeRange?> showTimeRangePickerSheet(
  BuildContext context, {
  TimeRange? initialValue,
}) async {
  final TimeRangeMode? mode = await showModalBottomSheet<TimeRangeMode>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => const SelectTimeRangeModeSheet(),
  );

  if (mode == null) return null;
  if (!context.mounted) return null;

  return switch (mode) {
    TimeRangeMode.last30Days => last30DaysRange(),
    TimeRangeMode.thisWeek => TimeRange.thisLocalWeek(),
    TimeRangeMode.thisMonth => TimeRange.thisMonth(),
    TimeRangeMode.thisYear => TimeRange.thisYear(),
    TimeRangeMode.allTime => Moment.minValue.rangeToMax(),
    TimeRangeMode.byYear when context.mounted => await showYearPickerSheet(
      context,
      initialDate: initialValue is YearTimeRange ? initialValue.from : null,
    ).then((value) => value == null ? null : YearTimeRange.fromDateTime(value)),
    TimeRangeMode.byMonth when context.mounted => await showMonthPickerSheet(
      context,
    ).then(
      (value) => value == null ? null : MonthTimeRange.fromDateTime(value),
    ),
    TimeRangeMode.custom when context.mounted => await showDateRangePicker(
      context: context,
      firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
      lastDate: DateTime.now().startOfNextYear(),
      initialDateRange:
          initialValue is CustomTimeRange
              ? DateTimeRange(start: initialValue.from, end: initialValue.to)
              : null,
    ).then(
      (value) =>
          value == null
              ? null
              : CustomTimeRange(value.start.startOfDay(), value.end.endOfDay()),
    ),
    _ => null, // context.mounted == true
  };
}

CustomTimeRange last30DaysRange() => Moment.now()
    .subtract(const Duration(days: 29))
    .startOfDay()
    .rangeTo(Moment.endOfToday());

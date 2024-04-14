import 'package:flow/widgets/month_selector_sheet.dart';
import 'package:flow/widgets/select_time_range_mode_sheet.dart';
import 'package:flow/widgets/year_selector_sheet.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';

extension TimeRangeSerializer on TimeRange {
  String serialize() => switch (this) {
        HourTimeRange hourRange =>
          "HourTimeRange:${hourRange.from.toIso8601String()}",
        DayTimeRange dayRange =>
          "DayTimeRange:${dayRange.from.toIso8601String()}",
        LocalWeekTimeRange localWeekRange =>
          "LocalWeekTimeRange:${localWeekRange.from.toIso8601String()}",
        MonthTimeRange monthRange =>
          "MonthTimeRange:${monthRange.from.toIso8601String()}",
        YearTimeRange yearRange =>
          "YearTimeRange:${yearRange.from.toIso8601String()}",
        _ => "CustomTimeRange:${from.toIso8601String()}:${to.toIso8601String()}"
      };

  static TimeRange parse(String serialized) {
    final TimeRange? result = tryParse(serialized);

    if (result == null) {
      throw const FormatException(
        "Cannot parse TimeRange from serialized string",
      );
    }

    return result;
  }

  static TimeRange? tryParse(String serialized) {
    final List<String> parts = serialized.split(":");

    if (parts.length < 2) return null;

    final DateTime? from = DateTime.tryParse(parts[1]);
    final DateTime? to = parts.length > 2 ? DateTime.tryParse(parts[2]) : null;

    if (from == null) return null;
    if (parts.first == "CustomTimeRange" && to == null) return null;

    return switch (parts[0]) {
      "HourTimeRange" => HourTimeRange.fromDateTime(from),
      "DayTimeRange" => DayTimeRange.fromDateTime(from),
      "LocalWeekTimeRange" => LocalWeekTimeRange(from),
      "MonthTimeRange" => MonthTimeRange.fromDateTime(from),
      "YearTimeRange" => YearTimeRange.fromDateTime(from),
      _ => CustomTimeRange(from, to!)
    };
  }
}

Future<DateTime?> showMonthPickerSheet(
  BuildContext context, {
  DateTime? initialDate,
}) =>
    showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      builder: (context) => MonthSelectorSheet(initialDate: initialDate),
    );

Future<DateTime?> showYearPickerSheet(
  BuildContext context, {
  DateTime? initialDate,
}) =>
    showModalBottomSheet<DateTime>(
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
    TimeRangeMode.thisWeek => TimeRange.thisLocalWeek(),
    TimeRangeMode.thisMonth => TimeRange.thisMonth(),
    TimeRangeMode.thisYear => TimeRange.thisYear(),
    TimeRangeMode.byYear when context.mounted => await showYearPickerSheet(
            context,
            initialDate:
                initialValue is YearTimeRange ? initialValue.from : null)
        .then((value) =>
            value == null ? null : YearTimeRange.fromDateTime(value)),
    TimeRangeMode.byMonth when context.mounted =>
      await showMonthPickerSheet(context).then(
          (value) => value == null ? null : MonthTimeRange.fromDateTime(value)),
    TimeRangeMode.custom when context.mounted => await showDateRangePicker(
        context: context,
        firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
        lastDate: DateTime.now().startOfNextYear(),
        initialDateRange: initialValue is CustomTimeRange
            ? DateTimeRange(start: initialValue.from, end: initialValue.to)
            : null,
      ).then((value) => value == null
          ? null
          : CustomTimeRange(value.start.startOfDay(), value.end.endOfDay())),
    _ => null, // context.mounted == true
  };
}

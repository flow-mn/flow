import "package:moment_dart/moment_dart.dart";

/// Return [TimeRange] if [unit] is supported time range unit
TimeRange? durationUnitToRange(DateTime dateTime, DurationUnit unit) =>
    switch (unit) {
      DurationUnit.day => DayTimeRange.fromDateTime(dateTime),
      DurationUnit.week => LocalWeekTimeRange(dateTime),
      DurationUnit.month => MonthTimeRange.fromDateTime(dateTime),
      DurationUnit.year => YearTimeRange.fromDateTime(dateTime),
      _ => null,
    };

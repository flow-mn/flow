import "package:moment_dart/moment_dart.dart";
import "package:recurrence/recurrence.dart";

extension RecurrenceHelpers on Recurrence {
  /// Moves the start to [from]. Rules follow it, e.g., monthly lands on
  /// [from]'s day. Runs indefinitely if it'd end before [from].
  Recurrence startingAt(DateTime from) => copyWith(
    range: CustomTimeRange(
      from,
      range.to.isBefore(from) ? Moment.maxValue : range.to,
    ),
  ).realign();
}

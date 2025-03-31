/// Returns whether this scheduled execution should run "now".
///
/// Use [anchor] to specify a reference point ("now" point) for the comparison.
///
/// Always returns `true` if [lastExecution] is `null`.
///
/// Returns `false` if [interval] is negative.
bool shouldExecuteScheduledTask(
  Duration interval,
  DateTime? lastExecution, {
  DateTime? anchor,
}) {
  if (lastExecution == null) {
    return true;
  }

  if (interval.isNegative) {
    return false;
  }

  final DateTime now = anchor ?? DateTime.now();

  if (lastExecution.add(interval).isAfter(now)) {
    return false;
  }

  return true;
}

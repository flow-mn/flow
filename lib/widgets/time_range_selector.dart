import "package:flow/l10n/flow_localizations.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/utils/time_and_range.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Defaults to the current month
class TimeRangeSelector extends StatefulWidget {
  final TimeRange initialValue;

  final Function(TimeRange) onChanged;

  const TimeRangeSelector({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<TimeRangeSelector> createState() => _TimeRangeSelectorState();
}

class _TimeRangeSelectorState extends State<TimeRangeSelector> {
  static const double _dragThreshold = 32.0;

  late TimeRange _timeRange;

  @override
  void initState() {
    super.initState();

    _timeRange = widget.initialValue;
  }

  @override
  void didUpdateWidget(TimeRangeSelector oldWidget) {
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _timeRange = widget.initialValue;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final bool buildNextPrev = _timeRange is PageableRange;

    final String modeLabel = switch (_timeRange) {
      LocalWeekTimeRange() => "select.timeRange.mode.byWeek",
      MonthTimeRange() => "select.timeRange.mode.byMonth",
      YearTimeRange() => "select.timeRange.mode.byYear",
      _ => "select.timeRange.mode.custom",
    }.t(context);

    final TextDirection textDirection = Directionality.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              if (buildNextPrev) ...[
                IconButton(
                  icon: const Icon(Symbols.chevron_left),
                  onPressed: prev,
                ),
                const SizedBox(width: 12.0),
              ],
              Expanded(
                child: Listener(
                  onPointerSignal: (event) {
                    if (_timeRange is! PageableRange) return;
                    if (event is! PointerScrollEvent) return;

                    if (event.scrollDelta.dy < 0) {
                      prev();
                    } else if (event.scrollDelta.dy > 0) {
                      next();
                    }
                  },
                  child: Directionality(
                    textDirection: textDirection,
                    child: GestureDetector(
                      onHorizontalDragEnd: (details) {
                        final double? velocity = details.primaryVelocity;
                        if (velocity == null) return;
                        if (_timeRange is! PageableRange) return;

                        if (velocity <= -_dragThreshold) {
                          next();
                        } else if (velocity >= _dragThreshold) {
                          prev();
                        }
                      },
                      child: switch (_timeRange) {
                        LocalWeekTimeRange localWeekTimeRange => Button(
                          onTap: selectRange,
                          child: Text(
                            "${localWeekTimeRange.from.toMoment().ll} -> ${localWeekTimeRange.to.toMoment().ll}",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        MonthTimeRange monthTimeRange => Button(
                          onTap: pickMonth,
                          child: Text(
                            monthTimeRange.from.format(
                              payload:
                                  monthTimeRange.from.isAtSameYearAs(
                                        DateTime.now(),
                                      )
                                      ? "MMMM"
                                      : "MMMM YYYY",
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        YearTimeRange yearTimeRange => Button(
                          onTap: selectRange,
                          child: Text(
                            yearTimeRange.year.toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        _ => Button(
                          onTap: pickRange,
                          child: Text(
                            "${_timeRange.from.toMoment().ll} -> ${_timeRange.to.toMoment().ll}",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      },
                    ),
                  ),
                ),
              ),
              if (buildNextPrev) ...[
                const SizedBox(width: 12.0),
                IconButton(
                  icon: const Icon(Symbols.chevron_right),
                  onPressed: next,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(modeLabel),
            TextButton(
              onPressed: changeMode,
              child: Text("select.timeRange.changeMode".t(context)),
            ),
          ],
        ),
      ],
    );
  }

  void update(TimeRange newValue) {
    setState(() {
      _timeRange = newValue;
    });
    widget.onChanged(_timeRange);
  }

  void pickRange() async {
    final TimeRange? newRange = await selectRange();
    if (newRange != null) {
      update(newRange);
    }
  }

  Future<CustomTimeRange?> selectRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
      lastDate: DateTime(4000),
      initialDateRange:
          _timeRange is CustomTimeRange
              ? DateTimeRange(
                start: (_timeRange as CustomTimeRange).from,
                end: (_timeRange as CustomTimeRange).to,
              )
              : null,
    );

    if (range != null) {
      return CustomTimeRange(range.start, range.end);
    }

    return null;
  }

  Future<void> pickMonth() async {
    final DateTime? newDate = await showMonthPickerSheet(
      context,
      initialDate: _timeRange.from,
    );

    if (!mounted || newDate == null) return;

    update(MonthTimeRange.fromDateTime(newDate));
  }

  Future<void> changeMode() async {
    final TimeRange? newRange = await showTimeRangePickerSheet(
      context,
      initialValue: _timeRange,
    );

    if (!mounted || newRange == null) return;

    update(newRange);
  }

  /// Assumes [_timeRange] is pageable
  void next() => update((_timeRange as PageableRange).next);

  /// Assumes [_timeRange] is pageable
  void prev() => update((_timeRange as PageableRange).last);
}

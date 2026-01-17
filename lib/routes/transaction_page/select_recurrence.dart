import "package:flow/data/recurrence_mode.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/routes/transaction_page/select_recurrence/input_occurrences_sheet.dart";
import "package:flow/routes/transaction_page/select_recurrence/select_until_mode_sheet.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/custom_popups.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:recurrence/recurrence.dart";

enum RecurrenceUntilMode with LocalizedEnum {
  never,
  date,
  noOfOccurrences;

  @override
  String get localizationEnumName => "RecurrenceUntilMode";

  @override
  String get localizationEnumValue => name;

  @override
  String get localizedTextKey =>
      "select.recurrence.until.$localizationEnumValue";
}

class SelectRecurrence extends StatefulWidget {
  final Recurrence? initialValue;
  final Function(Recurrence) onChanged;

  final TimeRange? startBounds;

  const SelectRecurrence({
    super.key,
    required this.onChanged,
    required this.startBounds,
    this.initialValue,
  });

  @override
  State<SelectRecurrence> createState() => _SelectRecurrenceState();
}

class _SelectRecurrenceState extends State<SelectRecurrence> {
  late Recurrence _recurrence;
  RecurrenceMode _selectedMode = RecurrenceMode.everyMonth;

  final GlobalKey _modeSelectorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _setRecurrence(widget.initialValue);
  }

  @override
  void didUpdateWidget(SelectRecurrence oldWidget) {
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        _setRecurrence(widget.initialValue);
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final bool runsForever = _recurrence.range.to >= Moment.maxValue;

    final Map<String, String> l10nEnumPayload = {
      "weekday": _recurrence.range.from.format(payload: "dddd"),
      "dayOfMonth": _recurrence.range.from.format(payload: "Do"),
      "monthAndDay": _recurrence.range.from.format(payload: "MMMM Do"),
    };

    final int? currentOccurrences = _recurrence.range.to >= Moment.maxValue
        ? null
        : _recurrence.occurrences().length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text("select.recurrence".t(context)),
              IgnorePointer(
                child: DropdownButton<RecurrenceMode>(
                  key: _modeSelectorKey,
                  value: _selectedMode,
                  style: context.textTheme.titleSmall,
                  underline: SizedBox.shrink(),
                  focusColor: kTransparent,
                  isDense: true,
                  icon: Icon(Symbols.arrow_drop_down_rounded),
                  alignment: AlignmentDirectional.topEnd,
                  items: RecurrenceMode.values
                      .where((mode) => mode != RecurrenceMode.custom)
                      .map(
                        (mode) => DropdownMenuItem<RecurrenceMode>(
                          value: mode,
                          child: Text(
                            mode.localizedNameContext(context, l10nEnumPayload),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _updateMode,
                ),
              ),
            ],
          ),
          onTap: openModeSelector,
        ),
        ListTile(
          title: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text("select.recurrence.from".t(context)),
              Opacity(
                opacity: widget.startBounds != null ? 1.0 : 0.66,
                child: Text(_recurrence.range.from.toMoment().LLL),
              ),
            ],
          ),
          onTap: widget.startBounds != null ? _selectFrom : null,
          // enabled: widget.canEditFromDate,
        ),
        ListTile(
          title: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text("select.recurrence.until".t(context)),
              Opacity(
                opacity: runsForever ? 0.5 : 1.0,
                child: Text(
                  runsForever
                      ? RecurrenceUntilMode.never.localizedNameContext(context)
                      : _recurrence.range.to.toMoment().LLL,
                ),
              ),
            ],
          ),
          subtitle: currentOccurrences == null
              ? null
              : Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Text(
                    "select.recurrence.occurrences.n".t(
                      context,
                      currentOccurrences.toString(),
                    ),
                    style: context.textTheme.bodyMedium?.semi(context),
                  ),
                ),
          onTap: _selectUntil,
        ),
      ],
    );
  }

  void _updateMode(RecurrenceMode? mode) {
    if (mode == null) return;

    late final List<RecurrenceRule> rules;

    switch (mode) {
      case RecurrenceMode.everyDay:
        rules = [RecurrenceRule.daily()];
        break;
      case RecurrenceMode.everyWeek:
        rules = [RecurrenceRule.weekly(_recurrence.range.from.weekday)];
        break;
      case RecurrenceMode.every2Week:
        rules = [RecurrenceRule.interval(const Duration(days: 14))];
      case RecurrenceMode.everyMonth:
        rules = [RecurrenceRule.monthly(_recurrence.range.from.day)];
        break;
      case RecurrenceMode.everyYear:
        rules = [
          RecurrenceRule.yearly(
            _recurrence.range.from.month,
            _recurrence.range.from.day,
          ),
        ];
        break;
      case RecurrenceMode.custom:
        rules = [];
        // TODO: Handle this case. This takes the initial rules in to account,
        // and returns a new list of rules rather than a single rule.
        throw UnimplementedError();
    }

    _setRecurrence(_recurrence.copyWith(rules: rules));

    if (!mounted) return;
    setState(() {});
    widget.onChanged(_recurrence);
  }

  void _selectFrom() async {
    final DateTime initialDate =
        _recurrence.range.from.isBefore(Moment.minValue)
        ? DateTime.now()
        : _recurrence.range.from;

    final DateTime? result = await context.pickDate(
      initialDate,
      widget.startBounds,
    );

    if (result == null) return;
    _recurrence = _recurrence.copyWith(
      range: CustomTimeRange(result, _recurrence.range.to),
    );

    if (!mounted) return;
    setState(() {});
    widget.onChanged(_recurrence);

    final DateTime? resultWithTime = await context.pickTime(anchor: result);
    if (resultWithTime == null) return;

    _recurrence = _recurrence.copyWith(
      range: CustomTimeRange(resultWithTime, _recurrence.range.to),
    );
    if (!mounted) return;
    setState(() {});
    widget.onChanged(_recurrence);
  }

  void _selectUntil() async {
    final RecurrenceUntilMode? mode = await showModalBottomSheet(
      context: context,
      builder: (context) => SelectUntilModeSheet(),
      isScrollControlled: true,
    );

    if (mode == null || !mounted) return;

    switch (mode) {
      case RecurrenceUntilMode.never:
        {
          setState(() {
            _recurrence = _recurrence.copyWith(
              range: CustomTimeRange(
                _recurrence.range.from.startOfSecond(),
                Moment.maxValue,
              ),
            );
          });
          widget.onChanged(_recurrence);
          return;
        }
      case RecurrenceUntilMode.date:
        {
          final DateTime initialDate = _recurrence.range.to >= Moment.maxValue
              ? DateTime.now()
              : _recurrence.range.to;

          final DateTime? result = await context.pickDate(initialDate);

          if (!mounted) return;
          if (result == null) return;

          setState(() {
            _recurrence = _recurrence.copyWith(
              range: CustomTimeRange(
                _recurrence.range.from.startOfSecond(),
                copyWithFromHours(result),
              ),
            );
          });
          widget.onChanged(_recurrence);
        }
      case RecurrenceUntilMode.noOfOccurrences:
        {
          final int? currentOccurrences =
              _recurrence.range.to >= Moment.maxValue
              ? null
              : _recurrence.occurrences().length;

          final int? occurrences = await showModalBottomSheet(
            context: context,
            builder: (context) =>
                InputOccurrencesSheet(initialValue: currentOccurrences),
            isScrollControlled: true,
          );

          if (!mounted) return;
          if (occurrences == null) return;

          final Duration? safeLimitDuration = switch (_selectedMode) {
            RecurrenceMode.everyDay => const Duration(days: 1),
            RecurrenceMode.everyWeek => const Duration(days: 7),
            RecurrenceMode.every2Week => const Duration(days: 14),
            RecurrenceMode.everyMonth => const Duration(days: 32),
            RecurrenceMode.everyYear => const Duration(days: 367),
            RecurrenceMode.custom => null,
          };

          setState(() {
            final DateTime safeLimit = safeLimitDuration == null
                ? Moment.maxValue
                : (_recurrence.range.from +
                      (safeLimitDuration * (occurrences + 1)));

            final DateTime endDate = _recurrence
                .occurrences(
                  subrange: _recurrence.range.from.rangeTo(safeLimit),
                )
                .skip(occurrences - 1)
                .first;

            _recurrence = _recurrence.copyWith(
              range: CustomTimeRange(
                _recurrence.range.from.startOfSecond(),
                copyWithFromHours(endDate),
              ),
            );
          });
          widget.onChanged(_recurrence);
        }
    }
  }

  DateTime copyWithFromHours(DateTime date) => date
      .clone()
      .setClampedHour(_recurrence.range.from.hour)
      .setClampedMinute(_recurrence.range.from.minute)
      .setClampedSecond(_recurrence.range.from.second);

  void openModeSelector() {
    _modeSelectorKey.currentContext?.visitChildElements((element) {
      if (element.widget is Semantics) {
        element.visitChildElements((element) {
          if (element.widget is Actions) {
            element.visitChildElements((element) {
              Actions.invoke(element, ActivateIntent());
            });
          }
        });
      }
    });
  }

  void _setRecurrence(Recurrence? recurrence) {
    _recurrence =
        (recurrence ??
                Recurrence.fromIndefinitely(
                  rules: [
                    MonthlyRecurrenceRule(day: recurrence?.range.from.day ?? 1),
                  ],
                  start: DateTime.now().startOfSecond(),
                ))
            .realign();

    if (_recurrence.rules.length != 1) {
      _selectedMode = RecurrenceMode.custom;
    } else {
      final RecurrenceRule rule = _recurrence.rules.single;

      if (rule is IntervalRecurrenceRule) {
        if (rule.data == const Duration(days: 1)) {
          _selectedMode = RecurrenceMode.everyDay;
        } else if (rule.data == const Duration(days: 7)) {
          _selectedMode = RecurrenceMode.everyWeek;
        } else if (rule.data == const Duration(days: 14)) {
          _selectedMode = RecurrenceMode.every2Week;
        }
      } else if (rule is WeeklyRecurrenceRule) {
        _selectedMode = RecurrenceMode.everyWeek;
      } else if (rule is MonthlyRecurrenceRule) {
        _selectedMode = RecurrenceMode.everyMonth;
      } else if (rule is YearlyRecurrenceRule) {
        _selectedMode = RecurrenceMode.everyYear;
      } else {
        _selectedMode = RecurrenceMode.custom;
      }
    }
  }
}

import "package:flow/data/recurrence_mode.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/routes/transaction_page/select_occurrences_sheet.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/custom_popups.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:recurrence/recurrence.dart";

enum RecurrenceEndMode {
  never,
  onDate,
  afterOccurrences,
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
  RecurrenceEndMode _endMode = RecurrenceEndMode.never;
  int _occurrences = 10;

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        // End mode selection
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("select.recurrence.endMode".t(context)),
              DropdownButton<RecurrenceEndMode>(
                value: _endMode,
                style: context.textTheme.titleSmall,
                underline: SizedBox.shrink(),
                focusColor: kTransparent,
                isDense: true,
                icon: Icon(Symbols.arrow_drop_down_rounded),
                items: RecurrenceEndMode.values.map(
                  (mode) => DropdownMenuItem<RecurrenceEndMode>(
                    value: mode,
                    child: Text(_getEndModeText(mode, context)),
                  ),
                ).toList(),
                onChanged: _updateEndMode,
              ),
            ],
          ),
        ),
        // Show appropriate end option based on selected mode
        if (_endMode == RecurrenceEndMode.onDate)
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("select.recurrence.until".t(context)),
                Opacity(
                  opacity: runsForever ? 0.5 : 1.0,
                  child: Text(
                    runsForever ? "-" : _recurrence.range.to.toMoment().LLL,
                  ),
                ),
              ],
            ),
            onTap: _selectUntil,
          ),
        if (_endMode == RecurrenceEndMode.afterOccurrences)
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("select.recurrence.occurrences".t(context)),
                Text("select.recurrence.occurrences.times".t(context, {"count": _occurrences.toString()})),
              ],
            ),
            onTap: _selectOccurrences,
          ),
      ],
    );
  }

  String _getEndModeText(RecurrenceEndMode mode, BuildContext context) {
    switch (mode) {
      case RecurrenceEndMode.never:
        return "select.recurrence.endMode.never".t(context);
      case RecurrenceEndMode.onDate:
        return "select.recurrence.endMode.on".t(context);
      case RecurrenceEndMode.afterOccurrences:
        return "select.recurrence.endMode.after".t(context);
    }
  }

  void _updateEndMode(RecurrenceEndMode? mode) {
    if (mode == null) return;
    
    setState(() {
      _endMode = mode;
    });
    
    // Update the recurrence based on the selected end mode
    _updateRecurrenceRange();
  }

  void _updateRecurrenceRange() {
    DateTime endDate;
    
    switch (_endMode) {
      case RecurrenceEndMode.never:
        endDate = Moment.maxValue;
        break;
      case RecurrenceEndMode.onDate:
        // Keep current end date, or set to maxValue if it was infinite
        endDate = _recurrence.range.to >= Moment.maxValue 
            ? DateTime.now().add(const Duration(days: 30))
            : _recurrence.range.to;
        break;
      case RecurrenceEndMode.afterOccurrences:
        // Calculate end date based on occurrences
        endDate = _calculateEndDateFromOccurrences();
        break;
    }
    
    _recurrence = _recurrence.copyWith(
      range: CustomTimeRange(_recurrence.range.from, endDate),
    );
    
    widget.onChanged(_recurrence);
  }

  DateTime _calculateEndDateFromOccurrences() {
    // Calculate end date based on the number of occurrences and recurrence rule
    DateTime startDate = _recurrence.range.from;
    
    switch (_selectedMode) {
      case RecurrenceMode.everyDay:
        return startDate.add(Duration(days: _occurrences - 1));
      case RecurrenceMode.everyWeek:
        return startDate.add(Duration(days: (_occurrences - 1) * 7));
      case RecurrenceMode.every2Week:
        return startDate.add(Duration(days: (_occurrences - 1) * 14));
      case RecurrenceMode.everyMonth:
        DateTime endDate = startDate;
        for (int i = 1; i < _occurrences; i++) {
          endDate = DateTime(endDate.year, endDate.month + 1, endDate.day);
        }
        return endDate;
      case RecurrenceMode.everyYear:
        return DateTime(startDate.year + _occurrences - 1, startDate.month, startDate.day);
      case RecurrenceMode.custom:
        // For custom, fallback to daily calculation
        return startDate.add(Duration(days: _occurrences - 1));
    }
  }

  void _selectOccurrences() async {
    final int? result = await context.push<int>(
      "/select-occurrences",
      extra: {
        "initialValue": _occurrences,
        "minValue": 1,
        "maxValue": 999,
      },
    );

    // Fallback using showModalBottomSheet if routing doesn't work
    if (result == null) {
      final int? bottomSheetResult = await showModalBottomSheet<int>(
        context: context,
        isScrollControlled: true,
        builder: (context) => SelectOccurrencesSheet(
          initialValue: _occurrences,
          minValue: 1,
          maxValue: 999,
        ),
      );
      
      if (bottomSheetResult != null && mounted) {
        setState(() {
          _occurrences = bottomSheetResult;
        });
        _updateRecurrenceRange();
      }
    } else if (mounted) {
      setState(() {
        _occurrences = result;
      });
      _updateRecurrenceRange();
    }
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

    _selectedMode = mode;
    _setRecurrence(_recurrence.copyWith(rules: rules));

    if (!mounted) return;
    setState(() {});
    
    // If we're in afterOccurrences mode, recalculate the end date
    if (_endMode == RecurrenceEndMode.afterOccurrences) {
      _updateRecurrenceRange();
    } else {
      widget.onChanged(_recurrence);
    }
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
    final DateTime initialDate = _recurrence.range.to >= Moment.maxValue
        ? DateTime.now()
        : _recurrence.range.to;

    final DateTime? result = await context.pickDate(initialDate);

    if (!mounted) return;
    if (result == null) return;

    setState(() {
      _recurrence = _recurrence.copyWith(
        range: CustomTimeRange(_recurrence.range.from, result),
      );
    });
    widget.onChanged(_recurrence);
  }

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
                ))
            .realign();

    // Determine end mode based on the range
    if (_recurrence.range.to >= Moment.maxValue) {
      _endMode = RecurrenceEndMode.never;
    } else {
      _endMode = RecurrenceEndMode.onDate;
    }

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

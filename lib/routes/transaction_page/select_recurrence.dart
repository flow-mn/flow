import "package:flow/data/recurrence_mode.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/custom_popups.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:recurrence/recurrence.dart";

class SelectRecurrence extends StatefulWidget {
  final Recurrence? initialValue;
  final Function(Recurrence) onChanged;

  const SelectRecurrence({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<SelectRecurrence> createState() => _SelectRecurrenceState();
}

class _SelectRecurrenceState extends State<SelectRecurrence> {
  late Recurrence _recurrence;
  final RecurrenceMode _selectedMode = RecurrenceMode.everyMonth;

  final GlobalKey _modeSelectorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _recurrence = widget.initialValue ?? Recurrence.fromIndefinitely(rules: []);
  }

  @override
  void didUpdateWidget(SelectRecurrence oldWidget) {
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        _recurrence =
            widget.initialValue ?? Recurrence.fromIndefinitely(rules: []);
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final bool runsForever = _recurrence.range.to.isAfter(DateTime(4000));

    final Map<String, String> l10nEnumPayload = {
      "weekday": _recurrence.range.from.format(payload: "dddd"),
      "dayOfMonth": _recurrence.range.from.format(payload: "Do"),
      "monthAndDay": _recurrence.range.from.format(payload: "MMMM Do"),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text("select.recurrence".t(context)),
          trailing: IgnorePointer(
            child: DropdownButton<RecurrenceMode>(
              key: _modeSelectorKey,
              value: _selectedMode,
              style: context.textTheme.titleSmall,
              underline: SizedBox.shrink(),
              focusColor: kTransparent,
              isDense: true,
              icon: Icon(Symbols.arrow_drop_down_rounded),
              alignment: AlignmentDirectional.topEnd,
              items:
                  RecurrenceMode.values
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
          onTap: openModeSelector,
        ),
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("select.recurrence.from".t(context)),
              Text(_recurrence.range.from.toMoment().LLL),
            ],
          ),
          onTap: _selectFrom,
        ),
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

    _recurrence = _recurrence.copyWith(rules: rules);

    if (!mounted) return;
    setState(() {});
    widget.onChanged(_recurrence);
  }

  void _selectFrom() async {
    final DateTime initialDate =
        _recurrence.range.from.isBefore(DateTime(0))
            ? DateTime.now()
            : _recurrence.range.from;

    final DateTime? result = await context.pickDate(initialDate);

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
    final DateTime initialDate =
        _recurrence.range.to.isAfter(DateTime(4000))
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
}

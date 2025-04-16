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
  RecurrenceMode _selectedMode = RecurrenceMode.everyMonth;

  final GlobalKey _modeSelectorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _recurrence = widget.initialValue ?? Recurrence.fromIndefinitely(rules: []);
  }

  @override
  Widget build(BuildContext context) {
    final bool runsForever = _recurrence.range.to.isAfter(DateTime(4000));

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
                          child: Text(mode.localizedNameContext(context)),
                        ),
                      )
                      .toList(),
              onChanged: (newMode) {
                if (newMode == null) return;

                setState(() {
                  _selectedMode = newMode;
                });
              },
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

  void _selectFrom() async {
    final DateTime initialDate =
        _recurrence.range.from.isBefore(DateTime(0))
            ? DateTime.now()
            : _recurrence.range.from;

    final DateTime? result = await context.pickDate(initialDate);

    if (!mounted) return;
    if (result == null) return;

    setState(() {
      _recurrence = _recurrence.copyWith(
        range: CustomTimeRange(result, _recurrence.range.to),
      );
    });
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

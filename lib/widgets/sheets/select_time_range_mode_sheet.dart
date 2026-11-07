import "package:flow/l10n/flow_localizations.dart";
import "package:flow/prefs/custom_cycles.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:uuid/uuid.dart";

class TimeRangeSelection {
  final TimeRangeMode mode;
  final String? cycleId;

  const TimeRangeSelection({
    required this.mode,
    this.cycleId,
  });
}

enum TimeRangeMode {
  last30Days("last30Days"),
  thisWeek("thisWeek"),
  thisMonth("thisMonth"),
  thisYear("thisYear"),
  currentCycle("currentCycle"),
  allTime("allTime"),
  byMonth("byMonth"),
  byYear("byYear"),
  customCycle("customCycle"),
  addCycle("addCycle"),
  editCycle("editCycle"),
  deleteCycle("deleteCycle"),
  custom("custom");

  final String value;

  const TimeRangeMode(this.value);

  String get translationKey => "select.timeRange.$value";

  static TimeRangeMode? tryInferPresetFromRange(
    TimeRange? range, {
    DateTime? anchor,
  }) {
    if (range == null) {
      return null;
    }

    final DateTime now = anchor ?? DateTime.now();

    if (range == LocalWeekTimeRange(now)) {
      return TimeRangeMode.thisWeek;
    } else if (range == MonthTimeRange.fromDateTime(now)) {
      return TimeRangeMode.thisMonth;
    } else if (range == YearTimeRange.fromDateTime(now)) {
      return TimeRangeMode.thisYear;
    } else if (range == Moment.minValue.rangeToMax()) {
      return TimeRangeMode.allTime;
    }

    return null;
  }
}

class AddEditCustomCycleSheet extends StatefulWidget {
  final CustomCycle? initialCycle;

  const AddEditCustomCycleSheet({super.key, this.initialCycle});

  @override
  State<AddEditCustomCycleSheet> createState() => _AddEditCustomCycleSheetState();
}

class _AddEditCustomCycleSheetState extends State<AddEditCustomCycleSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _startDayController;
  late final TextEditingController _endDayController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialCycle?.name ?? "");
    _startDayController = TextEditingController(
      text: widget.initialCycle != null
          ? widget.initialCycle!.startDay.toString()
          : "21",
    );
    _endDayController = TextEditingController(
      text: widget.initialCycle != null
          ? widget.initialCycle!.endDay.toString()
          : "20",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDayController.dispose();
    _endDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text(
        widget.initialCycle == null
            ? "customCycle.add".t(context)
            : "customCycle.edit".t(context),
      ),
      trailing: ModalOverflowBar(
        alignment: .end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(null),
            icon: const Icon(Symbols.close_rounded),
            label: Text("general.cancel".t(context)),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "customCycle.name".t(context),
                hintText: "customCycle.name.hint".t(context),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startDayController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: "customCycle.startDay".t(context),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: TextField(
                    controller: _endDayController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: "customCycle.endDay".t(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Symbols.check_rounded),
                label: Text("customCycle.save".t(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() async {
    final String name = _nameController.text.trim();
    final int? startDay = int.tryParse(_startDayController.text.trim());
    final int? endDay = int.tryParse(_endDayController.text.trim());

    if (name.isEmpty || startDay == null || endDay == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text("customCycle.validation.fillAll".t(context))),
      );
      return;
    }

    if (startDay < 1 || startDay > 31 || endDay < 1 || endDay > 31) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text("customCycle.validation.days".t(context))),
      );
      return;
    }

    final CustomCycle cycle = CustomCycle(
      id: widget.initialCycle?.id ?? const Uuid().v4(),
      name: name.isEmpty ? "customCycle.defaultName".t(context) : name,
      startDay: startDay,
      endDay: endDay,
    );

    await CustomCyclePreferences().addOrUpdateCycle(cycle);
    if (!context.mounted) return;
    context.pop(cycle);
  }
}

class SelectTimeRangeModeSheet extends StatelessWidget {
  final TimeRangeMode? initialValue;
  final List<CustomCycle> customCycles;

  const SelectTimeRangeModeSheet({
    super.key,
    this.initialValue,
    this.customCycles = const <CustomCycle>[],
  });

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("select.timeRange".t(context)),
      trailing: ModalOverflowBar(
        alignment: .end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(null),
            icon: const Icon(Symbols.close_rounded),
            label: Text("general.cancel".t(context)),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                "select.timeRange.presets".t(context),
                style: context.textTheme.labelMedium,
              ),
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Wrap(
                spacing: 12.0,
                runSpacing: 8.0,
                children:
                    [
                          TimeRangeMode.last30Days,
                          TimeRangeMode.thisWeek,
                          TimeRangeMode.thisMonth,
                          TimeRangeMode.thisYear,
                          TimeRangeMode.currentCycle,
                          TimeRangeMode.allTime,
                        ]
                        .map(
                          (mode) => FilterChip(
                            label: Text(mode.translationKey.t(context)),
                            onSelected: (_) => context.pop(
                              TimeRangeSelection(mode: mode),
                            ),
                            selected: mode == initialValue,
                          ),
                        )
                        .toList(),
              ),
            ),
            const SizedBox(height: 12.0),
            ListTile(
              title: Text("select.timeRange.mode.byMonth".t(context)),
              onTap: () => context.pop(
                const TimeRangeSelection(mode: TimeRangeMode.byMonth),
              ),
              trailing: const LeChevron(),
            ),
            ListTile(
              title: Text("select.timeRange.mode.byYear".t(context)),
              onTap: () => context.pop(
                const TimeRangeSelection(mode: TimeRangeMode.byYear),
              ),
              trailing: const LeChevron(),
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                "customCycle.title".t(context),
                style: context.textTheme.labelMedium,
              ),
            ),
            const SizedBox(height: 8.0),
            if (customCycles.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ListTile(
                  title: Text("customCycle.empty.title".t(context)),
                  subtitle: Text("customCycle.empty.description".t(context)),
                ),
              )
            else
              ...customCycles.map(
                (cycle) => ListTile(
                  title: Text(cycle.name),
                  subtitle: Text("${cycle.startDay}–${cycle.endDay}"),
                  trailing: PopupMenuButton<TimeRangeSelection>(
                    icon: const Icon(Symbols.more_horiz_rounded),
                    onSelected: (selection) => context.pop(selection),
                    itemBuilder: (context) => <PopupMenuEntry<TimeRangeSelection>>[
                      PopupMenuItem<TimeRangeSelection>(
                        value: TimeRangeSelection(
                          mode: TimeRangeMode.customCycle,
                          cycleId: cycle.id,
                        ),
                        child: Text("customCycle.menu.thisCycle".t(context)),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<TimeRangeSelection>(
                        value: TimeRangeSelection(
                          mode: TimeRangeMode.editCycle,
                          cycleId: cycle.id,
                        ),
                        child: Text("customCycle.menu.edit".t(context)),
                      ),
                      PopupMenuItem<TimeRangeSelection>(
                        value: TimeRangeSelection(
                          mode: TimeRangeMode.deleteCycle,
                          cycleId: cycle.id,
                        ),
                        child: Text("customCycle.menu.delete".t(context)),
                      ),
                    ],
                  ),
                  onTap: () => context.pop(
                    TimeRangeSelection(
                      mode: TimeRangeMode.customCycle,
                      cycleId: cycle.id,
                    ),
                  ),
                ),
              ),
            ListTile(
              leading: const Icon(Symbols.add_rounded),
              title: Text("customCycle.add".t(context)),
              onTap: () => context.pop(
                const TimeRangeSelection(mode: TimeRangeMode.addCycle),
              ),
              trailing: const LeChevron(),
            ),
            const SizedBox(height: 12.0),
            ListTile(
              title: Text("select.timeRange.mode.custom".t(context)),
              onTap: () => context.pop(
                const TimeRangeSelection(mode: TimeRangeMode.custom),
              ),
              trailing: const LeChevron(),
            ),
          ],
        ),
      ),
    );
  }
}

import "package:flow/l10n/flow_localizations.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

enum TimeRangeMode {
  last30Days("last30Days"),
  thisWeek("thisWeek"),
  thisMonth("thisMonth"),
  thisYear("thisYear"),
  byMonth("byMonth"),
  byYear("byYear"),
  allTime("allTime"),
  custom("custom");

  final String value;

  const TimeRangeMode(this.value);

  String get translationKey => "select.timeRange.$value";

  /// Only returns one of [TimeRangeMode.thisWeek], [TimeRangeMode.thisMonth],
  /// [TimeRangeMode.thisYear], [TimeRangeMode.allTime] based on the [anchor]
  /// or now.
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

class SelectTimeRangeModeSheet extends StatelessWidget {
  final TimeRangeMode? initialValue;

  const SelectTimeRangeModeSheet({super.key, this.initialValue});

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
                        TimeRangeMode.allTime,
                      ]
                      .map(
                        (mode) => FilterChip(
                          label: Text(mode.translationKey.t(context)),
                          onSelected: (_) => context.pop(mode),
                          selected: mode == initialValue,
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 12.0),
          ListTile(
            title: Text("select.timeRange.mode.byMonth".t(context)),
            onTap: () => context.pop(TimeRangeMode.byMonth),
            trailing: DirectionalChevron(),
          ),
          ListTile(
            title: Text("select.timeRange.mode.byYear".t(context)),
            onTap: () => context.pop(TimeRangeMode.byYear),
            trailing: DirectionalChevron(),
          ),
          ListTile(
            title: Text("select.timeRange.mode.custom".t(context)),
            onTap: () => context.pop(TimeRangeMode.custom),
            trailing: DirectionalChevron(),
          ),
        ],
      ),
    );
  }
}

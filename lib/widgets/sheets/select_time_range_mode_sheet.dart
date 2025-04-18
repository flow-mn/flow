import "package:flow/l10n/flow_localizations.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

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
}

class SelectTimeRangeModeSheet extends StatelessWidget {
  const SelectTimeRangeModeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("select.timeRange".t(context)),
      trailing: ModalOverflowBar(
        alignment: MainAxisAlignment.end,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
              runSpacing: 12.0,
              children: [
                ActionChip(
                  label: Text("select.timeRange.last30days".t(context)),
                  onPressed: () => context.pop(TimeRangeMode.last30Days),
                ),
                ActionChip(
                  label: Text("select.timeRange.thisWeek".t(context)),
                  onPressed: () => context.pop(TimeRangeMode.thisWeek),
                ),
                ActionChip(
                  label: Text("select.timeRange.thisMonth".t(context)),
                  onPressed: () => context.pop(TimeRangeMode.thisMonth),
                ),
                ActionChip(
                  label: Text("select.timeRange.thisYear".t(context)),
                  onPressed: () => context.pop(TimeRangeMode.thisYear),
                ),
                ActionChip(
                  label: Text("select.timeRange.allTime".t(context)),
                  onPressed: () => context.pop(TimeRangeMode.allTime),
                ),
              ],
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

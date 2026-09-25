import "package:flow/data/insights/insight_engine.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/insights_preferences.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";

/// Turns kinds of insights back on after "Don't show".
class InsightKindsSheet extends StatelessWidget {
  const InsightKindsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final InsightsLocalPreferences preferences = InsightsLocalPreferences();

    return ModalSheet.scrollable(
      title: Text("tabs.stats.worthKnowing.kinds".t(context)),
      child: SingleChildScrollView(
        child: ValueListenableBuilder(
          valueListenable: preferences.hiddenTypes.valueNotifier,
          builder: (context, _, _) {
            final Set<InsightType> hidden = preferences.hiddenTypeSet;

            return Column(
              mainAxisSize: .min,
              children: [
                for (final InsightType type in InsightType.values)
                  SwitchListTile(
                    title: Text(
                      "tabs.stats.worthKnowing.type.${type.name}".t(context),
                    ),
                    value: !hidden.contains(type),
                    onChanged: (show) => preferences.setHidden(type, !show),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

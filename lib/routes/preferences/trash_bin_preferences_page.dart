import "dart:developer";

import "package:flow/l10n/extensions.dart";
import "package:flow/services/transactions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/extensions.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class TrashBinPreferencesPage extends StatefulWidget {
  const TrashBinPreferencesPage({super.key});

  @override
  State<TrashBinPreferencesPage> createState() =>
      _TrashBinPreferencesPageState();

  static const List<Duration> choices = [
    Duration(days: 7),
    Duration(days: 14),
    Duration(days: 30),
    Duration(days: 90),
    Duration(days: 180),
    Duration(days: 365),
  ];
}

class _TrashBinPreferencesPageState extends State<TrashBinPreferencesPage> {
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("preferences.trashBin".t(context))),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: UserPreferencesService().valueNotiifer,
          builder: (context, snapshot, _) {
            final int? trashBinRetentionDays = snapshot.trashBinRetentionDays;

            final bool isCustomPeriod =
                trashBinRetentionDays != null &&
                !TrashBinPreferencesPage.choices.any(
                  (preset) => trashBinRetentionDays == preset.inDays,
                );

            final List<Duration> choices = [
              ...TrashBinPreferencesPage.choices,
              if (isCustomPeriod) Duration(days: trashBinRetentionDays),
            ]..sort((a, b) => a.inDays.compareTo(b.inDays));

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListHeader("preferences.trashBin.retention".t(context)),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Wrap(
                      spacing: 12.0,
                      runSpacing: 8.0,
                      children: [
                        ...choices.map(
                          (value) => FilterChip(
                            showCheckmark: false,
                            key: ValueKey(value),
                            label: Text(
                              value.toDurationString(
                                format: DurationFormat([DurationUnit.day]),
                                dropPrefixOrSuffix: true,
                              ),
                            ),
                            onSelected:
                                (bool selected) =>
                                    selected
                                        ? updateTrashBinRetentionDays(
                                          value.inDays,
                                        )
                                        : null,
                            selected: value.inDays == trashBinRetentionDays,
                          ),
                        ),
                        FilterChip(
                          label: Text(
                            "preferences.trashBin.retention.forever".t(context),
                          ),
                          onSelected:
                              (bool selected) =>
                                  selected
                                      ? updateTrashBinRetentionDays(null)
                                      : null,
                          selected: trashBinRetentionDays == null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ListTile(
                    title: Text("preferences.trashBin.seeItems".t(context)),
                    trailing: Icon(Symbols.chevron_right_rounded),
                    onTap: () => context.push("/transactions/deleted"),
                  ),
                  ListTile(
                    title: Text("preferences.trashBin.emptyBin".t(context)),
                    trailing: Icon(Symbols.delete_sweep_rounded),
                    enabled: !busy,
                    onTap: emptyTrashBin,
                    textColor: context.colorScheme.error,
                    iconColor: context.colorScheme.error,
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void updateTrashBinRetentionDays(int? days) async {
    UserPreferencesService().trashBinRetentionDays = days;
  }

  void emptyTrashBin() async {
    if (busy) return;

    final bool? confirmation = await context.showConfirmDialog(
      isDeletionConfirmation: true,
      title: "preferences.trashBin.emptyBin".t(context),
      child: Text("preferences.trashBin.emptyBin.description".t(context)),
    );

    if (confirmation != true) return;

    setState(() {
      busy = true;
    });

    try {
      await TransactionsService().emptyTrashBin();
    } catch (error) {
      log("Failed to empty trash bin", error: error);
    } finally {
      busy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }
}

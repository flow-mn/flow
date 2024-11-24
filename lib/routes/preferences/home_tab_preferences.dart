import "package:flow/data/pending_transactions_duration.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/prefs.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flutter/material.dart";

class HomeTabPreferencesPage extends StatefulWidget {
  const HomeTabPreferencesPage({super.key});

  @override
  State<HomeTabPreferencesPage> createState() => _HomeTabPreferencesPageState();
}

class _HomeTabPreferencesPageState extends State<HomeTabPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final PendingTransactionsDuration homeTabPlannedTransactionsDuration =
        LocalPreferences().homeTabPlannedTransactionsDuration.get() ??
            LocalPreferences.homeTabPlannedTransactionsDurationDefault;

    return Scaffold(
      appBar: AppBar(
        title: Text("preferences.home".t(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              ListHeader("preferences.home.pending".t(context)),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children: PendingTransactionsDuration.values
                      .map(
                        (value) => FilterChip(
                          showCheckmark: false,
                          key: ValueKey(value.value),
                          label: Text(
                            value.localizedNameContext(context),
                          ),
                          onSelected: (bool selected) => selected
                              ? updateHomeTabPlannedTransactionsDays(value)
                              : null,
                          selected: value == homeTabPlannedTransactionsDuration,
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: InfoText(
                  child:
                      Text("preferences.home.pending.description".t(context)),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  void updateHomeTabPlannedTransactionsDays(
      PendingTransactionsDuration duration) async {
    await LocalPreferences().homeTabPlannedTransactionsDuration.set(duration);

    if (mounted) setState(() {});
  }
}

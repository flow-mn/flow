import 'package:flow/l10n/extensions.dart';
import 'package:flow/prefs.dart';
import 'package:flow/widgets/general/info_text.dart';
import 'package:flow/widgets/general/list_header.dart';
import 'package:flutter/material.dart';

class HomeTabPreferencesPage extends StatefulWidget {
  const HomeTabPreferencesPage({super.key});

  @override
  State<HomeTabPreferencesPage> createState() => _HomeTabPreferencesPageState();
}

class _HomeTabPreferencesPageState extends State<HomeTabPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final int homeTabPlannedTransactionsDays =
        LocalPreferences().homeTabPlannedTransactionsDays.get() ??
            LocalPreferences.homeTabPlannedTransactionsDaysDefault;

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
              ListHeader("preferences.home.upcoming".t(context)),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children: [0, 7, 14, 30]
                      .map(
                        (days) => FilterChip(
                          showCheckmark: false,
                          key: ValueKey(days),
                          label: Text(
                            days == 0
                                ? "preferences.home.upcoming.none".t(context)
                                : "preferences.home.upcoming.nextNdays"
                                    .t(context, days),
                          ),
                          onSelected: (bool value) => value
                              ? updateHomeTabPlannedTransactionsDays(days)
                              : null,
                          selected: days == homeTabPlannedTransactionsDays,
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
                      Text("preferences.home.upcoming.description".t(context)),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  void updateHomeTabPlannedTransactionsDays(int days) async {
    if (days < 0) return;

    await LocalPreferences().homeTabPlannedTransactionsDays.set(days);

    if (mounted) setState(() {});
  }
}

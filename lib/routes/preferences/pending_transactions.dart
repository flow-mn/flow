import "package:flow/l10n/extensions.dart";
import "package:flow/prefs.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flutter/material.dart";

class PendingTransactionPreferencesPage extends StatefulWidget {
  const PendingTransactionPreferencesPage({super.key});

  @override
  State<PendingTransactionPreferencesPage> createState() =>
      _PendingTransactionPreferencesPageState();
}

class _PendingTransactionPreferencesPageState
    extends State<PendingTransactionPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final int pendingTransactionsHomeTimeframe =
        LocalPreferences().pendingTransactionsHomeTimeframe.get() ??
            LocalPreferences.pendingTransactionsHomeTimeframeDefault;
    final bool requirePendingTransactionConfrimation =
        LocalPreferences().requirePendingTransactionConfrimation.get();
    final bool pendingTransactionsUpdateDateUponConfirmation =
        LocalPreferences().pendingTransactionsUpdateDateUponConfirmation.get();

    return Scaffold(
      appBar: AppBar(
        title: Text("preferences.pendingTransactions".t(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: InfoText(
                  child: Text(
                    "preferences.pendingTransactions.requireConfirmation.description"
                        .t(context),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ListHeader(
                "preferences.pendingTransactions.homeTimeframe".t(context),
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children: [1, 2, 3, 5, 7, 14, 30]
                      .map(
                        (value) => FilterChip(
                          showCheckmark: false,
                          key: ValueKey(value),
                          label: Text(
                            "general.nextNDays".t(context, value),
                          ),
                          onSelected: (bool selected) => selected
                              ? updatePendingTransactionsHomeTimeframe(value)
                              : null,
                          selected: value == pendingTransactionsHomeTimeframe,
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16.0),
              CheckboxListTile.adaptive(
                title: Text(
                  "preferences.pendingTransactions.requireConfirmation"
                      .t(context),
                ),
                value: requirePendingTransactionConfrimation,
                onChanged: updateRequirePendingTransactionConfrimation,
              ),
              const SizedBox(height: 16.0),
              if (requirePendingTransactionConfrimation) ...[
                CheckboxListTile.adaptive(
                  title: Text(
                    "preferences.pendingTransactions.updateDateUponConfirmation"
                        .t(context),
                  ),
                  subtitle: Text(
                    "preferences.pendingTransactions.updateDateUponConfirmation.description"
                        .t(context),
                  ),
                  value: pendingTransactionsUpdateDateUponConfirmation,
                  onChanged: updatePendingTransactionsConfirmationDate,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void updatePendingTransactionsHomeTimeframe(int days) async {
    await LocalPreferences().pendingTransactionsHomeTimeframe.set(days);

    if (mounted) setState(() {});
  }

  void updateRequirePendingTransactionConfrimation(
    bool? requirePendingTransactionConfrimation,
  ) async {
    if (requirePendingTransactionConfrimation == null) return;

    await LocalPreferences()
        .requirePendingTransactionConfrimation
        .set(requirePendingTransactionConfrimation);

    if (mounted) setState(() {});
  }

  void updatePendingTransactionsConfirmationDate(
    bool? newValue,
  ) async {
    if (newValue == null) return;

    await LocalPreferences()
        .pendingTransactionsUpdateDateUponConfirmation
        .set(newValue);

    if (mounted) setState(() {});
  }
}

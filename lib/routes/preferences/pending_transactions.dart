import "package:flow/l10n/extensions.dart";
import "package:flow/prefs.dart";
import "package:flow/widgets/general/info_text.dart";
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
    final bool requirePendingTransactionConfrimation =
        LocalPreferences().requirePendingTransactionConfrimation.get();

    return Scaffold(
      appBar: AppBar(
        title: Text("preferences.pendingTransactions".t(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile.adaptive(
                title: Text(
                    "preferences.pendingTransactions.requireConfirmation"
                        .t(context)),
                value: requirePendingTransactionConfrimation,
                onChanged: updateRequirePendingTransactionConfrimation,
              ),
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
            ],
          ),
        ),
      ),
    );
  }

  void updateRequirePendingTransactionConfrimation(
      bool? requirePendingTransactionConfrimation) async {
    if (requirePendingTransactionConfrimation == null) return;

    await LocalPreferences()
        .requirePendingTransactionConfrimation
        .set(requirePendingTransactionConfrimation);

    if (mounted) setState(() {});
  }
}

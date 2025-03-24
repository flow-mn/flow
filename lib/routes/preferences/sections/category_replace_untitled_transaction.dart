import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences_page.dart";
import "package:flow/services/user_preferences.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class UntitledTransactionFallback extends StatefulWidget {
  const UntitledTransactionFallback({super.key});

  @override
  State<UntitledTransactionFallback> createState() =>
      _UntitledTransactionFallbackState();
}

class _UntitledTransactionFallbackState
    extends State<UntitledTransactionFallback> {
  @override
  Widget build(BuildContext context) {
    final bool useCategoryNameForUntitledTransactions =
        UserPreferencesService().useCategoryNameForUntitledTransactions;

    return SwitchListTile /*.adaptive*/ (
      secondary: const Icon(Symbols.category_rounded),
      title: Text("preferences.transactions.fallbackToCategoryName".t(context)),
      value: useCategoryNameForUntitledTransactions,
      onChanged: updateUseCategoryNameForUntitledTransactions,
    );
  }

  void updateUseCategoryNameForUntitledTransactions(
    bool? newPrivacyMode,
  ) async {
    if (newPrivacyMode == null) return;

    UserPreferencesService().useCategoryNameForUntitledTransactions =
        newPrivacyMode;

    if (!mounted) return;

    PreferencesPage.of(context).reload();
    setState(() {});
  }
}

import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flutter/material.dart";

class MoneyFormattingPreferencesPage extends StatefulWidget {
  const MoneyFormattingPreferencesPage({super.key});

  @override
  State<MoneyFormattingPreferencesPage> createState() =>
      _MoneyFormattingPreferencesPageState();
}

class _MoneyFormattingPreferencesPageState
    extends State<MoneyFormattingPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final bool preferFullAmounts = LocalPreferences().preferFullAmounts.get();
    final bool useCurrencySymbol = LocalPreferences().useCurrencySymbol.get();

    return Scaffold(
      appBar: AppBar(title: Text("preferences.moneyFormatting".t(context))),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              Center(
                child: MoneyText(
                  Money(12345678.90, LocalPreferences().getPrimaryCurrency()),
                  initiallyAbbreviated: !preferFullAmounts,
                  tapToToggleAbbreviation: false,
                  style: context.textTheme.displaySmall,
                ),
              ),
              const SizedBox(height: 16.0),
              CheckboxListTile /*.adaptive*/ (
                title: Text(
                  "preferences.moneyFormatting.preferFull".t(context),
                ),
                subtitle: Text(
                  "preferences.moneyFormatting.preferFull.description".t(
                    context,
                  ),
                ),
                value: preferFullAmounts,
                onChanged: updatePreferFullAmounts,
              ),
              CheckboxListTile /*.adaptive*/ (
                title: Text(
                  "preferences.moneyFormatting.useCurrencySymbol".t(context),
                ),
                subtitle: Text(
                  "preferences.moneyFormatting.useCurrencySymbol.description".t(
                    context,
                  ),
                ),
                value: useCurrencySymbol,
                onChanged: updateUseCurrencySymbol,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updatePreferFullAmounts(bool? newPreferFullAmounts) async {
    if (newPreferFullAmounts == null) return;

    await LocalPreferences().preferFullAmounts.set(newPreferFullAmounts);

    if (mounted) setState(() {});
  }

  void updateUseCurrencySymbol(bool? newUseCurrencySymbol) async {
    if (newUseCurrencySymbol == null) return;

    await LocalPreferences().useCurrencySymbol.set(newUseCurrencySymbol);

    if (mounted) setState(() {});
  }
}

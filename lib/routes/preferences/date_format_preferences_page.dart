import "package:flow/data/prefs/date_format_preset.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class DateFormatPreferencesPage extends StatefulWidget {
  const DateFormatPreferencesPage({super.key});

  @override
  State<DateFormatPreferencesPage> createState() =>
      _DateFormatPreferencesPageState();
}

class _DateFormatPreferencesPageState extends State<DateFormatPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final DateFormatPreset dateFormatPreset =
        UserPreferencesService().dateFormatPreset;
    final bool transactionListAbsoluteDateHeaders =
        UserPreferencesService().transactionListAbsoluteDateHeaders;

    return Scaffold(
      appBar: AppBar(title: Text("preferences.dateFormat".t(context))),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              const SizedBox(height: 16.0),
              Center(
                child: Text(
                  _example(dateFormatPreset).lll,
                  style: context.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16.0),
              RadioGroup<DateFormatPreset>(
                groupValue: dateFormatPreset,
                onChanged: updateDateFormatPreset,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: DateFormatPreset.values
                      .map(
                        (preset) => RadioListTile<DateFormatPreset>(
                          title: Text(
                            preset == .system
                                ? "preferences.dateFormat.system".t(context)
                                : _example(preset).format("l"),
                          ),
                          subtitle: preset == .system
                              ? Text(_example(preset).format("l"))
                              : null,
                          value: preset,
                          activeColor: context.colorScheme.primary,
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16.0),
              SwitchListTile(
                title: Text(
                  "preferences.dateFormat.absoluteDateHeaders".t(context),
                ),
                value: transactionListAbsoluteDateHeaders,
                onChanged: updateTransactionListAbsoluteDateHeaders,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Moment _example(DateFormatPreset preset) =>
      Moment.now(localization: preset.apply(Moment.defaultLocalization));

  void updateDateFormatPreset(DateFormatPreset? newDateFormatPreset) {
    if (newDateFormatPreset == null) return;

    UserPreferencesService().dateFormatPreset = newDateFormatPreset;

    setState(() {});
  }

  void updateTransactionListAbsoluteDateHeaders(bool newValue) {
    UserPreferencesService().transactionListAbsoluteDateHeaders = newValue;

    setState(() {});
  }
}

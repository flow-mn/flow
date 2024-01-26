import 'package:flow/l10n/flow_localizations.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/widgets/general/bottom_sheet_frame.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LanguageSelectionSheet extends StatefulWidget {
  final Locale? currentLocale;

  const LanguageSelectionSheet({super.key, this.currentLocale});

  @override
  State<LanguageSelectionSheet> createState() => _LanguageSelectionSheetState();
}

class _LanguageSelectionSheetState extends State<LanguageSelectionSheet> {
  @override
  Widget build(BuildContext context) {
    return BottomSheetFrame(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            Text(
              "preferences.language.choose".t(context),
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16.0),
            ...FlowLocalizations.supportedLanguages.map(
              (locale) => ListTile(
                title: Text(locale.name),
                onTap: () => context.pop(locale),
                selected: widget.currentLocale == locale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

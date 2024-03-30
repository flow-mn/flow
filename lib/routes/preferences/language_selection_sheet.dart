import 'package:flow/l10n/flow_localizations.dart';
import 'package:flow/widgets/general/modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class LanguageSelectionSheet extends StatefulWidget {
  final Locale? currentLocale;

  const LanguageSelectionSheet({super.key, this.currentLocale});

  @override
  State<LanguageSelectionSheet> createState() => _LanguageSelectionSheetState();
}

class _LanguageSelectionSheetState extends State<LanguageSelectionSheet> {
  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      scrollableContentMaxHeight: MediaQuery.of(context).size.height,
      title: Text("preferences.language.choose".t(context)),
      trailing: ButtonBar(
        children: [
          TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Symbols.close_rounded),
            label: Text("general.cancel".t(context)),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ...FlowLocalizations.supportedLanguages.map(
              (locale) => ListTile(
                title: Text(locale.endonym),
                subtitle: Text(locale.name),
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

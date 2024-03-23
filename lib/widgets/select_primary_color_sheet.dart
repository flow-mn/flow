import 'package:flow/l10n/flow_localizations.dart';
import 'package:flow/widgets/general/modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class SelectPrimaryColorSheet extends StatefulWidget {
  final Locale? currentLocale;

  const SelectPrimaryColorSheet({super.key, this.currentLocale});

  @override
  State<SelectPrimaryColorSheet> createState() =>
      _SelectPrimaryColorSheetState();
}

class _SelectPrimaryColorSheetState extends State<SelectPrimaryColorSheet> {
  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      scrollableContentMaxHeight: MediaQuery.of(context).size.height,

      /// Add Localization
      title: const Text("Set a Primary Color"),
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

import "package:flow/l10n/flow_localizations.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with a [ThemeMode]
class ThemeSelectionSheet extends StatelessWidget {
  final ThemeMode? currentTheme;

  const ThemeSelectionSheet({super.key, this.currentTheme});

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      scrollableContentMaxHeight: MediaQuery.of(context).size.height,
      title: Text("preferences.themeMode.choose".t(context)),
      trailing: OverflowBar(
        alignment: MainAxisAlignment.end,
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
            ...ThemeMode.values.map(
              (themeMode) => RadioListTile<ThemeMode>.adaptive(
                title:
                    Text("preferences.themeMode.${themeMode.name}".t(context)),
                selected: currentTheme == themeMode,
                value: themeMode,
                groupValue: currentTheme,
                onChanged: (value) => context.pop(value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

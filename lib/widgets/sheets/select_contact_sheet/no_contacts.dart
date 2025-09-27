import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:permission_handler/permission_handler.dart";

class NoContacts extends StatelessWidget {
  const NoContacts({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "select.contact.empty".t(context),
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text(
              "select.contact.emptyPermissionSuggestion".t(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            TextButton.icon(
              onPressed: () => openAppSettings(),
              label: Text("select.contact.editPermissions".t(context)),
              icon: Icon(Symbols.open_in_new_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/empty_state.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons_flow/symbols.dart";
import "package:permission_handler/permission_handler.dart";

class NoContacts extends StatelessWidget {
  const NoContacts({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: Text("select.contact.empty".t(context)),
      subtitle: Text("select.contact.emptyPermissionSuggestion".t(context)),
      icon: FlowIconData.icon(Symbols.person_rounded),
      trailing: TextButton.icon(
        onPressed: () => openAppSettings(),
        label: Text("select.contact.editPermissions".t(context)),
        icon: Icon(Symbols.open_in_new_rounded),
      ),
    );
  }
}

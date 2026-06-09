import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/empty_state.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class NoAccounts extends StatelessWidget {
  const NoAccounts({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: FlowIconData.icon(Symbols.wallet_rounded),
      title: Text("account.noAccounts".t(context)),
      trailing: Button(
        trailing: const Icon(Symbols.add_rounded, weight: 600.0),
        child: Text("account.new".t(context)),
        onTap: () => context.push("/account/new"),
      ),
    );
  }
}

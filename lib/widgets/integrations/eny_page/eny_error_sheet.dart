import "package:flow/l10n/flow_localizations.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class EnyErrorSheet extends StatelessWidget {
  const EnyErrorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      trailing: ModalOverflowBar(
        alignment: .end,
        children: [
          Button(
            onTap: () => context.pop(false),
            child: Text("general.cancel".t(context)),
          ),
          Button(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              }
              context.push("/preferences/integrations/eny");
            },
            trailing: LeChevron(),
            child: Text(
              "integrations.eny.invalidCredentials.configure".t(context),
            ),
          ),
        ],
      ),
      title: Text("integrations.eny.invalidCredentials".t(context)),
      child: Text("integrations.eny.invalidCredentials.description".t(context)),
    );
  }
}

import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class AddAccountCard extends StatelessWidget {
  final BorderRadius borderRadius;

  const AddAccountCard({
    super.key,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
  });

  @override
  Widget build(BuildContext context) {
    return Surface(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (context) => InkWell(
        onTap: () => context.push("/account/new"),
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  FlowIcon(
                    FlowIconData.icon(Symbols.add_rounded),
                    size: 60.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    "setup.accounts.addAccount".t(context),
                    style: context.textTheme.titleSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

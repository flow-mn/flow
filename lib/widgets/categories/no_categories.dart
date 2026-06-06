import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/empty_state.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class NoCategories extends StatelessWidget {
  const NoCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: Text("categories.noCategories".t(context)),
      icon: FlowIconData.icon(Symbols.category_rounded),
      trailing: Button(
        trailing: const Icon(Symbols.add_rounded, weight: 600.0),
        child: Text("category.new".t(context)),
        onTap: () => context.push("/category/new"),
      ),
    );
  }
}

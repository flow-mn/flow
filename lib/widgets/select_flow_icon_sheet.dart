import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/select_flow_icon_sheet/select_char_flow_icon_sheet.dart";
import "package:flow/widgets/select_flow_icon_sheet/select_icon_flow_icon_sheet.dart";
import "package:flow/widgets/select_flow_icon_sheet/select_image_flow_icon_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with [FlowIconData] or [null]
class SelectFlowIconSheet extends StatefulWidget {
  final FlowIconData? current;

  final double iconSize;

  const SelectFlowIconSheet({super.key, this.current, this.iconSize = 96.0});

  @override
  State<SelectFlowIconSheet> createState() => _SelectFlowIconSheetState();
}

class _SelectFlowIconSheetState extends State<SelectFlowIconSheet>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("flowIcon.change".t(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Symbols.category_rounded),
            title: Text("flowIcon.type.icon".t(context)),
            onTap: () => _selectIcon(),
          ),
          ListTile(
            leading: const Icon(Symbols.glyphs_rounded),
            title: Text("flowIcon.type.character".t(context)),
            onTap: () => _selectEmoji(),
          ),
          ListTile(
            leading: const Icon(Symbols.image_rounded),
            title: Text("flowIcon.type.image".t(context)),
            onTap: () => _selectImage(),
          ),
        ],
      ),
    );
  }

  void _selectIcon() async {
    final FlowIconData? result = await showModalBottomSheet<IconFlowIcon>(
      context: context,
      builder:
          (context) => SelectIconFlowIconSheet(initialValue: widget.current),
      isScrollControlled: true,
    );

    if (mounted) {
      context.pop(result);
    }
  }

  void _selectEmoji() async {
    final FlowIconData? result = await showModalBottomSheet<CharacterFlowIcon>(
      context: context,
      builder:
          (context) => SelectCharFlowIconSheet(
            iconSize: widget.iconSize,
            initialValue: widget.current,
          ),
      isScrollControlled: true,
    );

    if (mounted) {
      context.pop(result);
    }
  }

  void _selectImage() async {
    final FlowIconData? result = await showModalBottomSheet<ImageFlowIcon>(
      context: context,
      builder:
          (context) => SelectImageFlowIconSheet(
            iconSize: widget.iconSize,
            initialValue: widget.current,
          ),
    );

    if (mounted) {
      context.pop(result);
    }
  }
}

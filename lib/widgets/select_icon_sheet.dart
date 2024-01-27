import 'dart:io';

import 'package:flow/data/flow_icon.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/utils.dart';
import 'package:flow/widgets/general/bottom_sheet_frame.dart';
import 'package:flow/widgets/general/surface.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Pops with [FlowIconData] or [null]
class SelectIconSheet extends StatefulWidget {
  final Function(FlowIconData? value)? onChange;
  final FlowIconData? current;

  const SelectIconSheet({super.key, this.current, this.onChange});

  @override
  State<SelectIconSheet> createState() => _SelectIconSheetState();
}

class _SelectIconSheetState extends State<SelectIconSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  late final TextEditingController _characterTextController;

  late FlowIconData? selected;

  @override
  void initState() {
    super.initState();

    selected = widget.current;

    final initialIndex = switch (selected) { ImageFlowIcon() => 1, _ => 0 };

    _characterTextController = TextEditingController(
        text: selected is CharacterFlowIcon
            ? (selected! as CharacterFlowIcon).character
            : null);

    _controller =
        TabController(length: 2, vsync: this, initialIndex: initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetFrame(
      child: Column(
        children: [
          TabBar(
            tabs: [
              // Tab(
              //   text: "flowIcon.type.icon".t(context),
              //   icon: const Icon(Symbols.category_rounded),
              // ),
              Tab(
                text: "flowIcon.type.character".t(context),
                icon: const Icon(Symbols.glyphs_rounded),
              ),
              Tab(
                text: "flowIcon.type.image".t(context),
                icon: const Icon(Symbols.image_rounded),
              ),
            ],
            controller: _controller,
          ),
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24.0),
                    // TODO center the text/emoji, see https://github.com/flutter/flutter/issues/119623 for details
                    Center(
                      child: Surface(
                        builder: (context) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox.square(
                            dimension: 80.0,
                            child: Center(
                              child: TextField(
                                autofocus: true,
                                showCursor: false,
                                cursorWidth: 0.0,
                                controller: _characterTextController,
                                onChanged: (_) => updateCharacter(),
                                style: TextStyle(
                                  fontSize: 40.0,
                                  height: 1.0,
                                  fontWeight: FontWeight.w500,
                                  color: context.colorScheme.onSecondary,
                                  decoration: null,
                                ),
                                textAlign: TextAlign.center,
                                decoration: null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      "flowIcon.type.character.description".t(context),
                      style: context.textTheme.bodySmall?.semi(context),
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text("Hello")],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _setValue(FlowIconData data) {
    selected = data;
    if (widget.onChange != null) {
      widget.onChange!(data);
    }
  }

  void updateCharacter() {
    if (_characterTextController.text.characters.isEmpty) return;

    _characterTextController.text =
        _characterTextController.text.characters.last;
    _setValue(FlowIconData.emoji(_characterTextController.text));
    setState(() {});
  }

  void updatePicture() async {
    final xfile = await pickImage(
      maxWidth: 512,
      maxHeight: 512,
    );
    if (xfile == null) return;

    final image = Image.file(File(xfile.path));
    // image.image
    // TODO complete image picker
  }
}

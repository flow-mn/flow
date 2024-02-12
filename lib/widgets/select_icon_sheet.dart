import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flow/data/flow_icon.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/utils.dart';
import 'package:flow/widgets/general/bottom_sheet_frame.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flow/widgets/general/surface.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as path;
import 'package:simple_icons/simple_icons.dart';
import 'package:uuid/uuid.dart';

/// Pops with [FlowIconData] or [null]
class SelectIconSheet extends StatefulWidget {
  final Function(FlowIconData? value)? onChange;
  final FlowIconData? current;

  final double iconSize;

  const SelectIconSheet({
    super.key,
    this.current,
    this.onChange,
    this.iconSize = 96.0,
  });

  @override
  State<SelectIconSheet> createState() => _SelectIconSheetState();
}

class _SelectIconSheetState extends State<SelectIconSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  late final TextEditingController _characterTextController;

  final FocusNode _textFieldFocusNode = FocusNode();

  late FlowIconData? selected;

  bool busy = false;

  late final VoidCallback? cleanUpImage;

  @override
  void initState() {
    super.initState();

    selected = widget.current;

    final initialIndex = switch (selected) {
      ImageFlowIcon() => 2,
      CharacterFlowIcon() => 1,
      _ => 0
    };

    _characterTextController = TextEditingController(
        text: selected is CharacterFlowIcon
            ? (selected! as CharacterFlowIcon).character
            : null);

    _controller = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialIndex,
    );

    _controller.addListener(() {
      if (!_controller.indexIsChanging) {
        if (_textFieldFocusNode.hasFocus && _controller.index != 1) {
          _textFieldFocusNode.unfocus();
        }
      }
    });

    _textFieldFocusNode.addListener(() {
      setState(() {});
    });

    if (selected is ImageFlowIcon) {
      final initialImagePath = (selected as ImageFlowIcon).imagePath;
      cleanUpImage = () {
        // If the image hasn't changed, no need to delete it.
        if (selected case ImageFlowIcon selectedImageIcon) {
          if (selectedImageIcon.imagePath == initialImagePath) {
            return;
          }
        }

        File(
          path.join(
            ObjectBox.appDataDirectory,
            initialImagePath,
          ),
        ).deleteSync();
      };
    } else {
      cleanUpImage = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _characterTextController.dispose();
    _textFieldFocusNode.dispose();

    if (cleanUpImage != null) {
      cleanUpImage!();
    }

    super.dispose();
  }

  final List<IconData> simpleIcons = SimpleIcons.values.values.toList();

  @override
  Widget build(BuildContext context) {
    return BottomSheetFrame(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(
                    text: "flowIcon.type.icon".t(context),
                    icon: const Icon(Symbols.category_rounded),
                  ),
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
                    GridView.builder(
                      itemBuilder: (context, index) => IconButton(
                        onPressed: () => updateIcon(simpleIcons[index]),
                        icon: Icon(simpleIcons[index]),
                        color: (selected is IconFlowIcon &&
                                simpleIcons[index] ==
                                    (selected as IconFlowIcon).iconData)
                            ? context.colorScheme.primary
                            : null,
                        iconSize: 48.0,
                      ),
                      itemCount: SimpleIcons.values.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 72.0,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 24.0),
                        // TODO center the text/emoji, see https://github.com/flutter/flutter/issues/119623 for details
                        Center(
                          child: Surface(
                            shape: RoundedRectangleBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(16.0),
                              ),
                              side: BorderSide(
                                color: (_textFieldFocusNode.hasPrimaryFocus ||
                                        _textFieldFocusNode.hasFocus)
                                    ? context.colorScheme.primary
                                    : kTransparent,
                                width: 2.0,
                              ),
                            ),
                            builder: (context) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox.square(
                                dimension: widget.iconSize,
                                child: Center(
                                  child: TextField(
                                    autofocus: true,
                                    focusNode: _textFieldFocusNode,
                                    showCursor: false,
                                    cursorWidth: 0.0,
                                    controller: _characterTextController,
                                    onChanged: (_) => updateCharacter(),
                                    style: TextStyle(
                                      fontSize: widget.iconSize * 0.5,
                                      height: 1.0,
                                      fontWeight: FontWeight.w500,
                                      color: context.colorScheme.onSecondary,
                                      decoration: null,
                                    ),
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      hintText: "?",
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                    ),
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
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 24.0),
                        FlowIcon(
                          selected is ImageFlowIcon
                              ? selected!
                              : FlowIconData.icon(Symbols.image_rounded),
                          size: widget.iconSize,
                          plated: true,
                          onTap: updatePicture,
                        ),
                        const SizedBox(height: 8.0),
                        TextButton.icon(
                          onPressed: updatePicture,
                          icon: const Icon(Symbols.add_photo_alternate_rounded),
                          label: Text(
                            "flowIcon.type.image.pick".t(context),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                      ],
                    ),
                    // InkWell(
                    //   onTap: updatePicture,
                    //   child: const Text("Select picture"),
                    // ),
                  ],
                ),
              ),
              ButtonBar(
                children: [
                  TextButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Symbols.check_rounded),
                    label: Text(
                      "general.done".t(context),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
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
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      final cropped = await pickAndCropSquareImage(context, maxDimension: 256);
      if (cropped == null) {
        // Error toast is handled in `pickAndCropSquareImage`
        return;
      }

      final byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();

      if (bytes == null) throw "";

      final dataDirectory = ObjectBox.appDataDirectory;
      final fileName = "${const Uuid().v4()}.png";
      final file = File(path.join(
        dataDirectory,
        "images",
        fileName,
      ));
      await file.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);

      _setValue(FlowIconData.image("images/$fileName"));
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      log("[Select Icon Sheet] uploadPicture has failed due to: $e");
    } finally {
      busy = false;
      if (mounted) setState(() {});
    }
  }

  void updateIcon(IconData iconData) async {
    _setValue(FlowIconData.icon(iconData));
    setState(() {});
  }
}

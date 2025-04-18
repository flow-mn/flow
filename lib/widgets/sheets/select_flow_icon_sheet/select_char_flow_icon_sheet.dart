import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class SelectCharFlowIconSheet extends StatefulWidget {
  final FlowIconData? initialValue;

  final double iconSize;

  const SelectCharFlowIconSheet({
    super.key,
    this.initialValue,
    required this.iconSize,
  });

  @override
  State<SelectCharFlowIconSheet> createState() =>
      _SelectCharFlowIconSheetState();
}

class _SelectCharFlowIconSheetState extends State<SelectCharFlowIconSheet> {
  late final TextEditingController _characterTextController;

  final FocusNode _textFieldFocusNode = FocusNode();

  CharacterFlowIcon? value;

  @override
  void initState() {
    super.initState();
    value =
        widget.initialValue is CharacterFlowIcon
            ? widget.initialValue as CharacterFlowIcon
            : null;
    _characterTextController = TextEditingController(text: value?.character);
  }

  @override
  Widget build(BuildContext context) {
    final double scrollableContentMaxHeight =
        MediaQuery.of(context).size.height * 0.3 -
        MediaQuery.of(context).viewInsets.vertical;

    return ModalSheet.scrollable(
      scrollableContentMaxHeight: scrollableContentMaxHeight,
      title: Text("flowIcon.type.character".t(context)),
      trailing: ModalOverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => context.pop(value),
            icon: const Icon(Symbols.check_rounded),
            label: Text("general.done".t(context)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24.0),
          // TODO center the text/emoji, see https://github.com/flutter/flutter/issues/119623 for details
          Center(
            child: Surface(
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                side: BorderSide(
                  color:
                      (_textFieldFocusNode.hasPrimaryFocus ||
                              _textFieldFocusNode.hasFocus)
                          ? context.colorScheme.primary
                          : kTransparent,
                  width: 2.0,
                ),
              ),
              builder:
                  (context) => Padding(
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
    );
  }

  void updateCharacter() {
    if (_characterTextController.text.characters.isEmpty) return;

    _characterTextController.text =
        _characterTextController.text.characters.last;
    value = CharacterFlowIcon(_characterTextController.text);
    setState(() {});
  }
}

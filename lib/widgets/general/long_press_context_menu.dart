import "package:flow/l10n/extensions.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class LongPressContextMenu extends StatefulWidget {
  /// Prepends a paste action. This requires [onPaste] to be set.
  final bool addPasteAction;

  final List<PopupMenuEntry<String>> actions;

  final ValueChanged<String?> onSelected;

  /// Called when the user pastes text. This requires [addPasteAction] to be `true`.
  final void Function(String text)? onPaste;

  final Widget child;

  const LongPressContextMenu({
    super.key,
    required this.child,
    required this.actions,
    required this.onSelected,
    this.addPasteAction = false,
    this.onPaste,
  });

  @override
  State<StatefulWidget> createState() => _LongPressContextMenuState();
}

class _LongPressContextMenuState extends State<LongPressContextMenu> {
  Offset _lastPointerPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        if (event.kind == PointerDeviceKind.mouse &&
            event.buttons == kSecondaryMouseButton) {
          _lastPointerPosition = event.position;

          _open();
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (TapDownDetails details) {
          _lastPointerPosition = details.globalPosition;
        },
        onLongPress: _open,
        child: widget.child,
      ),
    );
  }

  void _open() async {
    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    if (overlay == null) return;

    String? pasteText;

    if (widget.addPasteAction && widget.onPaste != null) {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);

      final String? text = clipboardData?.text?.trim();

      if (text != null && text.isNotEmpty) {
        pasteText = text;
      }
    }

    if (!mounted) return;

    final String? value = await showMenu<String>(
      context: context,
      items: [
        if (pasteText != null)
          PopupMenuItem<String>(
            value: "paste",
            child: Text("general.paste".t(context)),
          ),
        ...widget.actions
      ],
      position: RelativeRect.fromLTRB(
        _lastPointerPosition.dx,
        _lastPointerPosition.dy,
        overlay.size.width - _lastPointerPosition.dx,
        overlay.size.height - _lastPointerPosition.dy,
      ),
    );

    if (value == "paste") {
      widget.onPaste?.call(pasteText ?? "");
    } else {
      widget.onSelected(value);
    }
  }
}

import "package:cross_file/cross_file.dart";
import "package:desktop_drop/desktop_drop.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class ImageDropZone extends StatefulWidget {
  final Function(XFile? file)? onFileDropped;
  final VoidCallback? onTap;

  const ImageDropZone({super.key, this.onFileDropped, this.onTap});

  @override
  State<ImageDropZone> createState() => _ImageDropZoneState();
}

class _ImageDropZoneState extends State<ImageDropZone> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: DropTarget(
        onDragDone: (detail) {
          if (widget.onFileDropped != null) {
            widget.onFileDropped!(detail.files.firstOrNull);
          }
        },
        onDragEntered: (detail) => setState(() => _dragging = true),
        onDragExited: (detail) => setState(() => _dragging = false),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 96.0,
                horizontal: 16.0,
              ),
              height: double.infinity,
              width: double.infinity,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: .circular(16.0),
                child: Surface(
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(16.0),
                    alignment: .center,
                    child: Column(
                      mainAxisSize: .min,
                      children: [
                        FlowIcon(
                          FlowIconData.icon(Symbols.image_rounded),
                          size: 80.0,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "select.dropFile".t(context),
                          style: context.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "select.dropFile.acceptedTypes".t(
                            context,
                            "jpeg, png, webp, heic",
                          ),
                          style: context.textTheme.bodyMedium?.semi(context),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_dragging,
                child: AnimatedOpacity(
                  opacity: _dragging ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    color: context.colorScheme.primary,
                    child: Center(
                      child: Text(
                        "select.dropFile.dropHere".t(context),
                        style: context.textTheme.headlineMedium?.copyWith(
                          color: context.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

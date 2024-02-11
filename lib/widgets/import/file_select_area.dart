import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flow/data/flow_icon.dart';
import 'package:flow/l10n/extensions.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils/utils.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flow/widgets/general/surface.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class FileSelectArea extends StatefulWidget {
  final Function(XFile? file)? onFileDropped;
  final VoidCallback? onTap;

  const FileSelectArea({super.key, this.onFileDropped, this.onTap});

  @override
  State<FileSelectArea> createState() => _FileSelectAreaState();
}

class _FileSelectAreaState extends State<FileSelectArea> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final bool showDropText = isDesktop();

    return DropTarget(
      onDragDone: (detail) {
        if (widget.onFileDropped != null) {
          widget.onFileDropped!(detail.files.firstOrNull);
        }
      },
      onDragEntered: (detail) => setState(() => _dragging = true),
      onDragExited: (detail) => setState(() => _dragging = false),
      child: SizedBox.expand(
        child: _dragging
            ? Container(
                color: context.colorScheme.primary,
                child: Center(
                  child: Text(
                    "sync.import.pickFile.dropzone.active".t(context),
                    style: context.textTheme.headlineMedium
                        ?.copyWith(color: context.colorScheme.onPrimary),
                  ),
                ),
              )
            : Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(16.0),
                    child: Surface(
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FlowIcon(
                              FlowIconData.icon(
                                Symbols.cloud_upload_rounded,
                              ),
                              size: 80.0,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              showDropText
                                  ? "sync.import.pickFile.pickOrDrop".t(context)
                                  : "sync.import.pickFile".t(context),
                              style: context.textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "sync.import.pickFile.description".t(context),
                              style:
                                  context.textTheme.bodyMedium?.semi(context),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

import "dart:io";

import "package:flow/data/flow_icon.dart";
import "package:flow/objectbox.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:path/path.dart" as path;

class ProfilePicture extends StatefulWidget {
  final VoidCallback? onTap;

  final bool showOverlayUponHover;
  final IconData overlayIcon;

  final String? filePath;

  final double size;

  const ProfilePicture({
    super.key,
    this.size = 96.0,
    this.onTap,
    required this.filePath,
    this.showOverlayUponHover = false,
    this.overlayIcon = Symbols.add_a_photo_rounded,
  });

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  bool showOverlay = false;

  @override
  Widget build(BuildContext context) {
    final file =
        widget.filePath == null
            ? null
            : File(path.join(ObjectBox.imagesDirectory, widget.filePath!));

    final child = ClipOval(
      child: Container(
        color: context.colorScheme.primary,
        child:
            file?.existsSync() == true
                ? Image.file(file!, width: widget.size, height: widget.size)
                : FlowIcon(
                  const IconFlowIcon(Symbols.person_rounded),
                  size: widget.size,
                  color: context.colorScheme.onPrimary,
                ),
      ),
    );

    if (widget.onTap == null) {
      return child;
    }

    return MouseRegion(
      onEnter:
          widget.showOverlayUponHover
              ? (event) =>
                  setState(() => showOverlay = event.distance <= widget.size)
              : null,
      onExit:
          widget.showOverlayUponHover
              ? (event) => setState(() => showOverlay = false)
              : null,
      child: Stack(
        children: [
          child,
          InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(999.9),
            child: AnimatedOpacity(
              opacity: showOverlay ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x40000000),
                ),
                child: SizedBox.square(
                  dimension: widget.size,
                  child: Icon(
                    widget.overlayIcon,
                    size: widget.size / 2,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

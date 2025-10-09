import "dart:io";
import "dart:typed_data";

import "package:crop_image/crop_image.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class CropSquareImagePageProps {
  final File? file;
  final Uint8List? bytes;
  final double? maxDimension;

  CropSquareImagePageProps({this.bytes, this.file, this.maxDimension});
}

/// Pops with a [ui.Image] object
class CropSquareImagePage extends StatefulWidget {
  final File? file;
  final Uint8List? bytes;

  final double? maxDimension;

  const CropSquareImagePage({
    super.key,
    this.file,
    this.bytes,
    this.maxDimension,
  });
  factory CropSquareImagePage.fromProps({
    Key? key,
    required CropSquareImagePageProps props,
  }) => CropSquareImagePage(
    key: key,
    file: props.file,
    bytes: props.bytes,
    maxDimension: props.maxDimension,
  );

  @override
  State<CropSquareImagePage> createState() => _CropSquareImagePageState();
}

class _CropSquareImagePageState extends State<CropSquareImagePage> {
  final CropController _controller = CropController(aspectRatio: 1.0);

  bool busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: CropImage(
          controller: _controller,
          image: widget.file != null
              ? Image.file(widget.file!)
              : Image.memory(widget.bytes!),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Frame(
          child: Row(
            children: [
              IconButton(
                onPressed: () => _controller.rotateLeft(),
                icon: const Icon(Symbols.rotate_90_degrees_ccw_rounded),
              ),
              IconButton(
                onPressed: () => _controller.rotateRight(),
                icon: const Icon(Symbols.rotate_90_degrees_cw_rounded),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: done,
                label: Text("general.confirm".t(context)),
                icon: busy
                    ? const Spinner()
                    : const Icon(Symbols.check_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> done() async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    final image = await _controller.croppedBitmap(
      quality: FilterQuality.high,
      maxSize: widget.maxDimension,
    );

    if (!mounted) return;

    context.pop(image);
  }
}

import "package:crop_image/crop_image.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class CropSquareImagePageProps {
  final Image image;
  final double? maxDimension;

  /// If [false], returns [Image] object
  final bool returnBitmap;

  CropSquareImagePageProps({
    required this.image,
    this.maxDimension,
    this.returnBitmap = true,
  });
}

class CropSquareImagePage extends StatefulWidget {
  final Image image;

  final double? maxDimension;
  final bool returnBitmap;

  const CropSquareImagePage({
    super.key,
    required this.image,
    this.maxDimension,
    this.returnBitmap = true,
  });

  @override
  State<CropSquareImagePage> createState() => _CropSquareImagePageState();
}

class _CropSquareImagePageState extends State<CropSquareImagePage> {
  late final Image _image;

  final CropController _controller = CropController(
    aspectRatio: 1.0,
  );

  bool busy = false;

  @override
  void initState() {
    super.initState();

    _image = widget.image;
  }

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
          image: _image,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
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
                icon:
                    busy ? const Spinner() : const Icon(Symbols.check_rounded),
              )
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

    final image = widget.returnBitmap
        ? await _controller.croppedBitmap(
            quality: FilterQuality.high,
            maxSize: widget.maxDimension,
          )
        : await _controller.croppedImage(
            quality: FilterQuality.high,
          );

    if (!mounted) return;

    context.pop(image);
  }
}

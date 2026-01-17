import "dart:async";
import "dart:io";

import "package:camera/camera.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/camera.dart";
import "package:flow/services/integrations/eny.dart";
import "package:flow/utils/extensions/directionality.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/camera_page_base.dart";
import "package:flow/widgets/camera_page_base/overlay_button.dart";
import "package:flow/widgets/general/rtl_flipper.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/image_drop_zone.dart";
import "package:flow/widgets/integrations/eny_page/eny_error_sheet.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class EnyPage extends StatefulWidget {
  const EnyPage({super.key});

  @override
  State<EnyPage> createState() => _EnyPageState();
}

class _EnyPageState extends State<EnyPage> {
  final GlobalKey<CameraPageBaseState> _cameraPageKey =
      GlobalKey<CameraPageBaseState>();

  bool _busy = false;

  XFile? _takenPicture;

  @override
  Widget build(BuildContext context) {
    final bool isCameraSupported = Platform.isAndroid || Platform.isIOS;

    final IconData flashIcon = switch (_cameraPageKey.currentState?.flashMode) {
      FlashMode.auto => Symbols.flash_auto_rounded,
      FlashMode.always => Symbols.flash_on_rounded,
      FlashMode.torch => Symbols.flashlight_on_rounded,
      _ => Symbols.flash_off_rounded,
    };

    final List<Widget> topButtons = [
      OverlayButton(
        child: RTLFlipper(child: Icon(Symbols.chevron_left_rounded)),
        onTap: () {
          if (context.canPop()) {
            context.pop();
          }
        },
      ),
      if (isCameraSupported)
        OverlayButton(
          child: Icon(flashIcon),
          onTap: () {
            _cameraPageKey.currentState?.rotateFlashMode();
            setState(() {});
          },
        ),
    ];

    final List<Widget> bottomButtons = [
      (CameraService.cameras?.length ?? 0) > 1
          ? OverlayButton(
              onTap: () {
                setState(() {});
              },
              child: Icon(Symbols.switch_camera_rounded),
            )
          : Opacity(
              opacity: 0,
              child: IgnorePointer(
                child: OverlayButton(
                  onTap: () {},
                  child: Icon(Icons.switch_camera_rounded),
                ),
              ),
            ),
      if (_takenPicture != null || isCameraSupported)
        OverlayButton(
          onTap: _busy
              ? null
              : (_takenPicture == null ? _takePicture : _sendTakenPicture),
          child: SizedBox.square(
            dimension: 24.0,
            child: _busy
                ? const Spinner.center()
                : Icon(
                    _takenPicture == null
                        ? Symbols.photo_camera_rounded
                        : Symbols.send_rounded,
                  ),
          ),
        ),
      OverlayButton(
        onTap: _selectMultiImageFromGallery,
        child: Icon(Symbols.photo_library_rounded),
      ),
    ];

    return CameraPageBase(
      key: _cameraPageKey,
      unsupportedWidget: Positioned.fill(
        child: SafeArea(
          child: ImageDropZone(
            onFileDropped: (file) {
              if (file?.mimeType?.startsWith("image") == true) {
                _takenPicture = file;
                setState(() {});
              }
            },
            onTap: _selectMultiImageFromGallery,
          ),
        ),
      ),
      children: [
        if (_takenPicture != null)
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: Image.file(File(_takenPicture!.path), fit: BoxFit.contain),
            ),
          ),
        Positioned(
          top: 20.0,
          left: 20.0,
          right: 20.0,
          child: SafeArea(
            child: Row(
              spacing: 12.0,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: context.isRtl
                  ? topButtons.reversed.toList()
                  : topButtons,
            ),
          ),
        ),
        Positioned(
          bottom: 20.0,
          left: 20.0,
          right: 20.0,
          child: SafeArea(
            child: Row(
              spacing: 12.0,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: context.isRtl
                  ? bottomButtons.reversed.toList()
                  : bottomButtons,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectMultiImageFromGallery() async {
    final List<XFile>? files = await pickMultipleMediaFiles();

    if (files == null || files.isEmpty) {
      return;
    }

    if (files.length == 1) {
      _takenPicture = files.first;
      setState(() {});
    } else {
      // show popup here
      await Future.wait(files.map((file) => EnyService().processReceipt(file)));
    }
  }

  Future<void> _takePicture() async {
    if (_busy) {
      return;
    }

    if (_cameraPageKey.currentState?.controller == null) {
      return;
    }

    setState(() {
      _takenPicture = null;
      _busy = true;
    });

    try {
      final XFile? picture = await _cameraPageKey.currentState?.controller
          ?.takePicture();

      _takenPicture = picture;
    } catch (e) {
      // Ignore errors
    } finally {
      _busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _sendTakenPicture() async {
    if (_busy) {
      return;
    }

    if (_takenPicture == null) {
      return;
    }

    setState(() {
      _busy = true;
    });

    if (LocalPreferences().enableHapticFeedback.get()) {
      unawaited(HapticFeedback.lightImpact().catchError((_) {}));
    }

    try {
      await EnyService().processReceipt(_takenPicture!);
    } catch (e) {
      if (e is EnyCredsError) {
        if (mounted) {
          await showModalBottomSheet(
            context: context,
            builder: (context) => EnyErrorSheet(),
            isScrollControlled: true,
          );
        }
      }
    } finally {
      _busy = false;
      _takenPicture = null;
      if (mounted) {
        setState(() {});
      }
    }
  }
}

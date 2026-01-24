import "dart:async";
import "dart:io";

import "package:camera/camera.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/camera.dart";
import "package:flow/services/integrations/eny.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/extensions/directionality.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/animated_eny_logo.dart";
import "package:flow/widgets/camera_page_base.dart";
import "package:flow/widgets/camera_page_base/overlay_button.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/general/rtl_flipper.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/image_drop_zone.dart";
import "package:flow/widgets/integrations/eny_page/eny_error_sheet.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
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

  bool _flashBusy = false;
  bool _lensChangeBusy = false;

  XFile? _takenPicture;

  bool get isCameraSupported => Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    CameraService.ensureInitialized().then((_) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final IconData flashIcon = switch (_cameraPageKey.currentState?.flashMode) {
      FlashMode.auto => Symbols.flash_auto_rounded,
      FlashMode.always => Symbols.flash_on_rounded,
      FlashMode.torch => Symbols.flashlight_on_rounded,
      _ => Symbols.flash_off_rounded,
    };

    final List<Widget> topButtons = [
      OverlayButton(
        child: _takenPicture == null
            ? RTLFlipper(child: Icon(Symbols.chevron_left_rounded))
            : Icon(Symbols.close_rounded),
        onTap: () {
          if (_takenPicture != null) {
            setState(() {
              _takenPicture = null;
            });
          } else if (context.canPop()) {
            context.pop();
          }
        },
      ),
      if (isCameraSupported && CameraService.cameras?.isNotEmpty == true)
        OverlayButton(
          child: Icon(flashIcon),
          onTap: () async {
            if (_flashBusy) return;

            setState(() {
              _flashBusy = true;
            });

            try {
              await _cameraPageKey.currentState?.rotateFlashMode();
            } finally {
              _flashBusy = false;
              if (mounted) {
                setState(() {});
              }
            }
          },
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
            child: Image.file(File(_takenPicture!.path), fit: BoxFit.cover),
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
          child: SafeArea(child: buildBottomButtons(context)),
        ),
      ],
    );
  }

  Widget buildBottomButtons(BuildContext context) {
    if (_takenPicture != null) {
      return Column(
        spacing: 16.0,
        mainAxisSize: .min,
        children: [
          OverlayButton(
            child: Icon(
              Symbols.delete_forever_rounded,
              color: context.colorScheme.error,
            ),
            onTap: () {
              _takenPicture = null;
              setState(() {});
            },
          ),
          Button(
            trailing: _busy
                ? const SizedBox.square(dimension: 24.0, child: Spinner())
                : Icon(Symbols.send_rounded),
            onTap: _busy ? null : _sendTakenPicture,
            child: Text("integrations.eny.send".t(context)),
          ),
        ],
      );
    }

    final List<Widget> buttons = [
      (CameraService.cameras?.length ?? 0) > 1
          ? OverlayButton(
              onTap: () async {
                if (_lensChangeBusy) return;
                setState(() {
                  _lensChangeBusy = true;
                });
                try {
                  await _cameraPageKey.currentState?.rotateCamera();
                } finally {
                  _lensChangeBusy = false;
                  if (mounted) {
                    setState(() {});
                  }
                }
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
      if (_takenPicture != null ||
          (isCameraSupported && CameraService.cameras?.isNotEmpty == true))
        OverlayButton(
          onTap: _busy ? null : _takePicture,
          child: SizedBox.square(
            dimension: 24.0,
            child: _busy
                ? const Spinner.center()
                : Icon(Symbols.photo_camera_rounded),
          ),
        ),
      OverlayButton(
        onTap: _selectMultiImageFromGallery,
        child: Icon(Symbols.photo_library_rounded),
      ),
    ];
    return Row(
      spacing: 12.0,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: context.isRtl ? buttons.reversed.toList() : buttons,
    );
  }

  Future<void> _selectMultiImageFromGallery() async {
    final List<XFile>? files = await pickMultipleMediaFiles(limit: 5);

    if (files == null || files.isEmpty) {
      return;
    }

    if (!mounted) {
      return;
    }

    if (files.length == 1) {
      _takenPicture = files.first;
      setState(() {});
    } else {
      final bool? confirmed = await context.showConfirmationSheet(
        title: "integrations.eny.multipleImagesNotice".t(context, files.length),
        child: Column(
          mainAxisSize: .min,
          spacing: 12.0,
          children: [
            RichText(
              text: TextSpan(
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: .bold,
                ),
                children: [
                  WidgetSpan(
                    child: SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: AnimatedEnyLogo(),
                    ),
                    alignment: .middle,
                  ),
                  TextSpan(text: " "),
                  TextSpan(
                    text: "integrations.eny.multipleImagesNotice.description".t(
                      context,
                      files.length,
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: .horizontal,
              child: Row(
                spacing: 12.0,
                children: files
                    .map(
                      (file) => ClipRRect(
                        borderRadius: .all(.circular(12.0)),
                        child: SizedBox(
                          width: 80.0,
                          height: 80.0,
                          child: Image.file(File(file.path), fit: BoxFit.cover),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            InfoText(
              child: Text(
                "integrations.eny.multipleImagesNotice.checkNotice".t(context),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        return;
      }

      await Future.wait(files.map((file) => EnyService().processReceipt(file)));
      if (mounted) {
        context.showToast(text: "integrations.eny.sent".t(context));
        if (context.canPop()) {
          context.pop();
        }
      }
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
      if (mounted) {
        context.showToast(text: "integrations.eny.sent".t(context));
        if (context.canPop()) {
          context.pop();
        }
      }
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

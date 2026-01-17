import "dart:io";

import "package:camera/camera.dart";
import "package:flow/services/camera.dart";
import "package:flow/utils/utils.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("CameraPageBase");

class CameraPageBase extends StatefulWidget {
  final CameraLensDirection? preferredCamera;
  final List<Widget> children;

  final Widget? unsupportedWidget;

  const CameraPageBase({
    super.key,
    required this.children,
    this.preferredCamera = .back,
    this.unsupportedWidget,
  });

  @override
  State<CameraPageBase> createState() => CameraPageBaseState();
}

class CameraPageBaseState extends State<CameraPageBase>
    with WidgetsBindingObserver {
  CameraController? controller;

  FlashMode? _flashMode;
  FlashMode get flashMode => _flashMode ?? FlashMode.off;

  @override
  void initState() {
    super.initState();
    if (!CameraService.initialized) {
      CameraService.initialize().then((_) {
        if (!mounted) return;
        _initializeCameraController();
      });
    } else {
      _initializeCameraController();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSupported =
        (Platform.isAndroid || Platform.isIOS) &&
        CameraService.cameras?.isNotEmpty == true;

    return Stack(
      children: [
        if (isSupported)
          Positioned.fill(
            child: controller == null || !controller!.value.isInitialized
                ? const Center(child: CircularProgressIndicator())
                : CameraPreview(controller!),
          ),
        if (!isSupported)
          widget.unsupportedWidget ??
              Material(child: Center(child: Text("Camera not supported :("))),

        ...widget.children,
      ],
    );
  }

  void _initializeCameraController() async {
    final CameraDescription? description =
        CameraService.cameras?.firstWhereOrNull(
          (camera) => camera.lensDirection == widget.preferredCamera,
        ) ??
        CameraService.cameras?.firstOrNull;

    if (description == null) {
      _log.severe("No camera found");
      return;
    }

    final CameraController cameraController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        _log.severe("Camera error", cameraController.value.errorDescription);
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      _log.severe("Camera exception", e.description);
    } catch (e) {
      _log.severe("Unknown camera error", e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  FlashMode rotateFlashMode() {
    if (controller == null) {
      return FlashMode.off;
    }

    final FlashMode currentMode = controller!.value.flashMode;
    final FlashMode newMode = switch (currentMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      FlashMode.always => FlashMode.torch,
      FlashMode.torch => FlashMode.off,
    };

    controller!.setFlashMode(newMode);
    _flashMode = newMode;
    return newMode;
  }
}

import "dart:io";

import "package:camera/camera.dart";
import "package:flow/services/camera.dart";
import "package:flow/utils/utils.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
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

    WidgetsBinding.instance.addObserver(this);

    CameraService.ensureInitialized().then((_) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _initializeCameraController();
        setState(() {});
      });
    });
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
    WidgetsBinding.instance.removeObserver(this);
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
                : cameraWidget(context, controller!),
          ),
        if (!isSupported)
          widget.unsupportedWidget ??
              Material(child: Center(child: Text("Camera not supported :("))),

        ...widget.children,
      ],
    );
  }

  Widget cameraWidget(BuildContext context, CameraController controller) {
    final CameraValue camera = controller.value;

    final Size size = MediaQuery.sizeOf(context);

    double scale = size.aspectRatio * camera.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(child: CameraPreview(controller)),
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

  Future<FlashMode> rotateFlashMode() async {
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

    await controller!.setFlashMode(newMode);
    _flashMode = newMode;
    return newMode;
  }

  Future<CameraDescription?> rotateCamera() async {
    if (controller != null) {
      final CameraDescription currentDescription = controller!.description;
      final int currentIndex = CameraService.cameras!.indexWhere(
        (c) => c.name == currentDescription.name,
      );
      final int nextIndex = (currentIndex + 1) % CameraService.cameras!.length;
      final CameraDescription nextDescription =
          CameraService.cameras![nextIndex];
      await controller!.setDescription(nextDescription);
      return nextDescription;
    } else {
      _initializeCameraController();
      return CameraService.cameras?.firstWhereOrNull(
            (camera) => camera.lensDirection == widget.preferredCamera,
          ) ??
          CameraService.cameras?.firstOrNull;
    }
  }
}

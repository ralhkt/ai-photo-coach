import 'dart:async';
import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/camera_constants.dart';

class CameraService {
  CameraController? _controller;

  CameraController? get controller => _controller;

  static Future<List<CameraDescription>> listCameras() {
    return availableCameras();
  }

  static Future<bool> requestPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> hasPermission() async {
    return Permission.camera.isGranted;
  }

  static ResolutionPreset resolutionFor(CameraDescription camera) {
    if (camera.lensDirection == CameraLensDirection.front) {
      return CameraConstants.frontPreviewResolution;
    }
    return CameraConstants.previewResolution;
  }

  Future<CameraController> initialize(
    CameraDescription camera, {
    FlashMode flashMode = FlashMode.auto,
  }) async {
    final hasAccess = await hasPermission() || await requestPermission();
    if (!hasAccess) {
      throw CameraException(
        'permission_denied',
        'Camera permission was not granted.',
      );
    }

    await _releasePreviousController();
    return _createController(camera, flashMode: flashMode);
  }

  /// Switches lenses — must release the previous iOS capture session first.
  Future<CameraController> switchTo(
    CameraDescription camera, {
    FlashMode flashMode = FlashMode.auto,
  }) async {
    await _releasePreviousController();
    return _createController(
      camera,
      flashMode: flashMode,
      deferFlash: true,
    );
  }

  Future<void> _releasePreviousController() async {
    final previous = _controller;
    _controller = null;
    if (previous == null) {
      return;
    }

    try {
      if (previous.value.isStreamingImages) {
        await previous.stopImageStream();
      }
    } catch (_) {}

    try {
      if (previous.value.isInitialized) {
        await previous.pausePreview();
      }
    } catch (_) {}

    try {
      await previous.dispose();
    } catch (error) {
      debugPrint('CameraService: dispose failed: $error');
    }

    if (!kIsWeb && Platform.isIOS) {
      await Future<void>.delayed(CameraConstants.iosSessionReleaseDelay);
    }
  }

  Future<CameraController> _createController(
    CameraDescription camera, {
    required FlashMode flashMode,
    bool deferFlash = false,
  }) async {
    final controller = CameraController(
      camera,
      resolutionFor(camera),
      enableAudio: false,
      imageFormatGroup: _preferredImageFormat(),
    );

    await controller.initialize();

    if (controller.value.isInitialized) {
      if (deferFlash) {
        unawaited(_safeSetFlashMode(controller, flashMode));
      } else {
        await _safeSetFlashMode(controller, flashMode);
      }
    }

    _controller = controller;
    return controller;
  }

  Future<void> _safeSetFlashMode(
    CameraController controller,
    FlashMode flashMode,
  ) async {
    try {
      await controller.setFlashMode(flashMode);
    } catch (_) {
      try {
        await controller.setFlashMode(FlashMode.off);
      } catch (_) {}
    }
  }

  static ImageFormatGroup _preferredImageFormat() {
    if (kIsWeb) {
      return ImageFormatGroup.jpeg;
    }
    if (Platform.isIOS) {
      return ImageFormatGroup.bgra8888;
    }
    if (Platform.isAndroid) {
      return ImageFormatGroup.yuv420;
    }
    return ImageFormatGroup.jpeg;
  }

  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      await controller.dispose();
    }
  }
}
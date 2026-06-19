import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

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
    return _createController(camera, flashMode: flashMode);
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
      await previous.dispose();
    } catch (error) {
      debugPrint('CameraService: dispose failed: $error');
    }

    if (!kIsWeb && Platform.isIOS) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
  }

  Future<CameraController> _createController(
    CameraDescription camera, {
    required FlashMode flashMode,
  }) async {
    final preset = !kIsWeb && Platform.isIOS
        ? ResolutionPreset.low
        : ResolutionPreset.high;

    final controller = CameraController(
      camera,
      preset,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller.initialize();

    if (controller.value.isInitialized) {
      try {
        await controller.setFlashMode(flashMode);
      } catch (_) {
        await controller.setFlashMode(FlashMode.off);
      }
    }

    _controller = controller;
    return controller;
  }

  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      await controller.dispose();
    }
  }
}
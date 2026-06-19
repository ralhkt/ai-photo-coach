import 'dart:async';
import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// iOS pose coaching frame source — prefers [CameraController.startImageStream]
/// over [takePicture] to avoid freezing the native preview layer.
class PosePreviewFrameSource {
  bool _streamActive = false;
  CameraImage? _latest;
  DateTime _lastFrameAt = DateTime.fromMillisecondsSinceEpoch(0);

  bool get usesImageStream => _streamActive;

  /// Starts a throttled BGRA stream. Returns false when unsupported.
  Future<bool> tryStartStream(CameraController controller) async {
    if (kIsWeb || !Platform.isIOS || _streamActive) {
      return _streamActive;
    }
    if (!controller.value.isInitialized || controller.value.isStreamingImages) {
      return false;
    }

    try {
      await controller.startImageStream(_onFrame);
      _streamActive = true;
      return true;
    } catch (error) {
      debugPrint('PosePreviewFrameSource: image stream unavailable: $error');
      _streamActive = false;
      return false;
    }
  }

  void _onFrame(CameraImage image) {
    _latest = image;
    _lastFrameAt = DateTime.now();
  }

  /// Returns the newest frame if it is fresher than [maxAge].
  CameraImage? consumeLatest({Duration maxAge = const Duration(seconds: 2)}) {
    final frame = _latest;
    if (frame == null) {
      return null;
    }
    if (DateTime.now().difference(_lastFrameAt) > maxAge) {
      return null;
    }
    return frame;
  }

  Future<void> stop(CameraController? controller) async {
    _latest = null;
    _streamActive = false;
    if (controller == null || !controller.value.isStreamingImages) {
      return;
    }
    try {
      await controller.stopImageStream();
    } catch (error) {
      debugPrint('PosePreviewFrameSource: stop stream failed: $error');
    }
  }
}
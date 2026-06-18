import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/scene_stability_provider.dart';
import 'scene_change_detector.dart';

class CameraFrameMonitor {
  CameraFrameMonitor(this._ref);

  final Ref _ref;
  final SceneChangeDetector _detector = SceneChangeDetector();
  CameraController? _controller;
  bool _isMonitoring = false;
  DateTime _lastProcessed = DateTime.fromMillisecondsSinceEpoch(0);
  static const _minInterval = Duration(milliseconds: 800);

  Future<void> start(CameraController controller) async {
    if (_isMonitoring && identical(_controller, controller)) {
      return;
    }

    await stop();
    _controller = controller;
    _detector.reset();
    _ref.read(sceneStabilityProvider.notifier).setMonitoring();

    if (!controller.value.isInitialized) {
      return;
    }

    try {
      await controller.startImageStream(_onFrame);
      _isMonitoring = true;
    } catch (error) {
      debugPrint('CameraFrameMonitor: image stream unavailable: $error');
    }
  }

  Future<void> stop() async {
    final controller = _controller;
    _controller = null;
    _isMonitoring = false;
    _detector.reset();
    Future.microtask(() {
      _ref.read(sceneStabilityProvider.notifier).reset();
    });

    if (controller != null && controller.value.isStreamingImages) {
      try {
        await controller.stopImageStream();
      } catch (_) {}
    }
  }

  void _onFrame(CameraImage image) {
    final now = DateTime.now();
    if (now.difference(_lastProcessed) < _minInterval) {
      return;
    }
    _lastProcessed = now;

    try {
      final result = _detector.evaluate(image);
      final notifier = _ref.read(sceneStabilityProvider.notifier);
      if (result.isStable) {
        notifier.reportStable(hammingDistance: result.hammingDistance);
      } else {
        notifier.reportChanged(hammingDistance: result.hammingDistance);
      }
    } catch (error) {
      debugPrint('CameraFrameMonitor: frame analysis failed: $error');
    }
  }
}

final cameraFrameMonitorProvider = Provider<CameraFrameMonitor>((ref) {
  final monitor = CameraFrameMonitor(ref);
  ref.onDispose(() {
    monitor.stop();
  });
  return monitor;
});
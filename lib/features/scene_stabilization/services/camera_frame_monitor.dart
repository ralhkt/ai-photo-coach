import 'dart:async';
import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/performance/performance_budget.dart';
import '../../../core/settings/app_settings_provider.dart';
import '../providers/scene_stability_provider.dart';
import 'scene_change_detector.dart';

class CameraFrameMonitor {
  CameraFrameMonitor(this._ref);

  final Ref _ref;
  final SceneChangeDetector _detector = SceneChangeDetector();
  CameraController? _controller;
  bool _isMonitoring = false;
  DateTime _lastProcessed = DateTime.fromMillisecondsSinceEpoch(0);
  Duration _minInterval =
      const Duration(milliseconds: PerformanceBudget.phashFrameIntervalMs);

  Future<void> start(CameraController controller) async {
    if (_isMonitoring && identical(_controller, controller)) {
      return;
    }

    await stop();
    _controller = controller;
    final powerSave = _ref.read(powerSaveEnabledProvider);
    _minInterval = Duration(
      milliseconds: powerSave
          ? PerformanceBudget.phashFrameIntervalPowerSaveMs
          : PerformanceBudget.phashFrameIntervalMs,
    );
    _detector.reset();
    _ref.read(sceneStabilityProvider.notifier).setMonitoring();

    if (!controller.value.isInitialized) {
      return;
    }

    // iOS: image stream deadlocks with CameraPreview + takePicture — keep preview live.
    if (!kIsWeb && Platform.isIOS) {
      _controller = controller;
      _isMonitoring = false;
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

  /// Pauses the image stream so [takePicture] can run without deadlocking iOS.
  Future<T> runExclusive<T>(
    Future<T> Function() action, {
    bool resumeStream = true,
  }) async {
    if (!kIsWeb && Platform.isIOS) {
      return action();
    }

    final controller = _controller;
    final wasMonitoring = _isMonitoring;

    if (wasMonitoring && controller != null && controller.value.isStreamingImages) {
      try {
        await controller.stopImageStream();
      } catch (_) {}
      _isMonitoring = false;
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }

    try {
      return await action();
    } finally {
      if (resumeStream &&
          wasMonitoring &&
          controller != null &&
          controller.value.isInitialized &&
          !_isMonitoring) {
        try {
          await controller.startImageStream(_onFrame);
          _controller = controller;
          _isMonitoring = true;
        } catch (error) {
          debugPrint('CameraFrameMonitor: failed to resume stream: $error');
        }
      }
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
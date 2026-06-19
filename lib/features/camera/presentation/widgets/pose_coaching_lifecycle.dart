import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ar/providers/ar_providers.dart';
import '../../../ar/services/device_attitude_service.dart';
import '../../providers/camera_capture_provider.dart';
import '../../providers/camera_providers.dart';
import '../../providers/camera_settings_provider.dart';
import '../../providers/live_scene_analysis_provider.dart';
import '../../../pose/providers/pose_coaching_provider.dart';

/// Polls preview frames + gyro attitude for live pose coaching (iOS-safe).
///
/// Uses [capturePreviewFrame] instead of [CameraController.startImageStream] so
/// guided mode works on iOS where preview + image stream deadlocks.
class PoseCoachingLifecycle extends ConsumerStatefulWidget {
  const PoseCoachingLifecycle({super.key});

  @override
  ConsumerState<PoseCoachingLifecycle> createState() =>
      _PoseCoachingLifecycleState();
}

class _PoseCoachingLifecycleState extends ConsumerState<PoseCoachingLifecycle> {
  Timer? _timer;
  bool _tickInFlight = false;
  double _latestRoll = 0;

  Duration get _frameInterval {
    if (kIsWeb) {
      return const Duration(milliseconds: 900);
    }
    return Platform.isIOS
        ? const Duration(milliseconds: 850)
        : const Duration(milliseconds: 550);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_syncLoop);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _syncLoop() {
    if (!mounted) {
      return;
    }

    final shouldRun = ref.read(poseCoachingShouldRunProvider);
    if (shouldRun && _timer == null) {
      _timer = Timer.periodic(_frameInterval, (_) => unawaited(_tick()));
      unawaited(_tick());
    } else if (!shouldRun && _timer != null) {
      _timer?.cancel();
      _timer = null;
      ref.read(poseCoachingResultProvider.notifier).state = null;
      ref.read(poseCoachingServiceProvider).reset();
    }
  }

  bool _isCameraBusy() {
    return ref.read(isCapturingProvider) ||
        ref.read(isBurstingProvider) ||
        ref.read(timerCountdownProvider) != null ||
        ref.read(liveSceneAnalyzingProvider);
  }

  Future<void> _tick() async {
    if (!mounted || _tickInFlight || !ref.read(poseCoachingShouldRunProvider)) {
      return;
    }
    if (_isCameraBusy()) {
      return;
    }

    final controller = ref.read(cameraControllerProvider).value;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    _tickInFlight = true;
    try {
      final bytes =
          await ref.read(cameraControllerProvider.notifier).capturePreviewFrame();
      if (!mounted || bytes == null || bytes.isEmpty) {
        return;
      }

      final result = await ref.read(poseCoachingServiceProvider).evaluatePreviewFrame(
            bytes: bytes,
            rollAngle: _latestRoll,
          );

      if (!mounted || result == null) {
        return;
      }

      ref.read(poseCoachingResultProvider.notifier).state = result;
    } finally {
      _tickInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(poseCoachingShouldRunProvider, (_, __) {
      _syncLoop();
    });

    ref.listen<AsyncValue<DeviceAttitude>>(
      deviceAttitudeProvider,
      (_, next) {
        _latestRoll = next.value?.rollDegrees ?? _latestRoll;
      },
    );

    final attitude = ref.watch(deviceAttitudeProvider).value;
    if (attitude != null) {
      _latestRoll = attitude.rollDegrees;
    }

    return const SizedBox.shrink();
  }
}
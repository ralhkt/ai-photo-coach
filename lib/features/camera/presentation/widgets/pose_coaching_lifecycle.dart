import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ar/providers/ar_providers.dart';
import '../../../ar/services/device_attitude_service.dart';
import '../../../../core/settings/app_settings_provider.dart';
import '../../providers/camera_capture_provider.dart';
import '../../providers/camera_providers.dart';
import '../../providers/camera_settings_provider.dart';
import '../../providers/live_scene_analysis_provider.dart';
import '../../../pose/models/pose_coaching_result.dart';
import '../../../pose/providers/pose_coaching_provider.dart';

/// Polls preview frames + attitude for live pose coaching (iOS-safe).
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
  DateTime _lastCapture = DateTime.fromMillisecondsSinceEpoch(0);
  Duration _captureInterval = const Duration(milliseconds: 550);
  PoseCoachingResult? _lastResult;

  Duration get _fallbackInterval {
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
    _captureInterval = _fallbackInterval;
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
      _timer = Timer.periodic(const Duration(milliseconds: 120), (_) {
        unawaited(_tick());
      });
      unawaited(_tick());
    } else if (!shouldRun && _timer != null) {
      _timer?.cancel();
      _timer = null;
      _lastResult = null;
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

    final service = ref.read(poseCoachingServiceProvider);
    final powerSave = ref.read(powerSaveEnabledProvider);
    _captureInterval = service.captureScheduler.nextInterval(
      lastResult: _lastResult,
      powerSave: powerSave,
    );

    final now = DateTime.now();
    if (!service.captureScheduler.shouldCapture(_lastCapture, _captureInterval, now: now)) {
      return;
    }

    final controller = ref.read(cameraControllerProvider).value;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (!service.shouldRunInference(now: now)) {
      return;
    }

    _tickInFlight = true;
    try {
      final bytes =
          await ref.read(cameraControllerProvider.notifier).capturePreviewFrame();
      if (!mounted || bytes == null || bytes.isEmpty) {
        return;
      }

      _lastCapture = now;
      final trendyTemplate = ref.read(activeTrendyTemplateProvider);
      final result = await service.evaluatePreviewFrame(
        bytes: bytes,
        rollAngle: _latestRoll,
        trendyTemplate: trendyTemplate,
        now: now,
      );

      if (!mounted || result == null) {
        return;
      }

      _lastResult = result;
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
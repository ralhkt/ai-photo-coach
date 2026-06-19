import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ar/providers/ar_providers.dart';
import '../../../ar/services/device_attitude_service.dart';
import '../../../../core/settings/app_settings_provider.dart';
import '../../providers/camera_capture_provider.dart';
import '../../providers/camera_interaction_provider.dart';
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
  Duration _captureInterval = const Duration(milliseconds: 900);
  PoseCoachingResult? _lastResult;

  Duration get _fallbackInterval {
    if (kIsWeb) {
      return const Duration(milliseconds: 1100);
    }
    return Platform.isIOS
        ? const Duration(milliseconds: 1200)
        : const Duration(milliseconds: 700);
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
      _scheduleNextTick(const Duration(milliseconds: 120));
      unawaited(_tick());
    } else if (!shouldRun && _timer != null) {
      _timer?.cancel();
      _timer = null;
      _lastResult = null;
      ref.read(poseCoachingResultProvider.notifier).state = null;
      ref.read(poseCoachingServiceProvider).reset();
    }
  }

  void _scheduleNextTick(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      unawaited(_tick());
    });
  }

  bool _isCameraBusy() {
    return ref.read(isCapturingProvider) ||
        ref.read(isBurstingProvider) ||
        ref.read(timerCountdownProvider) != null ||
        ref.read(liveSceneAnalyzingProvider) ||
        ref.read(cameraSwitchingProvider) ||
        ref.read(isPreviewSamplingProvider) ||
        ref.read(isCameraUiInteractionPausedProvider);
  }

  Future<void> _tick() async {
    if (!mounted) {
      return;
    }

    if (!ref.read(poseCoachingShouldRunProvider)) {
      _syncLoop();
      return;
    }

    if (_tickInFlight || _isCameraBusy()) {
      _scheduleNextTick(const Duration(milliseconds: 250));
      return;
    }

    final service = ref.read(poseCoachingServiceProvider);
    final powerSave = ref.read(powerSaveEnabledProvider);
    _captureInterval = service.captureScheduler.nextInterval(
      lastResult: _lastResult,
      powerSave: powerSave,
    );

    final now = DateTime.now();
    if (!service.captureScheduler.shouldCapture(
      _lastCapture,
      _captureInterval,
      now: now,
    )) {
      final wait = _captureInterval - now.difference(_lastCapture);
      _scheduleNextTick(wait < const Duration(milliseconds: 80)
          ? const Duration(milliseconds: 80)
          : wait);
      return;
    }

    final controller = ref.read(cameraControllerProvider).value;
    if (controller == null || !controller.value.isInitialized) {
      _scheduleNextTick(const Duration(milliseconds: 400));
      return;
    }

    if (!service.shouldRunInference(now: now)) {
      _scheduleNextTick(const Duration(milliseconds: 200));
      return;
    }

    _tickInFlight = true;
    try {
      final bytes =
          await ref.read(cameraControllerProvider.notifier).capturePreviewFrame();
      if (!mounted || bytes == null || bytes.isEmpty) {
        _scheduleNextTick(_captureInterval);
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

      if (!mounted) {
        return;
      }

      if (result != null) {
        _lastResult = result;
        ref.read(poseCoachingResultProvider.notifier).state = result;
      }
    } finally {
      _tickInFlight = false;
      if (mounted) {
        _scheduleNextTick(_captureInterval);
      }
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

    return const SizedBox.shrink();
  }
}
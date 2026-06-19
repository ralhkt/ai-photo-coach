import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ar/providers/ar_providers.dart';
import '../../../ar/services/device_attitude_service.dart';
import '../../../pose/models/pose_coaching_result.dart';
import '../../../pose/providers/pose_coaching_provider.dart';
import '../../../pose/services/pose_preview_frame_source.dart';
import '../../../../core/settings/app_settings_provider.dart';
import '../../models/preview_capture_request.dart';
import '../../platform/native_preview_frame_service.dart';
import '../../providers/camera_capture_provider.dart';
import '../../providers/camera_interaction_provider.dart';
import '../../providers/camera_providers.dart';
import '../../providers/camera_settings_provider.dart';
import '../../providers/live_scene_analysis_provider.dart';

/// Polls preview frames + attitude for live pose coaching.
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
  DateTime _lastPublish = DateTime.fromMillisecondsSinceEpoch(0);
  Duration _captureInterval = const Duration(milliseconds: 2000);
  PoseCoachingResult? _lastResult;
  final PosePreviewFrameSource _androidFrameSource = PosePreviewFrameSource();
  bool _androidStreamAttempted = false;
  bool _iosSamplerAttached = false;

  bool get _useIosNativeSampler =>
      !kIsWeb && Platform.isIOS && NativePreviewFrameService.instance.isSupported;

  static const _iosNativeMinInterval = Duration(milliseconds: 5500);
  static const _guidedIdleBeforeMl = guidedMlIdleAfterInteraction;
  static const _guidedMinPublishGap = Duration(milliseconds: 4500);

  Duration get _fallbackInterval {
    if (_useIosNativeSampler) {
      return _iosNativeMinInterval;
    }
    if (kIsWeb) {
      return const Duration(milliseconds: 1500);
    }
    return Platform.isIOS
        ? const Duration(milliseconds: 1800)
        : const Duration(milliseconds: 1100);
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
    final controller = ref.read(cameraControllerProvider).value;
    if (_useIosNativeSampler) {
      unawaited(NativePreviewFrameService.instance.detach());
    } else {
      unawaited(_androidFrameSource.stop(controller));
    }
    super.dispose();
  }

  Future<void> _setSamplerActive(bool active) async {
    if (!_useIosNativeSampler) {
      return;
    }
    if (active && !_iosSamplerAttached) {
      await NativePreviewFrameService.instance.attach();
      _iosSamplerAttached = true;
      return;
    }
    if (!active && _iosSamplerAttached) {
      await NativePreviewFrameService.instance.detach();
      _iosSamplerAttached = false;
    }
  }

  void _syncLoop() {
    if (!mounted) {
      return;
    }

    final shouldRun = ref.read(poseCoachingShouldRunProvider);
    if (shouldRun && _timer == null) {
      _androidStreamAttempted = false;
      unawaited(_setSamplerActive(true));
      _scheduleNextTick(const Duration(milliseconds: 800));
    } else if (!shouldRun && _timer != null) {
      _timer?.cancel();
      _timer = null;
      _lastResult = null;
      _androidStreamAttempted = false;
      ref.read(poseCoachingResultProvider.notifier).state = null;
      ref.read(poseCoachingServiceProvider).reset();
      final controller = ref.read(cameraControllerProvider).value;
      unawaited(_setSamplerActive(false));
      unawaited(_androidFrameSource.stop(controller));
    }
  }

  void _deferForUserActivity() {
    _timer?.cancel();
    _timer = Timer(_guidedIdleBeforeMl, () {
      if (mounted) {
        unawaited(_tick());
      }
    });
  }

  void _scheduleNextTick(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      unawaited(_tick());
    });
  }

  bool _isGuidedUserInteracting() {
    if (!ref.read(poseCoachingShouldRunProvider)) {
      return false;
    }
    return isGuidedUserRecentlyActive(ref.read(guidedUserActivityProvider));
  }

  bool _isCameraBusy() {
    return ref.read(isCapturingProvider) ||
        ref.read(isBurstingProvider) ||
        ref.read(timerCountdownProvider) != null ||
        ref.read(liveSceneAnalyzingProvider) ||
        ref.read(cameraSwitchingProvider) ||
        ref.read(isPreviewSamplingProvider) ||
        ref.read(isCameraUiInteractionPausedProvider) ||
        _isGuidedUserInteracting();
  }

  Duration _busyRetryDelay() {
    if (_isGuidedUserInteracting()) {
      return _guidedIdleBeforeMl;
    }
    if (ref.read(isCameraUiInteractionPausedProvider) ||
        ref.read(isCapturingProvider) ||
        ref.read(cameraSwitchingProvider)) {
      return const Duration(milliseconds: 400);
    }
    return const Duration(milliseconds: 800);
  }

  Duration _effectiveCaptureInterval(Duration schedulerInterval) {
    if (!_useIosNativeSampler) {
      return schedulerInterval;
    }
    return schedulerInterval < _iosNativeMinInterval
        ? _iosNativeMinInterval
        : schedulerInterval;
  }

  bool _shouldPublishResult(PoseCoachingResult result, DateTime now) {
    if (_isGuidedUserInteracting()) {
      return false;
    }
    if (now.difference(_lastPublish) < _guidedMinPublishGap) {
      return false;
    }

    final previous = _lastResult;
    if (previous == null) {
      return true;
    }
    if ((result.poseScore - previous.poseScore).abs() >= 10) {
      return true;
    }
    if (result.combinedGuidance != previous.combinedGuidance) {
      return true;
    }
    if (result.isLevel != previous.isLevel) {
      return true;
    }
    return false;
  }

  void _publishIfNeeded(PoseCoachingResult? result, DateTime now) {
    if (result != null && _shouldPublishResult(result, now)) {
      _lastResult = result;
      _lastPublish = now;
      ref.read(poseCoachingResultProvider.notifier).state = result;
    }
  }

  void _scheduleAfterTick() {
    if (!mounted) {
      return;
    }
    if (_isGuidedUserInteracting()) {
      _deferForUserActivity();
      return;
    }
    _scheduleNextTick(_captureInterval);
  }

  Future<void> _ensureAndroidFrameSource(CameraController controller) async {
    if (_useIosNativeSampler || _androidStreamAttempted) {
      return;
    }
    _androidStreamAttempted = true;
    await _androidFrameSource.tryStartStream(controller);
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
      if (_isGuidedUserInteracting()) {
        _deferForUserActivity();
      } else {
        _scheduleNextTick(_busyRetryDelay());
      }
      return;
    }

    final service = ref.read(poseCoachingServiceProvider);
    final powerSave = ref.read(powerSaveEnabledProvider);
    _captureInterval = _effectiveCaptureInterval(
      service.captureScheduler.nextInterval(
        lastResult: _lastResult,
        powerSave: powerSave,
      ),
    );

    final now = DateTime.now();
    if (!service.captureScheduler.shouldCapture(
      _lastCapture,
      _captureInterval,
      now: now,
    )) {
      final wait = _captureInterval - now.difference(_lastCapture);
      _scheduleNextTick(wait < const Duration(milliseconds: 300)
          ? const Duration(milliseconds: 300)
          : wait);
      return;
    }

    final controller = ref.read(cameraControllerProvider).value;
    if (controller == null || !controller.value.isInitialized) {
      _scheduleNextTick(const Duration(milliseconds: 800));
      return;
    }

    if (!service.shouldRunInference(now: now) || _isGuidedUserInteracting()) {
      _deferForUserActivity();
      return;
    }

    _tickInFlight = true;
    try {
      final trendyTemplate = ref.read(activeTrendyTemplateProvider);
      PoseCoachingResult? result;

      if (_useIosNativeSampler) {
        final bytes = await NativePreviewFrameService.instance.latestJpeg();
        if (!mounted || _isGuidedUserInteracting()) {
          return;
        }
        if (bytes == null || bytes.isEmpty) {
          _scheduleNextTick(_iosNativeMinInterval);
          return;
        }
        _lastCapture = now;
        result = await service.evaluatePreviewFrame(
          bytes: bytes,
          rollAngle: _latestRoll,
          trendyTemplate: trendyTemplate,
          now: now,
        );
      } else {
        await _ensureAndroidFrameSource(controller);
        if (_androidFrameSource.usesImageStream) {
          final frame = _androidFrameSource.consumeLatest();
          if (frame == null) {
            _scheduleNextTick(const Duration(milliseconds: 500));
            return;
          }
          if (!mounted || _isGuidedUserInteracting()) {
            return;
          }
          _lastCapture = now;
          result = await service.evaluateCameraImage(
            image: frame,
            sensorOrientation: controller.description.sensorOrientation,
            rollAngle: _latestRoll,
            trendyTemplate: trendyTemplate,
            now: now,
          );
        } else {
          final bytes = await ref
              .read(cameraControllerProvider.notifier)
              .capturePreviewFrame(PreviewCaptureRequest.coaching);
          if (!mounted || bytes == null || bytes.isEmpty) {
            _scheduleNextTick(_captureInterval);
            return;
          }
          if (_isGuidedUserInteracting()) {
            return;
          }
          _lastCapture = now;
          result = await service.evaluatePreviewFrame(
            bytes: bytes,
            rollAngle: _latestRoll,
            trendyTemplate: trendyTemplate,
            now: now,
          );
        }
      }

      if (!mounted) {
        return;
      }

      _publishIfNeeded(result, DateTime.now());
    } finally {
      _tickInFlight = false;
      _scheduleAfterTick();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(poseCoachingShouldRunProvider, (_, __) {
      _syncLoop();
    });

    ref.listen<DateTime?>(guidedUserActivityProvider, (previous, next) {
      if (next != null && next != previous) {
        _deferForUserActivity();
      }
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
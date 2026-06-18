import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/camera_guidance.dart';
import '../../../models/camera_timer_duration.dart';
import '../../../models/captured_photo.dart';
import '../../../models/focus_indicator_state.dart';
import '../services/camera_service.dart';
import 'camera_capture_provider.dart';
import 'camera_mode_settings_provider.dart';
import 'camera_settings_provider.dart';

final camerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return CameraService.listCameras();
});

final cameraControllerProvider =
    AsyncNotifierProvider<CameraControllerNotifier, CameraController?>(
  CameraControllerNotifier.new,
);

class CameraControllerNotifier extends AsyncNotifier<CameraController?> {
  int _cameraIndex = 0;
  Timer? _burstTimer;
  Timer? _focusHideTimer;
  Timer? _countdownTimer;

  @override
  Future<CameraController?> build() async {
    ref.onDispose(() async {
      _burstTimer?.cancel();
      _focusHideTimer?.cancel();
      _countdownTimer?.cancel();
      await ref.read(cameraServiceProvider).dispose();
    });

    final cameras = await ref.watch(camerasProvider.future);
    if (cameras.isEmpty) {
      return null;
    }

    _cameraIndex = _defaultCameraIndex(cameras);
    final flashMode = ref.read(flashModeProvider);
    return ref.read(cameraServiceProvider).initialize(
          cameras[_cameraIndex],
          flashMode: flashMode,
        );
  }

  int _defaultCameraIndex(List<CameraDescription> cameras) {
    final backIndex = cameras.indexWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );
    return backIndex >= 0 ? backIndex : 0;
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final cameras = await ref.read(camerasProvider.future);
      if (cameras.isEmpty) {
        return null;
      }
      return ref.read(cameraServiceProvider).initialize(
            cameras[_cameraIndex],
            flashMode: ref.read(flashModeProvider),
          );
    });
  }

  Future<void> switchCamera() async {
    final cameras = await ref.read(camerasProvider.future);
    if (cameras.length < 2) {
      return;
    }

    await _unlockAeAf();
    _cameraIndex = (_cameraIndex + 1) % cameras.length;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(cameraServiceProvider).initialize(
            cameras[_cameraIndex],
            flashMode: ref.read(flashModeProvider),
          );
    });
  }

  Future<void> cycleFlashMode() async {
    final controller = state.value;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final isFront = controller.description.lensDirection ==
        CameraLensDirection.front;
    final current = ref.read(flashModeProvider);
    final next = _nextFlashMode(current, isFront: isFront);

    ref.read(flashModeProvider.notifier).state = next;
    try {
      await controller.setFlashMode(next);
    } catch (_) {
      ref.read(flashModeProvider.notifier).state = FlashMode.off;
      await controller.setFlashMode(FlashMode.off);
    }
  }

  FlashMode _nextFlashMode(FlashMode current, {required bool isFront}) {
    if (isFront) {
      return switch (current) {
        FlashMode.off => FlashMode.auto,
        FlashMode.auto => FlashMode.always,
        _ => FlashMode.off,
      };
    }

    return switch (current) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      FlashMode.always => FlashMode.torch,
      _ => FlashMode.off,
    };
  }

  Future<void> setFocusAt(Offset localPosition, Size previewSize) async {
    final controller = state.value;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (ref.read(aeAfLockProvider)) {
      return;
    }

    final normalized = Offset(
      (localPosition.dx / previewSize.width).clamp(0.0, 1.0),
      (localPosition.dy / previewSize.height).clamp(0.0, 1.0),
    );

    try {
      await controller.setFocusMode(FocusMode.auto);
      await controller.setExposureMode(ExposureMode.auto);
      await controller.setFocusPoint(normalized);
      await controller.setExposurePoint(normalized);
    } catch (_) {
      return;
    }

    ref.read(focusIndicatorProvider.notifier).state = FocusIndicatorState(
      position: localPosition,
      normalizedPoint: normalized,
      isLocked: false,
      visible: true,
    );

    _focusHideTimer?.cancel();
    _focusHideTimer = Timer(const Duration(seconds: 2), () {
      final current = ref.read(focusIndicatorProvider);
      if (current != null && !current.isLocked) {
        ref.read(focusIndicatorProvider.notifier).state =
            current.copyWith(visible: false);
      }
    });
  }

  Future<void> lockAeAfAt(Offset localPosition, Size previewSize) async {
    final controller = state.value;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final normalized = Offset(
      (localPosition.dx / previewSize.width).clamp(0.0, 1.0),
      (localPosition.dy / previewSize.height).clamp(0.0, 1.0),
    );

    try {
      await controller.setFocusPoint(normalized);
      await controller.setExposurePoint(normalized);
      await controller.setFocusMode(FocusMode.locked);
      await controller.setExposureMode(ExposureMode.locked);
    } catch (_) {
      return;
    }

    ref.read(aeAfLockProvider.notifier).state = true;
    ref.read(focusIndicatorProvider.notifier).state = FocusIndicatorState(
      position: localPosition,
      normalizedPoint: normalized,
      isLocked: true,
      visible: true,
    );
    _focusHideTimer?.cancel();
  }

  Future<void> toggleAeAfLock() async {
    if (ref.read(aeAfLockProvider)) {
      await _unlockAeAf();
      return;
    }

    final controller = state.value;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final indicator = ref.read(focusIndicatorProvider);
    final normalized = indicator?.normalizedPoint ?? const Offset(0.5, 0.5);
    try {
      await controller.setFocusPoint(normalized);
      await controller.setExposurePoint(normalized);
      await controller.setFocusMode(FocusMode.locked);
      await controller.setExposureMode(ExposureMode.locked);
    } catch (_) {
      return;
    }

    ref.read(aeAfLockProvider.notifier).state = true;
    ref.read(focusIndicatorProvider.notifier).state = FocusIndicatorState(
      position: indicator?.position ?? const Offset(180, 320),
      normalizedPoint: normalized,
      isLocked: true,
      visible: true,
    );
  }

  Future<void> _unlockAeAf() async {
    final controller = state.value;
    if (controller == null || !controller.value.isInitialized) {
      ref.read(aeAfLockProvider.notifier).state = false;
      return;
    }

    try {
      await controller.setFocusMode(FocusMode.auto);
      await controller.setExposureMode(ExposureMode.auto);
      await controller.setFocusPoint(null);
      await controller.setExposurePoint(null);
    } catch (_) {}

    ref.read(aeAfLockProvider.notifier).state = false;
    final indicator = ref.read(focusIndicatorProvider);
    if (indicator != null) {
      ref.read(focusIndicatorProvider.notifier).state =
          indicator.copyWith(isLocked: false, visible: false);
    }
  }

  Future<CapturedPhoto?> capturePhoto({bool silent = false}) async {
    final controller = state.value;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return null;
    }

    ref.read(isCapturingProvider.notifier).state = true;
    try {
      final flashMode = ref.read(flashModeProvider);
      await controller.setFlashMode(flashMode);
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      final capture = CapturedPhoto(
        path: file.path,
        bytes: bytes,
        capturedAt: DateTime.now(),
      );
      ref.read(lastCaptureProvider.notifier).state = capture;
      if (!silent) {
        ref.read(captureFlashProvider.notifier).state = true;
        Future<void>.delayed(const Duration(milliseconds: 120), () {
          ref.read(captureFlashProvider.notifier).state = false;
        });
      }
      return capture;
    } finally {
      ref.read(isCapturingProvider.notifier).state = false;
    }
  }

  Future<CapturedPhoto?> captureWithTimer() async {
    final timer = ref.read(timerDurationProvider);
    final seconds = timer.seconds;
    if (seconds == 0) {
      return capturePhoto();
    }

    final completer = Completer<CapturedPhoto?>();
    var remaining = seconds;
    ref.read(timerCountdownProvider.notifier).state = remaining;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timerTick) {
      remaining--;
      if (remaining > 0) {
        ref.read(timerCountdownProvider.notifier).state = remaining;
        return;
      }

      timerTick.cancel();
      ref.read(timerCountdownProvider.notifier).state = null;
      capturePhoto().then(completer.complete);
    });

    return completer.future;
  }

  void startBurst() {
    if (ref.read(isBurstingProvider)) {
      return;
    }

    ref.read(isBurstingProvider.notifier).state = true;
    ref.read(burstPhotosProvider.notifier).state = const [];

    _burstTimer?.cancel();
    _burstTimer = Timer.periodic(const Duration(milliseconds: 220), (_) async {
      final photo = await capturePhoto(silent: true);
      if (photo == null) {
        return;
      }
      final current = [...ref.read(burstPhotosProvider), photo];
      ref.read(burstPhotosProvider.notifier).state = current;
    });
  }

  Future<List<CapturedPhoto>> stopBurst() async {
    _burstTimer?.cancel();
    ref.read(isBurstingProvider.notifier).state = false;
    final photos = ref.read(burstPhotosProvider);
    if (photos.isNotEmpty) {
      ref.read(lastCaptureProvider.notifier).state = photos.last;
    }
    return photos;
  }

  Future<void> applyGuidanceSettings(CameraGuidance guidance) async {
    ref.read(cameraModeSettingsProvider.notifier).seedGuidedFromAnalysis(
          suggestedZoom: guidance.suggestedZoom,
          exposureEv: guidance.exposureEv,
        );

    await setZoom(guidance.suggestedZoom);

    final controller = state.value;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      final minEv = await controller.getMinExposureOffset();
      final maxEv = await controller.getMaxExposureOffset();
      final ev = guidance.exposureEv.clamp(minEv, maxEv);
      await controller.setExposureOffset(ev);
      ref.read(manualExposureOffsetProvider.notifier).state = ev;
      ref.read(cameraModeSettingsProvider.notifier).persistActiveFromProviders();
    } catch (_) {}
  }

  Future<void> setZoom(double zoom) async {
    final controller = state.value;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final maxZoom = await controller.getMaxZoomLevel();
    final minZoom = await controller.getMinZoomLevel();
    final clamped = zoom.clamp(minZoom, maxZoom);
    await controller.setZoomLevel(clamped);
    ref.read(focalPresetProvider.notifier).state = clamped;
    ref.read(cameraModeSettingsProvider.notifier).persistActiveFromProviders();
  }

  Future<void> setManualExposure(double ev) async {
    final controller = state.value;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      final minEv = await controller.getMinExposureOffset();
      final maxEv = await controller.getMaxExposureOffset();
      final clamped = ev.clamp(minEv, maxEv);
      await controller.setExposureOffset(clamped);
      ref.read(manualExposureOffsetProvider.notifier).state = clamped;
      ref.read(cameraModeSettingsProvider.notifier).persistActiveFromProviders();
    } catch (_) {}
  }
}

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});
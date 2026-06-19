import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../models/camera_aspect_ratio.dart';
import '../../../../models/camera_timer_duration.dart';
import '../../providers/camera_capture_provider.dart';
import '../../providers/camera_interaction_provider.dart';
import '../../providers/camera_providers.dart';
import '../../providers/camera_settings_provider.dart';
import '../../providers/camera_shell_provider.dart';
import '../camera_shell_mode.dart';
import '../ios_camera_mode_switcher.dart';
import 'ios_camera_bottom_bar.dart';
import 'ios_exposure_slider.dart';

/// Bottom chrome with interaction pause markers on every control tap.
class IosCameraBottomBarHost extends ConsumerWidget {
  const IosCameraBottomBarHost({
    super.key,
    required this.onHdrTap,
    required this.onGalleryTap,
    required this.onShutterTap,
    required this.onBurstEnd,
  });

  final void Function(bool supported, bool enabled) onHdrTap;
  final void Function(bool hasLastCapture) onGalleryTap;
  final VoidCallback onShutterTap;
  final VoidCallback onBurstEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final shellMode = ref.watch(cameraShellModeProvider);
    final modeLabels = [
      l10n.cameraModeVideo,
      l10n.cameraModePhoto,
      l10n.cameraModeGuided,
    ];
    final proModeEnabled = ref.watch(proModeEnabledProvider);

    return IosCameraBottomBar(
      compactMode: shellMode == CameraShellMode.guided,
      showZoomPresets: true,
      modeLabel: _modeLabel(l10n, shellMode),
      modeLabels: modeLabels,
      selectedModeIndex: shellMode.carouselIndex,
      onModeSelected: (index) {
        markCameraUiInteraction(ref);
        unawaited(
          switchIosCameraShellMode(
            context: context,
            ref: ref,
            current: shellMode,
            target: CameraShellMode.fromCarouselIndex(index),
          ),
        );
      },
      thumbnailBytes: ref.watch(lastCaptureThumbnailProvider),
      isCapturing: ref.watch(isCapturingProvider),
      isBursting: ref.watch(isBurstingProvider),
      burstCount: ref.watch(burstPhotosProvider.select((photos) => photos.length)),
      hdrEnabled: ref.watch(hdrEnabledProvider),
      hdrSupported: ref.watch(hdrSupportedProvider),
      hdrLabel: l10n.hdrLabel,
      timerDuration: ref.watch(timerDurationProvider),
      aeAfLocked: ref.watch(aeAfLockProvider),
      optionsExpanded: ref.watch(showCameraOptionsProvider),
      canFlip: ref.watch(
        camerasProvider.select((cameras) => (cameras.value ?? []).length > 1),
      ),
      shutterEnabled: ref.watch(timerCountdownProvider) == null,
      onHdrTap: () {
        markCameraUiInteraction(ref);
        onHdrTap(
          ref.read(hdrSupportedProvider),
          ref.read(hdrEnabledProvider),
        );
      },
      onTimerTap: () {
        markCameraUiInteraction(ref);
        ref.read(timerDurationProvider.notifier).state =
            ref.read(timerDurationProvider).next;
      },
      onExposureLockTap: () {
        markCameraUiInteraction(ref);
        unawaited(
          ref.read(cameraControllerProvider.notifier).toggleAeAfLock(),
        );
      },
      onToggleOptions: () {
        markCameraUiInteraction(ref);
        ref.read(showCameraOptionsProvider.notifier).state =
            !ref.read(showCameraOptionsProvider);
      },
      onGalleryTap: () {
        markCameraUiInteraction(ref);
        onGalleryTap(ref.read(lastCaptureThumbnailProvider) != null);
      },
      onGalleryLongPress: () {
        markCameraUiInteraction(ref);
        onGalleryTap(false);
      },
      onShutterTap: onShutterTap,
      onBurstStart: () {
        markCameraUiInteraction(ref);
        unawaited(ref.read(cameraControllerProvider.notifier).startBurst());
      },
      onBurstEnd: onBurstEnd,
      onFlipCamera: () {
        markCameraUiInteraction(ref);
        unawaited(ref.read(cameraControllerProvider.notifier).switchCamera());
      },
      proModeEnabled: proModeEnabled,
      onProModeTap: () {
        markCameraUiInteraction(ref);
        ref.read(proModeEnabledProvider.notifier).state =
            !ref.read(proModeEnabledProvider);
      },
      aspectRatio: ref.watch(cameraAspectRatioProvider),
      onAspectRatioTap: () {
        markCameraUiInteraction(ref);
        ref.read(cameraAspectRatioProvider.notifier).state =
            ref.read(cameraAspectRatioProvider).next;
      },
      showHistogram: ref.watch(showHistogramProvider),
      onHistogramTap: () {
        markCameraUiInteraction(ref);
        ref.read(showHistogramProvider.notifier).state =
            !ref.read(showHistogramProvider);
      },
      frontMirrorEnabled: ref.watch(frontMirrorEnabledProvider),
      onMirrorTap: () {
        markCameraUiInteraction(ref);
        ref.read(frontMirrorEnabledProvider.notifier).state =
            !ref.read(frontMirrorEnabledProvider);
      },
      proModeExposure: proModeEnabled ? const _ProModeExposureSlider() : null,
      focalPreset: ref.watch(focalPresetProvider),
      onFocalPresetTap: (preset) {
        markCameraUiInteraction(ref);
        unawaited(ref.read(cameraControllerProvider.notifier).setZoom(preset));
      },
    );
  }

  String _modeLabel(AppLocalizations l10n, CameraShellMode mode) {
    return switch (mode) {
      CameraShellMode.video => l10n.cameraModeVideo,
      CameraShellMode.photo => l10n.cameraModePhoto,
      CameraShellMode.guided => l10n.cameraModeGuided,
    };
  }
}

/// Isolated exposure slider — avoids rebuilding the full bottom bar while dragging.
class _ProModeExposureSlider extends ConsumerWidget {
  const _ProModeExposureSlider();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IosExposureSlider(
      value: ref.watch(manualExposureOffsetProvider),
      onChanged: (value) {
        markCameraUiInteraction(ref);
        ref.read(cameraControllerProvider.notifier).setManualExposure(value);
      },
    );
  }
}
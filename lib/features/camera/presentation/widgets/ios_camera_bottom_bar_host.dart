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
import 'ios_camera_ui_kit.dart';
import 'ios_exposure_slider.dart';
import 'ios_gallery_button.dart';
import 'ios_shutter_button.dart';

/// Bottom chrome — guided mode watches fewer providers to avoid chrome jank.
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
    final shellMode = ref.watch(cameraShellModeProvider);
    if (shellMode == CameraShellMode.guided) {
      return _GuidedBottomBar(
        onGalleryTap: onGalleryTap,
        onShutterTap: onShutterTap,
        onBurstEnd: onBurstEnd,
      );
    }
    return _FullBottomBar(
      shellMode: shellMode,
      onHdrTap: onHdrTap,
      onGalleryTap: onGalleryTap,
      onShutterTap: onShutterTap,
      onBurstEnd: onBurstEnd,
    );
  }
}

class _GuidedBottomBar extends ConsumerWidget {
  const _GuidedBottomBar({
    required this.onGalleryTap,
    required this.onShutterTap,
    required this.onBurstEnd,
  });

  final void Function(bool hasLastCapture) onGalleryTap;
  final VoidCallback onShutterTap;
  final VoidCallback onBurstEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final modeLabels = [
      l10n.cameraModeVideo,
      l10n.cameraModePhoto,
      l10n.cameraModeGuided,
    ];

    return IosCameraBottomBar(
      compactMode: true,
      showZoomPresets: false,
      modeLabel: l10n.cameraModeGuided,
      modeLabels: modeLabels,
      selectedModeIndex: CameraShellMode.guided.carouselIndex,
      onModeSelected: (index) {
        markHeavyCameraInteraction(ref);
        unawaited(
          switchIosCameraShellMode(
            context: context,
            ref: ref,
            current: CameraShellMode.guided,
            target: CameraShellMode.fromCarouselIndex(index),
          ),
        );
      },
      thumbnailBytes: null,
      isCapturing: false,
      isBursting: false,
      burstCount: 0,
      hdrEnabled: false,
      hdrSupported: false,
      hdrLabel: l10n.hdrLabel,
      timerDuration: CameraTimerDuration.off,
      aeAfLocked: false,
      optionsExpanded: false,
      canFlip: true,
      isFlipping: false,
      shutterEnabled: true,
      onHdrTap: () {},
      onTimerTap: () {},
      onExposureLockTap: () {},
      onToggleOptions: () {},
      onGalleryTap: () {},
      onGalleryLongPress: () {},
      onShutterTap: onShutterTap,
      onBurstStart: () {},
      onBurstEnd: onBurstEnd,
      onFlipCamera: () {},
      proModeEnabled: false,
      aspectRatio: CameraAspectRatio.ratio4x3,
      showHistogram: false,
      frontMirrorEnabled: true,
      focalPreset: 1.0,
      controlRow: _GuidedControlRow(
        onGalleryTap: onGalleryTap,
        onShutterTap: onShutterTap,
        onBurstEnd: onBurstEnd,
      ),
      burstLabel: const _GuidedBurstLabel(),
    );
  }
}

class _GuidedBurstLabel extends ConsumerWidget {
  const _GuidedBurstLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBursting = ref.watch(isBurstingProvider);
    if (!isBursting) {
      return const SizedBox.shrink();
    }
    final burstCount = ref.watch(
      burstPhotosProvider.select((photos) => photos.length),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '×$burstCount',
        style: const TextStyle(
          color: IosCameraUiKit.accentYellow,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Isolated shutter row — thumbnail/capture state won't rebuild the mode carousel.
class _GuidedControlRow extends ConsumerWidget {
  const _GuidedControlRow({
    required this.onGalleryTap,
    required this.onShutterTap,
    required this.onBurstEnd,
  });

  final void Function(bool hasLastCapture) onGalleryTap;
  final VoidCallback onShutterTap;
  final VoidCallback onBurstEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: IosCameraUiKit.bottomControlRowHeight,
      child: Row(
        children: [
          _GuidedGalleryButton(onGalleryTap: onGalleryTap),
          Expanded(
            child: Center(
              child: _GuidedShutterButton(
                onShutterTap: onShutterTap,
                onBurstEnd: onBurstEnd,
              ),
            ),
          ),
          const _GuidedFlipButton(),
        ],
      ),
    );
  }
}

class _GuidedGalleryButton extends ConsumerWidget {
  const _GuidedGalleryButton({required this.onGalleryTap});

  final void Function(bool hasLastCapture) onGalleryTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnail = ref.watch(lastCaptureThumbnailProvider);
    return IosGalleryButton(
      thumbnailBytes: thumbnail,
      onTap: () {
        markGuidedUserActivity(ref);
        onGalleryTap(thumbnail != null);
      },
      onLongPress: () {
        markGuidedUserActivity(ref);
        onGalleryTap(false);
      },
    );
  }
}

class _GuidedShutterButton extends ConsumerWidget {
  const _GuidedShutterButton({
    required this.onShutterTap,
    required this.onBurstEnd,
  });

  final VoidCallback onShutterTap;
  final VoidCallback onBurstEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCapturing = ref.watch(isCapturingProvider);
    final isBursting = ref.watch(isBurstingProvider);
    final shutterEnabled = ref.watch(timerCountdownProvider) == null;

    return IosShutterButton(
      onPressed: shutterEnabled ? onShutterTap : null,
      onBurstStart: shutterEnabled
          ? () {
              markHeavyCameraInteraction(ref);
              unawaited(ref.read(cameraControllerProvider.notifier).startBurst());
            }
          : null,
      onBurstEnd: onBurstEnd,
      isCapturing: isCapturing,
      isBursting: isBursting,
      enabled: shutterEnabled,
    );
  }
}

class _GuidedFlipButton extends ConsumerWidget {
  const _GuidedFlipButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canFlip = ref.watch(
          camerasProvider.select((cameras) => (cameras.value ?? []).length > 1),
        ) &&
        !ref.watch(cameraSwitchingProvider);
    final isFlipping = ref.watch(cameraSwitchingProvider);

    return IosFlipCameraButton(
      onTap: canFlip
          ? () {
              markHeavyCameraInteraction(ref);
              unawaited(ref.read(cameraControllerProvider.notifier).switchCamera());
            }
          : null,
      enabled: canFlip,
      isFlipping: isFlipping,
    );
  }
}

class _FullBottomBar extends ConsumerWidget {
  const _FullBottomBar({
    required this.shellMode,
    required this.onHdrTap,
    required this.onGalleryTap,
    required this.onShutterTap,
    required this.onBurstEnd,
  });

  final CameraShellMode shellMode;
  final void Function(bool supported, bool enabled) onHdrTap;
  final void Function(bool hasLastCapture) onGalleryTap;
  final VoidCallback onShutterTap;
  final VoidCallback onBurstEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final modeLabels = [
      l10n.cameraModeVideo,
      l10n.cameraModePhoto,
      l10n.cameraModeGuided,
    ];

    return IosCameraBottomBar(
      compactMode: false,
      showZoomPresets: true,
      modeLabel: _modeLabel(l10n, shellMode),
      modeLabels: modeLabels,
      selectedModeIndex: shellMode.carouselIndex,
      onModeSelected: (index) {
        markHeavyCameraInteraction(ref);
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
      burstCount: ref.watch(
        burstPhotosProvider.select((photos) => photos.length),
      ),
      hdrEnabled: ref.watch(hdrEnabledProvider),
      hdrSupported: ref.watch(hdrSupportedProvider),
      hdrLabel: l10n.hdrLabel,
      timerDuration: ref.watch(timerDurationProvider),
      aeAfLocked: ref.watch(aeAfLockProvider),
      optionsExpanded: ref.watch(showCameraOptionsProvider),
      canFlip: ref.watch(
        camerasProvider.select((cameras) => (cameras.value ?? []).length > 1),
      ) &&
          !ref.watch(cameraSwitchingProvider),
      isFlipping: ref.watch(cameraSwitchingProvider),
      shutterEnabled: ref.watch(timerCountdownProvider) == null,
      onHdrTap: () {
        markCameraChromeTap(ref);
        onHdrTap(
          ref.read(hdrSupportedProvider),
          ref.read(hdrEnabledProvider),
        );
      },
      onTimerTap: () {
        markCameraChromeTap(ref);
        ref.read(timerDurationProvider.notifier).state =
            ref.read(timerDurationProvider).next;
      },
      onExposureLockTap: () {
        markCameraChromeTap(ref);
        unawaited(
          ref.read(cameraControllerProvider.notifier).toggleAeAfLock(),
        );
      },
      onToggleOptions: () {
        markCameraChromeTap(ref);
        ref.read(showCameraOptionsProvider.notifier).state =
            !ref.read(showCameraOptionsProvider);
      },
      onGalleryTap: () {
        markCameraChromeTap(ref);
        onGalleryTap(ref.read(lastCaptureThumbnailProvider) != null);
      },
      onGalleryLongPress: () {
        markCameraChromeTap(ref);
        onGalleryTap(false);
      },
      onShutterTap: onShutterTap,
      onBurstStart: () {
        markHeavyCameraInteraction(ref);
        unawaited(ref.read(cameraControllerProvider.notifier).startBurst());
      },
      onBurstEnd: onBurstEnd,
      onFlipCamera: () {
        markHeavyCameraInteraction(ref);
        unawaited(ref.read(cameraControllerProvider.notifier).switchCamera());
      },
      proModeEnabled: ref.watch(proModeEnabledProvider),
      onProModeTap: () {
        markCameraChromeTap(ref);
        ref.read(proModeEnabledProvider.notifier).state =
            !ref.read(proModeEnabledProvider);
      },
      aspectRatio: ref.watch(cameraAspectRatioProvider),
      onAspectRatioTap: () {
        markCameraChromeTap(ref);
        ref.read(cameraAspectRatioProvider.notifier).state =
            ref.read(cameraAspectRatioProvider).next;
      },
      showHistogram: ref.watch(showHistogramProvider),
      onHistogramTap: () {
        markCameraChromeTap(ref);
        ref.read(showHistogramProvider.notifier).state =
            !ref.read(showHistogramProvider);
      },
      frontMirrorEnabled: ref.watch(frontMirrorEnabledProvider),
      onMirrorTap: () {
        markCameraChromeTap(ref);
        ref.read(frontMirrorEnabledProvider.notifier).state =
            !ref.read(frontMirrorEnabledProvider);
      },
      proModeExposure: ref.watch(proModeEnabledProvider)
          ? const _ProModeExposureSlider()
          : null,
      focalPreset: ref.watch(focalPresetProvider),
      onFocalPresetTap: (preset) {
        markCameraChromeTap(ref);
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
      onChangeStart: () => markCameraChromeTap(ref),
      onChanged: (value) {
        ref.read(cameraControllerProvider.notifier).setManualExposure(value);
      },
    );
  }
}
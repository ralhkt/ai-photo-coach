import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../models/camera_aspect_ratio.dart';
import '../../../../models/camera_timer_duration.dart';
import '../../../../models/captured_photo.dart';
import '../../../ar/presentation/ar_horizon_overlay.dart';
import '../../../ar/presentation/ar_status_chip.dart';
import '../../../ar/providers/ar_providers.dart';
import '../../../ar/services/ar_platform_service.dart';
import '../../../scene_stabilization/providers/scene_stability_provider.dart';
import '../../providers/camera_capture_provider.dart';
import '../../providers/camera_providers.dart';
import '../../providers/camera_settings_provider.dart';
import '../burst_review_screen.dart';
import '../photo_review_screen.dart';
import 'ios_aspect_ratio_overlay.dart';
import 'ios_camera_bottom_bar.dart';
import 'ios_camera_preview.dart';
import 'ios_camera_top_bar.dart';
import 'ios_countdown_overlay.dart';
import 'ios_histogram_overlay.dart';

class IosCameraScaffold extends ConsumerStatefulWidget {
  const IosCameraScaffold({
    super.key,
    required this.controller,
    required this.overlay,
    this.guidanceChip,
    this.modeLabel,
    this.centerTopLabel,
    this.showGridButton = true,
    this.showFrameButton = false,
    this.gridEnabled = false,
    this.frameEnabled = false,
    this.onGridTap,
    this.onFrameTap,
    this.enablePhase2 = true,
  });

  final CameraController controller;
  final Widget overlay;
  final Widget? guidanceChip;
  final bool enablePhase2;
  final String? modeLabel;
  final String? centerTopLabel;
  final bool showGridButton;
  final bool showFrameButton;
  final bool gridEnabled;
  final bool frameEnabled;
  final VoidCallback? onGridTap;
  final VoidCallback? onFrameTap;

  @override
  ConsumerState<IosCameraScaffold> createState() => _IosCameraScaffoldState();
}

class _IosCameraScaffoldState extends ConsumerState<IosCameraScaffold> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lastCapture = ref.watch(lastCaptureProvider);
    final isCapturing = ref.watch(isCapturingProvider);
    final showFlash = ref.watch(captureFlashProvider);
    final flashMode = ref.watch(flashModeProvider);
    final cameras = ref.watch(camerasProvider).value ?? [];
    final hdrEnabled = ref.watch(hdrEnabledProvider);
    final timerDuration = ref.watch(timerDurationProvider);
    final countdown = ref.watch(timerCountdownProvider);
    final isBursting = ref.watch(isBurstingProvider);
    final burstPhotos = ref.watch(burstPhotosProvider);
    final aeAfLocked = ref.watch(aeAfLockProvider);
    final optionsExpanded = ref.watch(showCameraOptionsProvider);
    final arStatus = ref.watch(arSessionProvider).value ?? ArPlatformStatus.initial;
    final sceneStatus = ref.watch(sceneStabilityProvider);
    final arOverlayVisible = ref.watch(arOverlayVisibleProvider);
    final proMode = ref.watch(proModeEnabledProvider);
    final aspectRatio = ref.watch(cameraAspectRatioProvider);
    final manualEv = ref.watch(manualExposureOffsetProvider);
    final focalPreset = ref.watch(focalPresetProvider);
    final showHistogram = ref.watch(showHistogramProvider);
    final frontMirror = ref.watch(frontMirrorEnabledProvider);

    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              IosCameraPreview(controller: widget.controller),
              IosAspectRatioOverlay(aspectRatio: aspectRatio),
              widget.overlay,
              if (widget.enablePhase2)
                ArHorizonOverlay(visible: arOverlayVisible),
              if (showFlash)
                AnimatedOpacity(
                  opacity: showFlash ? 1 : 0,
                  duration: const Duration(milliseconds: 80),
                  child: const ColoredBox(color: Colors.white),
                ),
              if (countdown != null) IosCountdownOverlay(seconds: countdown),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IosCameraTopBar(
                  flashMode: flashMode,
                  hdrEnabled: hdrEnabled,
                  aeAfLocked: aeAfLocked,
                  aeAfLockLabel: l10n.aeAfLocked,
                  onClose: () => Navigator.of(context).maybePop(),
                  onFlashTap: () =>
                      ref.read(cameraControllerProvider.notifier).cycleFlashMode(),
                  onGridTap: widget.onGridTap,
                  onFrameTap: widget.onFrameTap,
                  gridEnabled: widget.gridEnabled,
                  frameEnabled: widget.frameEnabled,
                  showGridButton: widget.showGridButton,
                  showFrameButton: widget.showFrameButton,
                  centerLabel: widget.centerTopLabel,
                ),
              ),
              if (widget.enablePhase2)
                Positioned(
                  top: 96,
                  left: 16,
                  child: ArStatusChip(
                    arStatus: arStatus,
                    sceneStatus: sceneStatus,
                  ),
                ),
              if (showHistogram)
                IosHistogramOverlay(brightness: 0.45 + manualEv * 0.1),
            ],
          ),
        ),
        if (widget.guidanceChip != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: widget.guidanceChip!,
          ),
        IosCameraBottomBar(
          modeLabel: widget.modeLabel ?? l10n.cameraModePhoto,
          thumbnailBytes: lastCapture?.bytes,
          isCapturing: isCapturing,
          isBursting: isBursting,
          burstCount: burstPhotos.length,
          hdrEnabled: hdrEnabled,
          timerDuration: timerDuration,
          aeAfLocked: aeAfLocked,
          optionsExpanded: optionsExpanded,
          canFlip: cameras.length > 1,
          shutterEnabled: countdown == null,
          onHdrTap: () {
            ref.read(hdrEnabledProvider.notifier).state = !hdrEnabled;
          },
          onTimerTap: () {
            ref.read(timerDurationProvider.notifier).state = timerDuration.next;
          },
          onExposureLockTap: () {
            ref.read(cameraControllerProvider.notifier).toggleAeAfLock();
          },
          onToggleOptions: () {
            ref.read(showCameraOptionsProvider.notifier).state =
                !optionsExpanded;
          },
          onGalleryTap: () => _openGallery(context, lastCapture != null),
          onGalleryLongPress: () => _openGallery(context, false),
          onShutterTap: () => _capture(context),
          onBurstStart: () {
            ref.read(cameraControllerProvider.notifier).startBurst();
          },
          onBurstEnd: () => _finishBurst(context),
          onFlipCamera: () =>
              ref.read(cameraControllerProvider.notifier).switchCamera(),
          proModeEnabled: proMode,
          onProModeTap: () {
            ref.read(proModeEnabledProvider.notifier).state = !proMode;
          },
          aspectRatio: aspectRatio,
          onAspectRatioTap: () {
            ref.read(cameraAspectRatioProvider.notifier).state =
                aspectRatio.next;
          },
          showHistogram: showHistogram,
          onHistogramTap: () {
            ref.read(showHistogramProvider.notifier).state = !showHistogram;
          },
          frontMirrorEnabled: frontMirror,
          onMirrorTap: () {
            ref.read(frontMirrorEnabledProvider.notifier).state = !frontMirror;
          },
          manualExposure: manualEv,
          onManualExposureChanged: (value) {
            ref.read(cameraControllerProvider.notifier).setManualExposure(value);
          },
          focalPreset: focalPreset,
          onFocalPresetTap: (preset) {
            ref.read(cameraControllerProvider.notifier).setZoom(preset);
          },
        ),
      ],
    );
  }

  Future<void> _capture(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final photo = await ref
          .read(cameraControllerProvider.notifier)
          .captureWithTimer();
      if (!context.mounted || photo == null) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PhotoReviewScreen(photo: photo),
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.captureFailed)),
        );
      }
    }
  }

  Future<void> _finishBurst(BuildContext context) async {
    final photos =
        await ref.read(cameraControllerProvider.notifier).stopBurst();
    if (!context.mounted || photos.isEmpty) {
      return;
    }

    if (photos.length == 1) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PhotoReviewScreen(photo: photos.first),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BurstReviewScreen(photos: photos),
      ),
    );
  }

  Future<void> _openGallery(BuildContext context, bool preferLastCapture) async {
    final lastCapture = ref.read(lastCaptureProvider);
    if (preferLastCapture && lastCapture != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PhotoReviewScreen(photo: lastCapture),
        ),
      );
      return;
    }

    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (!context.mounted || file == null) {
      return;
    }

    final bytes = await file.readAsBytes();
    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PhotoReviewScreen(
          photo: CapturedPhoto(
            path: file.path,
            bytes: bytes,
            capturedAt: DateTime.now(),
          ),
          isFromGallery: true,
        ),
      ),
    );
  }
}
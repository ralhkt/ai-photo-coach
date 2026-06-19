import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/services/voice_guidance_service.dart';
import '../../../../core/settings/app_settings_provider.dart';
import '../../../../core/utils/guidance_text.dart';
import '../../../../models/camera_aspect_ratio.dart';
import '../../../../models/camera_timer_duration.dart';
import '../../../../models/photo_frame_template.dart';
import '../../../../models/captured_photo.dart';
import '../../../../models/shoot_session.dart';
import '../../../session/presentation/session_flow.dart';
import '../../../session/providers/shoot_session_provider.dart';
import '../../../ar/presentation/ar_horizon_overlay.dart';
import '../../../ar/presentation/ar_status_chip.dart';
import '../../../ar/providers/ar_providers.dart';
import '../../../ar/services/ar_platform_service.dart';
import '../../../scene_stabilization/providers/scene_stability_provider.dart';
import '../../providers/camera_capture_provider.dart';
import '../../providers/camera_mode_settings_provider.dart';
import '../../providers/camera_providers.dart';
import '../../providers/camera_settings_provider.dart';
import '../../providers/live_scene_analysis_provider.dart';
import 'angle_guidance_overlay.dart';
import 'live_scene_advice_panel.dart';
import 'live_scene_analyzing_overlay.dart';
import 'live_scene_auto_analyzer.dart';
import 'live_scene_coach_banner.dart';
import 'live_scene_guidance_frame_overlay.dart';
import '../burst_review_screen.dart';
import '../photo_review_screen.dart';
import 'ios_aspect_ratio_overlay.dart';
import 'ios_camera_bottom_bar.dart';
import 'ios_camera_preview.dart';
import 'letterboxed_camera_viewport.dart';
import 'ios_camera_top_bar.dart';
import 'ios_countdown_overlay.dart';
import 'ios_histogram_overlay.dart';

class IosCameraScaffold extends ConsumerStatefulWidget {
  const IosCameraScaffold({
    super.key,
    required this.controller,
    required this.overlay,
    this.croppedOverlay,
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
    this.shootSessionMode,
  });

  final CameraController controller;
  final Widget overlay;
  final Widget? croppedOverlay;
  final Widget? guidanceChip;
  final bool enablePhase2;
  final ShootSessionMode? shootSessionMode;
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
  bool get _isFreeShootMode =>
      widget.shootSessionMode == ShootSessionMode.free;

  double? _resolveCropAspectRatio(WidgetRef ref, Size viewport) {
    return ref.watch(cameraAspectRatioProvider).displayCropRatio(viewport);
  }

  String _aspectRatioLabel(AppLocalizations l10n, CameraAspectRatio ratio) {
    return switch (ratio) {
      CameraAspectRatio.ratio4x3 => l10n.aspectRatio4x3,
      CameraAspectRatio.ratio16x9 => l10n.aspectRatio16x9,
      CameraAspectRatio.ratio1x1 => l10n.aspectRatio1x1,
      CameraAspectRatio.full => l10n.aspectRatioFull,
    };
  }

  Future<void> _analyzeLiveScene(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final previous = ref.read(liveSceneAnalysisProvider).value;
    await ref.read(liveSceneAnalysisProvider.notifier).analyzeCurrentScene();

    if (!context.mounted) {
      return;
    }

    final analysis = ref.read(liveSceneAnalysisProvider).value;
    final error = ref.read(liveSceneAnalysisErrorProvider);
    if (analysis != null && analysis != previous && error == null) {
      await ref.read(appSettingsProvider.notifier).dismissLiveSceneCoach();
      if (!context.mounted) {
        return;
      }
      ref.read(voiceGuidanceServiceProvider).speak(
            context,
            guidanceHintLabel(l10n, analysis.guidance.framingHintKey),
          );
      _showLiveSceneSuccess(context, l10n);
    }
  }

  void _showLiveSceneSuccess(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFFFFD60A),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.liveSceneAnalysisReady)),
          ],
        ),
      ),
    );
  }

  String _liveSceneErrorMessage(
    AppLocalizations l10n,
    LiveSceneAnalysisFailure failure,
  ) {
    return switch (failure) {
      LiveSceneAnalysisFailure.cameraBusy => l10n.liveSceneCameraBusy,
      LiveSceneAnalysisFailure.cameraNotReady => l10n.liveSceneCameraNotReady,
      LiveSceneAnalysisFailure.captureFailed ||
      LiveSceneAnalysisFailure.analysisFailed =>
        l10n.liveSceneAnalyzeFailed,
    };
  }

  String _liveSceneErrorHint(
    AppLocalizations l10n,
    LiveSceneAnalysisFailure failure,
  ) {
    return switch (failure) {
      LiveSceneAnalysisFailure.cameraBusy => l10n.liveSceneCameraBusyHint,
      LiveSceneAnalysisFailure.cameraNotReady => l10n.liveSceneAnalyzeFailedHint,
      LiveSceneAnalysisFailure.captureFailed ||
      LiveSceneAnalysisFailure.analysisFailed =>
        l10n.liveSceneAnalyzeFailedHint,
    };
  }

  void _showLiveSceneError(
    BuildContext context,
    AppLocalizations l10n,
    LiveSceneAnalysisFailure failure,
  ) {
    final canRetry = failure != LiveSceneAnalysisFailure.cameraBusy;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _liveSceneErrorMessage(l10n, failure),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _liveSceneErrorHint(l10n, failure),
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        action: canRetry
            ? SnackBarAction(
                label: l10n.liveSceneRetryAction,
                onPressed: () => _analyzeLiveScene(context),
              )
            : null,
      ),
    );
    ref.read(liveSceneAnalysisErrorProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final liveAnalysis = ref.watch(liveSceneAnalysisProvider);
    final isLiveAnalyzing = ref.watch(liveSceneAnalyzingProvider);
    final isManualRun = ref.watch(liveSceneManualRunProvider);
    final coachDismissed = ref.watch(liveSceneCoachDismissedProvider);
    final hasAdvice = liveAnalysis.value != null;

    ref.listen<LiveSceneAnalysisFailure?>(
      liveSceneAnalysisErrorProvider,
      (previous, next) {
        if (next == null || next == previous || !context.mounted) {
          return;
        }
        _showLiveSceneError(context, l10n, next);
      },
    );

    ref.listen<bool>(liveSceneAnalyzingProvider, (previous, next) {
      if (previous != true || next != false || !context.mounted) {
        return;
      }
      final analysis = ref.read(liveSceneAnalysisProvider).value;
      final error = ref.read(liveSceneAnalysisErrorProvider);
      final manual = ref.read(liveSceneManualRunProvider);
      if (analysis == null || error != null) {
        return;
      }
      ref.read(appSettingsProvider.notifier).dismissLiveSceneCoach();
      if (manual) {
        return;
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Text(l10n.liveSceneAnalysisReady),
        ),
      );
    });

    final lastCapture = ref.watch(lastCaptureProvider);
    final isCapturing = ref.watch(isCapturingProvider);
    final showFlash = ref.watch(captureFlashProvider);
    final flashMode = ref.watch(flashModeProvider);
    final cameras = ref.watch(camerasProvider).value ?? [];
    final hdrSupported = ref.watch(hdrSupportedProvider);
    final hdrEnabled = ref.watch(hdrEnabledProvider);
    final hdrActive = hdrSupported && hdrEnabled;
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
    final showCoachBanner = _isFreeShootMode &&
        !coachDismissed &&
        !hasAdvice &&
        !isLiveAnalyzing;
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewport = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              final cropAspectRatio = _resolveCropAspectRatio(ref, viewport);

              return Stack(
                fit: StackFit.expand,
                children: [
                  LetterboxedCameraViewport(
                    cropAspectRatio: cropAspectRatio,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        IosCameraPreview(controller: widget.controller),
                        IosAspectRatioOverlay(aspectRatio: aspectRatio),
                        if (widget.croppedOverlay != null)
                          widget.croppedOverlay!,
                        if (_isFreeShootMode && hasAdvice)
                          const LiveSceneGuidanceFrameOverlay(),
                      ],
                    ),
                  ),
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
              if (_isFreeShootMode)
                LiveSceneAnalyzingOverlay(
                  visible: isLiveAnalyzing,
                  autoTriggered: !isManualRun,
                ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IosCameraTopBar(
                  flashMode: flashMode,
                  hdrEnabled: hdrActive,
                  aeAfLocked: aeAfLocked,
                  aeAfLockLabel: l10n.aeAfLocked,
                  onClose: () => _handleClose(context),
                  onFlashTap: () =>
                      ref.read(cameraControllerProvider.notifier).cycleFlashMode(),
                  onGridTap: widget.onGridTap,
                  onFrameTap: widget.onFrameTap,
                  gridEnabled: widget.gridEnabled,
                  frameEnabled: widget.frameEnabled,
                  showGridButton: widget.showGridButton,
                  showFrameButton: widget.showFrameButton,
                  showAiAnalyzeButton: _isFreeShootMode,
                  aiAnalyzing: isLiveAnalyzing,
                  onAiAnalyzeTap: countdown == null &&
                          !isBursting &&
                          !isCapturing &&
                          !isLiveAnalyzing
                      ? () => _analyzeLiveScene(context)
                      : null,
                  aiAnalyzeTooltip: l10n.liveSceneAnalyze,
                  centerLabel: widget.centerTopLabel,
                  showAspectRatioButton: true,
                  aspectRatioLabel: _aspectRatioLabel(l10n, aspectRatio),
                  onAspectRatioTap: () {
                    ref.read(cameraAspectRatioProvider.notifier).state =
                        aspectRatio.next;
                  },
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
              if (_isFreeShootMode)
                liveAnalysis.maybeWhen(
                  data: (analysis) {
                    if (analysis == null) {
                      return const SizedBox.shrink();
                    }
                    return AngleGuidanceOverlay(
                      angleDegrees: analysis.guidance.angleDegrees,
                      angleHintKey: analysis.guidance.angleHintKey,
                      visible: true,
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              if (_isFreeShootMode) const LiveSceneAutoAnalyzer(),
                ],
              );
            },
          ),
        ),
        if (widget.guidanceChip != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: widget.guidanceChip!,
          ),
        if (_isFreeShootMode)
          LiveSceneCoachBanner(visible: showCoachBanner),
        liveAnalysis.maybeWhen(
          data: (analysis) {
            if (analysis == null || !_isFreeShootMode) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
              child: LiveSceneAdvicePanel(
                analysis: analysis,
                isAnalyzing: isLiveAnalyzing,
                onDismiss: () {
                  ref.read(liveSceneAnalysisProvider.notifier).clear();
                },
                onReanalyze: isLiveAnalyzing
                    ? null
                    : () => _analyzeLiveScene(context),
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
        IosCameraBottomBar(
          modeLabel: widget.modeLabel ?? l10n.cameraModePhoto,
          thumbnailBytes: lastCapture?.bytes,
          isCapturing: isCapturing,
          isBursting: isBursting,
          burstCount: burstPhotos.length,
          hdrEnabled: hdrEnabled,
          hdrSupported: hdrSupported,
          hdrLabel: l10n.hdrLabel,
          timerDuration: timerDuration,
          aeAfLocked: aeAfLocked,
          optionsExpanded: optionsExpanded,
          canFlip: cameras.length > 1,
          shutterEnabled: countdown == null,
          onHdrTap: () => _handleHdrTap(context, l10n, hdrSupported, hdrEnabled),
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

  void _handleHdrTap(
    BuildContext context,
    AppLocalizations l10n,
    bool hdrSupported,
    bool hdrEnabled,
  ) {
    if (!hdrSupported) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          content: Text(l10n.hdrComingSoon),
        ),
      );
      return;
    }

    ref.read(hdrEnabledProvider.notifier).state = !hdrEnabled;
    ref.read(cameraModeSettingsProvider.notifier).persistActiveFromProviders();
  }

  Future<void> _handleClose(BuildContext context) async {
    ref.invalidate(liveSceneAnalysisProvider);

    if (widget.shootSessionMode == null) {
      ref.invalidate(cameraControllerProvider);
      if (context.mounted) {
        Navigator.of(context).maybePop();
      }
      return;
    }

    final shouldPop = await confirmEndSessionOnClose(context, ref);
    if (shouldPop && context.mounted) {
      ref.invalidate(cameraControllerProvider);
      if (context.mounted) {
        Navigator.of(context).maybePop();
      }
    }
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
      if (widget.shootSessionMode != null) {
        ref.read(shootSessionProvider.notifier).recordCapture(photo);
        ref.read(voiceGuidanceServiceProvider).speak(context, l10n.photoPreview);
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PhotoReviewScreen(
            photo: photo,
            isSessionCapture: widget.shootSessionMode != null,
          ),
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

    if (widget.shootSessionMode != null) {
      for (final photo in photos) {
        ref.read(shootSessionProvider.notifier).recordCapture(photo);
      }
    }

    if (photos.length == 1) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PhotoReviewScreen(
            photo: photos.first,
            isSessionCapture: widget.shootSessionMode != null,
          ),
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
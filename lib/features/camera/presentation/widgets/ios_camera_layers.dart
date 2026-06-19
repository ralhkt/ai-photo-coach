import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/settings/app_settings_provider.dart';
import '../../../../models/camera_aspect_ratio.dart';
import '../../../ar/presentation/ar_horizon_overlay.dart';
import '../../../ar/presentation/ar_status_chip.dart';
import '../../../ar/providers/ar_providers.dart';
import '../../../ar/services/ar_platform_service.dart';
import '../../../scene_stabilization/providers/scene_stability_provider.dart';
import '../../../reference/providers/guided_frame_providers.dart';
import '../../providers/camera_capture_provider.dart';
import '../../providers/camera_interaction_provider.dart';
import '../../providers/camera_mode_settings_provider.dart';
import '../../providers/camera_providers.dart';
import '../../providers/camera_settings_provider.dart';
import '../../providers/live_scene_analysis_provider.dart';
import 'angle_guidance_overlay.dart';
import 'ios_camera_grid_overlay.dart';
import 'ios_camera_preview.dart';
import 'ios_camera_top_bar.dart';
import 'ios_countdown_overlay.dart';
import 'ios_histogram_overlay.dart';
import 'letterboxed_camera_viewport.dart';
import 'live_scene_advice_panel.dart';
import 'live_scene_analyzing_overlay.dart';
import 'live_scene_coach_banner.dart';
import 'live_scene_guidance_frame_overlay.dart';

/// Isolated camera preview — only rebuilds when aspect ratio or overlays change.
class IosCameraPreviewLayer extends ConsumerWidget {
  const IosCameraPreviewLayer({
    super.key,
    required this.controller,
    this.croppedOverlay,
    this.showLiveGuidanceFrame = false,
    this.showNativeGrid = true,
    this.useGuidedGridProvider = false,
  });

  final CameraController controller;
  final Widget? croppedOverlay;
  final bool showLiveGuidanceFrame;
  final bool showNativeGrid;
  final bool useGuidedGridProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aspectRatio = ref.watch(cameraAspectRatioProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cropAspectRatio =
            aspectRatio.displayCropRatio(constraints.biggest);

        return RepaintBoundary(
          child: LetterboxedCameraViewport(
            cropAspectRatio: cropAspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraPreviewScope(controller: controller),
                _PreviewGridOverlay(
                  fallbackVisible: showNativeGrid,
                  useGuidedProvider: useGuidedGridProvider,
                ),
                if (croppedOverlay != null)
                  RepaintBoundary(child: croppedOverlay!),
                if (showLiveGuidanceFrame)
                  const LiveSceneGuidanceFrameOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Grid toggle rebuilds only this layer — not the camera preview texture.
class _PreviewGridOverlay extends ConsumerWidget {
  const _PreviewGridOverlay({
    required this.fallbackVisible,
    required this.useGuidedProvider,
  });

  final bool fallbackVisible;
  final bool useGuidedProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = useGuidedProvider
        ? ref.watch(guidedCompositionVisibleProvider)
        : fallbackVisible;
    return IosCameraGridOverlay(visible: visible);
  }
}

class IosCameraFlashLayer extends ConsumerWidget {
  const IosCameraFlashLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showFlash = ref.watch(captureFlashProvider);
    if (!showFlash) {
      return const SizedBox.shrink();
    }

    return const IgnorePointer(
      child: ColoredBox(color: Colors.white),
    );
  }
}

class IosCameraCountdownLayer extends ConsumerWidget {
  const IosCameraCountdownLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdown = ref.watch(timerCountdownProvider);
    if (countdown == null) {
      return const SizedBox.shrink();
    }
    return IosCountdownOverlay(seconds: countdown);
  }
}

class IosCameraTopBarLayer extends ConsumerWidget {
  const IosCameraTopBarLayer({
    super.key,
    required this.onClose,
    this.centerLabel,
  });

  final VoidCallback onClose;
  final String? centerLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final flashMode = ref.watch(flashModeProvider);
    final hdrSupported = ref.watch(hdrSupportedProvider);
    final hdrEnabled = ref.watch(hdrEnabledProvider);
    final aeAfLocked = ref.watch(aeAfLockProvider);
    final aspectRatio = ref.watch(cameraAspectRatioProvider);
    final optionsExpanded = ref.watch(showCameraOptionsProvider);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IosCameraTopBar(
        flashMode: flashMode,
        hdrEnabled: hdrSupported && hdrEnabled,
        aeAfLocked: aeAfLocked,
        aeAfLockLabel: l10n.aeAfLocked,
        formatLabel: l10n.cameraFormatJpeg,
        megapixelLabel: l10n.cameraFormatMegapixel,
        nightModeEnabled: hdrSupported && hdrEnabled,
        nightModeSupported: hdrSupported,
        onClose: onClose,
        onFlashTap: () {
          markCameraUiInteraction(ref);
          ref.read(cameraControllerProvider.notifier).cycleFlashMode();
        },
        onNightModeTap: () {
          markCameraUiInteraction(ref);
          ref.read(hdrEnabledProvider.notifier).state = !hdrEnabled;
          ref.read(cameraModeSettingsProvider.notifier).persistActiveFromProviders();
        },
        onFormatTap: () {
          markCameraUiInteraction(ref);
          ref.read(cameraAspectRatioProvider.notifier).state = aspectRatio.next;
        },
        onSettingsTap: () {
          markCameraUiInteraction(ref);
          ref.read(showCameraOptionsProvider.notifier).state = !optionsExpanded;
        },
        centerLabel: centerLabel,
      ),
    );
  }
}

class IosCameraPhase2Layer extends ConsumerWidget {
  const IosCameraPhase2Layer({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enabled) {
      return const SizedBox.shrink();
    }

    final arStatus =
        ref.watch(arSessionProvider).value ?? ArPlatformStatus.initial;
    final sceneStatus = ref.watch(sceneStabilityProvider);
    final arOverlayVisible = ref.watch(arOverlayVisibleProvider);
    final topInset = MediaQuery.paddingOf(context).top;

    return Stack(
      fit: StackFit.expand,
      children: [
        ArHorizonOverlay(visible: arOverlayVisible),
        Positioned(
          top: topInset + 52,
          left: 16,
          child: ArStatusChip(
            arStatus: arStatus,
            sceneStatus: sceneStatus,
          ),
        ),
      ],
    );
  }
}

class IosCameraHistogramLayer extends ConsumerWidget {
  const IosCameraHistogramLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showHistogram = ref.watch(showHistogramProvider);
    if (!showHistogram) {
      return const SizedBox.shrink();
    }
    final manualEv = ref.watch(manualExposureOffsetProvider);
    return IosHistogramOverlay(brightness: 0.45 + manualEv * 0.1);
  }
}

class IosCameraAngleGuidanceLayer extends ConsumerWidget {
  const IosCameraAngleGuidanceLayer({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enabled) {
      return const SizedBox.shrink();
    }

    final analysis = ref.watch(liveSceneAnalysisProvider).value;
    if (analysis == null) {
      return const SizedBox.shrink();
    }

    return AngleGuidanceOverlay(
      angleDegrees: analysis.guidance.angleDegrees,
      angleHintKey: analysis.guidance.angleHintKey,
      visible: true,
    );
  }
}

class IosCameraCoachBannerLayer extends ConsumerWidget {
  const IosCameraCoachBannerLayer({
    super.key,
    required this.enabled,
    required this.bottomOffset,
  });

  final bool enabled;
  final double bottomOffset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enabled) {
      return const SizedBox.shrink();
    }

    final coachDismissed = ref.watch(liveSceneCoachDismissedProvider);
    final hasAdvice = ref.watch(liveSceneAnalysisProvider).value != null;
    final isLiveAnalyzing = ref.watch(liveSceneAnalyzingProvider);

    if (coachDismissed || hasAdvice || isLiveAnalyzing) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 16,
      right: 16,
      bottom: bottomOffset,
      child: const LiveSceneCoachBanner(visible: true),
    );
  }
}

class IosCameraAdvicePanelLayer extends ConsumerWidget {
  const IosCameraAdvicePanelLayer({
    super.key,
    required this.enabled,
    required this.bottomOffset,
    required this.onReanalyze,
    required this.onDismiss,
  });

  final bool enabled;
  final double bottomOffset;
  final VoidCallback? onReanalyze;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enabled) {
      return const SizedBox.shrink();
    }

    final analysis = ref.watch(liveSceneAnalysisProvider).value;
    final isLiveAnalyzing = ref.watch(liveSceneAnalyzingProvider);
    if (analysis == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomOffset,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.38,
        ),
        child: SingleChildScrollView(
          child: LiveSceneAdvicePanel(
            analysis: analysis,
            isAnalyzing: isLiveAnalyzing,
            onDismiss: onDismiss,
            onReanalyze: isLiveAnalyzing ? null : onReanalyze,
          ),
        ),
      ),
    );
  }
}

class IosCameraAnalyzingLayer extends ConsumerWidget {
  const IosCameraAnalyzingLayer({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enabled) {
      return const SizedBox.shrink();
    }

    final isLiveAnalyzing = ref.watch(liveSceneAnalyzingProvider);
    final isManualRun = ref.watch(liveSceneManualRunProvider);

    return LiveSceneAnalyzingOverlay(
      visible: isLiveAnalyzing,
      autoTriggered: !isManualRun,
    );
  }
}
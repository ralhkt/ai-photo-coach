import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/services/voice_guidance_service.dart';
import '../../../../core/settings/app_settings_provider.dart';
import '../../../../core/utils/guidance_text.dart';
import '../../../../core/utils/pose_coaching_hint.dart';
import '../../../../core/widgets/app_glass_widgets.dart';
import '../../../scene_stabilization/providers/scene_stability_provider.dart';
import '../../../../models/camera_aspect_ratio.dart';
import '../../../../models/camera_timer_duration.dart';
import '../../../../models/captured_photo.dart';
import '../../../../models/shoot_session.dart';
import '../../../session/presentation/session_flow.dart';
import '../../../session/providers/shoot_session_provider.dart';
import '../../providers/camera_capture_provider.dart';
import '../../providers/camera_interaction_provider.dart';
import '../../providers/camera_mode_settings_provider.dart';
import '../../providers/camera_providers.dart';
import '../../providers/camera_settings_provider.dart';
import '../../providers/live_scene_analysis_provider.dart';
import '../../../pose/providers/pose_coaching_provider.dart';
import '../burst_review_screen.dart';
import '../camera_shell_mode.dart';
import '../ios_camera_mode_switcher.dart';
import '../photo_review_screen.dart';
import 'ios_camera_bottom_bar_host.dart';
import 'ios_camera_layers.dart';
import 'ios_camera_ui_kit.dart';

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
    this.useGuidedGridProvider = false,
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
  final bool useGuidedGridProvider;
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

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const bottomChromeHeight = IosCameraUiKit.bottomChromeHeight;
    const guidedHintHeight = 44.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        Stack(
          fit: StackFit.expand,
          children: [
            IosCameraPreviewLayer(
              controller: widget.controller,
              croppedOverlay: widget.croppedOverlay,
              showLiveGuidanceFrame: _isFreeShootMode,
              showNativeGrid: widget.gridEnabled,
              useGuidedGridProvider: widget.useGuidedGridProvider,
            ),
            widget.overlay,
            IosCameraPhase2Layer(enabled: widget.enablePhase2),
            const IosCameraFlashLayer(),
            const IosCameraCountdownLayer(),
            IosCameraAnalyzingLayer(enabled: _isFreeShootMode),
            IosCameraTopBarLayer(
              onClose: () => _handleClose(context),
              centerLabel: widget.centerTopLabel,
            ),
            const IosCameraHistogramLayer(),
            IosCameraAngleGuidanceLayer(enabled: _isFreeShootMode),
            LiveSceneAnalyzeButtonLayer(
              enabled: _isFreeShootMode,
              onAnalyze: () => _analyzeLiveScene(context),
            ),
          ],
        ),
        IosCameraCoachBannerLayer(
          enabled: _isFreeShootMode,
          bottomOffset: bottomChromeHeight + bottomInset + 8,
        ),
        IosCameraAdvicePanelLayer(
          enabled: _isFreeShootMode,
          bottomOffset: bottomChromeHeight + bottomInset,
          onDismiss: () {
            ref.read(liveSceneAnalysisProvider.notifier).clear();
          },
          onReanalyze: () => _analyzeLiveScene(context),
        ),
        if (widget.guidanceChip != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomChromeHeight + bottomInset + 8,
            child: SizedBox(
              height: guidedHintHeight,
              child: widget.guidanceChip!,
            ),
          )
        else if (_isFreeShootMode && ref.watch(poseCoachingShouldRunProvider))
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomChromeHeight + bottomInset + 8,
            child: const SizedBox(
              height: guidedHintHeight,
              child: _LivePoseCoachingChip(),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: RepaintBoundary(
            child: IosCameraBottomBarHost(
              onHdrTap: (supported, enabled) =>
                  _handleHdrTap(context, l10n, supported, enabled),
              onGalleryTap: (hasLast) => _openGallery(context, hasLast),
              onShutterTap: () => _capture(context),
              onBurstEnd: () => _finishBurst(context),
            ),
          ),
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
    markCameraUiInteraction(ref);
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

class _LivePoseCoachingChip extends ConsumerWidget {
  const _LivePoseCoachingChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stability = ref.watch(sceneStabilityProvider);
    final coaching = ref.watch(poseCoachingResultProvider);
    final aligned = isPoseCoachingAligned(
      stability: stability,
      coaching: coaching,
    );

    return AppCoachPill(
      message: resolvePoseCoachingMessage(
        l10n: l10n,
        stability: stability,
        coaching: coaching,
      ),
      icon: aligned
          ? Icons.check_circle_outline_rounded
          : Icons.accessibility_new_rounded,
      maxLines: 2,
    );
  }
}


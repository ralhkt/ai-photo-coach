import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/app_glass_widgets.dart';

import '../../../core/utils/coaching_guidance_helper.dart';
import '../../../core/utils/guidance_text.dart';
import '../../../core/utils/pose_coaching_hint.dart';
import '../../pose/providers/pose_coaching_provider.dart';
import '../../scene_stabilization/providers/scene_stability_provider.dart';

import '../../../models/camera_aspect_ratio.dart';
import '../../../models/camera_guidance.dart';
import '../../../models/shoot_session.dart';
import '../../../models/photo_frame_template.dart';
import '../../frames/presentation/guided_camera_overlay_stack.dart';
import '../../pose/platform/pose_silhouette_auto_capture_listener.dart';
import '../../overlays/providers/overlay_providers.dart';
import '../../reference/providers/guided_frame_providers.dart';
import '../../reference/providers/reference_providers.dart';
import '../providers/camera_interaction_provider.dart';
import '../providers/camera_mode_settings_provider.dart';
import '../providers/camera_providers.dart';
import '../providers/camera_settings_provider.dart';
import 'widgets/guided_overlay_tools_sheet.dart';
import 'widgets/camera_error_view.dart';
import 'widgets/camera_mode_scope.dart';
import 'widgets/camera_session_lifecycle.dart';
import 'widgets/ios_camera_scaffold.dart';

class GuidedCameraScreen extends ConsumerStatefulWidget {
  const GuidedCameraScreen({super.key});

  @override
  ConsumerState<GuidedCameraScreen> createState() =>
      _GuidedCameraScreenState();
}

class _GuidedCameraScreenState extends ConsumerState<GuidedCameraScreen> {
  bool _guidanceApplied = false;

  Future<void> _applyAnalysisGuidance() async {
    final analysis = ref.read(referenceAnalysisProvider).value;
    if (analysis == null || _guidanceApplied) {
      return;
    }

    _guidanceApplied = true;
    ref.read(overlayTypeProvider.notifier).state = analysis.guidance.overlayType;
    await ref.read(cameraControllerProvider.notifier).applyGuidanceSettings(
          analysis.guidance,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final analysis = ref.watch(referenceAnalysisProvider).value;
    final cameraState = ref.watch(cameraControllerProvider);

    if (analysis == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text(l10n.noReferenceLoaded)),
      );
    }

    final guidance = analysis.guidance;

    return Scaffold(
      backgroundColor: Colors.black,
      body: cameraState.when(
        loading: () => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(l10n.initializingCamera),
            ],
          ),
        ),
        error: (error, _) => CameraErrorView(
          message: l10n.cameraError,
          detail: error.toString(),
          retryLabel: l10n.retry,
          onRetry: () => ref.read(cameraControllerProvider.notifier).retry(),
        ),
        data: (controller) {
          if (controller == null || !controller.value.isInitialized) {
            return CameraErrorView(
              message: l10n.noCameraFound,
              retryLabel: l10n.retry,
              onRetry: () => ref.read(cameraControllerProvider.notifier).retry(),
            );
          }

          final coachingGuidance = CoachingGuidanceHelper().forGuidedOverlay(
            CoachingGuidanceHelper().ensureHumanSilhouette(guidance),
          );
          return PoseSilhouetteAutoCaptureListener(
            child: CameraModeScope(
                mode: CameraUiMode.guided,
                onActivated: _applyAnalysisGuidance,
                child: CameraSessionLifecycle(
                controller: controller,
                enableAr: false,
                shootSessionMode: ShootSessionMode.guided,
                child: IosCameraScaffold(
                  controller: controller,
                  enablePhase2: false,
                  shootSessionMode: ShootSessionMode.guided,
                  modeLabel: l10n.cameraModeGuided,
                  useGuidedGridProvider: true,
                  guidanceChip: const _PoseCoachingChip(),
                  croppedOverlay: _GuidedOverlayHost(
                    guidance: coachingGuidance,
                    imageBytes: analysis.imageBytes,
                    sourceAspectRatio: analysis.sourceAspectRatio,
                  ),
                  overlay: _GuidedToolbar(
                    initialTemplate: guidance.frameTemplate,
                    onOpenTools: () {
                      markGuidedUserActivity(ref);
                      showGuidedOverlayToolsSheet(context);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GuidedOverlayHost extends ConsumerWidget {
  const _GuidedOverlayHost({
    required this.guidance,
    required this.imageBytes,
    required this.sourceAspectRatio,
  });

  final CameraGuidance guidance;
  final Uint8List imageBytes;
  final double sourceAspectRatio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraAspectRatio = ref.watch(cameraAspectRatioProvider);
    return GuidedCameraOverlayStack(
      guidance: guidance,
      imageBytes: imageBytes,
      sourceAspectRatio: sourceAspectRatio,
      cameraAspectRatio: cameraAspectRatio,
    );
  }
}

class _GuidedToolbar extends ConsumerWidget {
  const _GuidedToolbar({
    required this.initialTemplate,
    required this.onOpenTools,
  });

  final PhotoFrameTemplate initialTemplate;
  final VoidCallback onOpenTools;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final top = MediaQuery.paddingOf(context).top + 56;
    final template = ref.watch(guidedFrameTemplateProvider) ?? initialTemplate;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          left: 0,
          right: 0,
          child: Center(
            child: _GuidedTemplateChip(label: frameTemplateLabel(l10n, template)),
          ),
        ),
        Positioned(
          right: 12,
          top: top,
          child: Column(
            children: [
              _GuidedGridToggleButton(tooltip: l10n.toggleOverlay),
              const SizedBox(height: 8),
              _GuidedFrameToggleButton(tooltip: l10n.toggleFrame),
              const SizedBox(height: 8),
              AppCameraToolButton(
                icon: Icons.layers_outlined,
                tooltip: l10n.guidedOverlayTools,
                onTap: onOpenTools,
              ),
              const SizedBox(height: 8),
              AppCameraToolButton(
                icon: Icons.aspect_ratio_rounded,
                tooltip: l10n.chooseFrameTemplate,
                onTap: () => cycleGuidedFrameTemplate(
                  ref,
                  current: template,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuidedTemplateChip extends StatelessWidget {
  const _GuidedTemplateChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _GuidedGridToggleButton extends ConsumerWidget {
  const _GuidedGridToggleButton({required this.tooltip});

  final String tooltip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(guidedCompositionVisibleProvider);
    return AppCameraToolButton(
      icon: visible ? Icons.grid_on_rounded : Icons.grid_off_rounded,
      tooltip: tooltip,
      onTap: () => toggleGuidedCompositionVisible(ref),
    );
  }
}

class _GuidedFrameToggleButton extends ConsumerWidget {
  const _GuidedFrameToggleButton({required this.tooltip});

  final String tooltip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(guidedFrameVisibleProvider);
    return AppCameraToolButton(
      icon: visible ? Icons.crop_free_rounded : Icons.crop_free_outlined,
      tooltip: tooltip,
      onTap: () => toggleGuidedFrameVisible(ref),
    );
  }
}

class _PoseCoachingChip extends ConsumerWidget {
  const _PoseCoachingChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    ref.watch(
      poseCoachingResultProvider.select(
        (result) => (
          result?.poseScore,
          result?.combinedGuidance,
          result?.isLevel,
          result?.poseMatched,
        ),
      ),
    );
    final stabilityState =
        ref.watch(sceneStabilityProvider.select((status) => status.state));
    final stability = SceneStabilityStatus(
      state: stabilityState,
      hammingDistance: 0,
    );
    final fullCoaching = ref.read(poseCoachingResultProvider);
    final aligned = isPoseCoachingAligned(
      stability: stability,
      coaching: fullCoaching,
    );

    return AppCoachPill(
      message: resolvePoseCoachingMessage(
        l10n: l10n,
        stability: stability,
        coaching: fullCoaching,
      ),
      icon: aligned
          ? Icons.check_circle_outline_rounded
          : Icons.accessibility_new_rounded,
      maxLines: 2,
    );
  }
}
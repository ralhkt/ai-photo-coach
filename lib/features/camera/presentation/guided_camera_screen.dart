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
import '../../../models/shoot_session.dart';
import '../../../models/photo_frame_template.dart';
import '../../../models/subject_shape_kind.dart';
import '../../frames/presentation/guided_camera_overlay_stack.dart';
import '../../overlays/providers/overlay_providers.dart';
import '../../reference/providers/guided_frame_providers.dart';
import '../../reference/providers/reference_providers.dart';
import '../providers/camera_mode_settings_provider.dart';
import '../providers/camera_providers.dart';
import '../providers/camera_settings_provider.dart';
import '../providers/pose_contour_stabilizer_provider.dart';
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
  bool _frameVisible = true;
  bool _compositionVisible = true;
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
    final cameraAspectRatio = ref.watch(cameraAspectRatioProvider);

    if (analysis == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text(l10n.noReferenceLoaded)),
      );
    }

    final guidance = analysis.guidance;
    final partLabels = bodyPartLabels(l10n);

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

          final coachingGuidance = CoachingGuidanceHelper().forPozeOverlay(
            CoachingGuidanceHelper().ensureHumanSilhouette(guidance),
            stabilizer: ref.read(poseContourStabilizerProvider),
          );

          return CameraModeScope(
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
                  centerTopLabel:
                      frameTemplateLabel(l10n, guidance.frameTemplate),
                  gridEnabled: _compositionVisible,
                  frameEnabled: _frameVisible,
                  showGridButton: true,
                  showFrameButton: true,
                  onGridTap: () =>
                      setState(() => _compositionVisible = !_compositionVisible),
                  onFrameTap: () => setState(() => _frameVisible = !_frameVisible),
                  guidanceChip: const _PoseCoachingChip(),
                  croppedOverlay: GuidedCameraOverlayStack(
                    guidance: coachingGuidance,
                    imageBytes: analysis.imageBytes,
                    sourceAspectRatio: analysis.sourceAspectRatio,
                    cameraAspectRatio: cameraAspectRatio,
                    compositionVisible: _compositionVisible,
                    frameVisible: _frameVisible,
                    partLabels: partLabels,
                  ),
                  overlay: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        right: 12,
                        top: MediaQuery.paddingOf(context).top + 56,
                        child: Column(
                          children: [
                            AppCameraToolButton(
                              icon: Icons.layers_outlined,
                              tooltip: l10n.guidedOverlayTools,
                              onTap: () => showGuidedOverlayToolsSheet(context),
                            ),
                            const SizedBox(height: 8),
                            AppCameraToolButton(
                              icon: Icons.aspect_ratio_rounded,
                              tooltip: l10n.chooseFrameTemplate,
                              onTap: () {
                                ref
                                    .read(referenceAnalysisProvider.notifier)
                                    .setFrameTemplate(
                                        guidance.frameTemplate.next);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          );
        },
      ),
    );
  }
}

class _PoseCoachingChip extends ConsumerWidget {
  const _PoseCoachingChip();

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


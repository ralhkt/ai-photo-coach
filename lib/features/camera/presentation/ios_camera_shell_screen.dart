import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/utils/coaching_guidance_helper.dart';
import '../../../core/utils/guidance_text.dart';
import '../../../core/utils/pose_coaching_hint.dart';
import '../../../core/widgets/app_glass_widgets.dart';
import '../../../models/camera_aspect_ratio.dart';
import '../../../models/photo_frame_template.dart';
import '../../../models/shoot_session.dart';
import '../../overlays/providers/overlay_providers.dart';
import '../../frames/presentation/guided_camera_overlay_stack.dart';
import '../../pose/platform/pose_silhouette_auto_capture_listener.dart';
import '../../pose/providers/pose_coaching_provider.dart';
import '../../reference/providers/guided_frame_providers.dart';
import '../../reference/providers/reference_providers.dart';
import '../../scene_stabilization/providers/scene_stability_provider.dart';
import '../providers/camera_interaction_provider.dart';
import '../providers/camera_mode_settings_provider.dart';
import '../providers/camera_providers.dart';
import '../providers/camera_settings_provider.dart';
import '../providers/camera_shell_provider.dart';
import '../providers/pose_contour_stabilizer_provider.dart';
import 'camera_shell_mode.dart';
import 'widgets/camera_error_view.dart';
import 'widgets/camera_mode_scope.dart';
import 'widgets/camera_session_lifecycle.dart';
import 'widgets/guided_overlay_tools_sheet.dart';
import 'widgets/ios_camera_scaffold.dart';

/// Single camera route — mode carousel swaps overlays without [Navigator] replacement.
class IosCameraShellScreen extends ConsumerStatefulWidget {
  const IosCameraShellScreen({
    super.key,
    this.initialMode = CameraShellMode.photo,
  });

  final CameraShellMode initialMode;

  @override
  ConsumerState<IosCameraShellScreen> createState() =>
      _IosCameraShellScreenState();
}

class _IosCameraShellScreenState extends ConsumerState<IosCameraShellScreen> {
  bool _frameVisible = true;
  bool _compositionVisible = true;
  bool _guidanceApplied = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(cameraShellModeProvider.notifier).state = widget.initialMode;
    });
  }

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
    final shellMode = ref.watch(cameraShellModeProvider);
    final isGuided = shellMode == CameraShellMode.guided;
    final analysis = ref.watch(referenceAnalysisProvider).value;
    final cameraState = ref.watch(cameraControllerProvider);
    final cameraAspectRatio = ref.watch(cameraAspectRatioProvider);
    final overlayVisible = ref.watch(overlayVisibleProvider);

    if (isGuided && analysis == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text(l10n.noReferenceLoaded)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: cameraState.when(
        loading: () => _LoadingView(message: l10n.initializingCamera),
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

          final guidance = analysis?.guidance;
          final partLabels = bodyPartLabels(l10n);
          final coachingGuidance = guidance == null
              ? null
              : CoachingGuidanceHelper().forGuidedOverlay(
                  CoachingGuidanceHelper().ensureHumanSilhouette(guidance),
                  stabilizer: ref.read(poseContourStabilizerProvider),
                );

          final scaffold = IosCameraScaffold(
            controller: controller,
            enablePhase2: !isGuided,
            shootSessionMode: isGuided
                ? ShootSessionMode.guided
                : ShootSessionMode.free,
            modeLabel: _modeLabel(l10n, shellMode),
            centerTopLabel: isGuided && guidance != null
                ? frameTemplateLabel(l10n, guidance.frameTemplate)
                : null,
            gridEnabled: isGuided ? _compositionVisible : overlayVisible,
            frameEnabled: _frameVisible,
            showGridButton: isGuided,
            showFrameButton: isGuided,
            onGridTap: isGuided
                ? () {
                    markCameraUiInteraction(ref);
                    setState(() => _compositionVisible = !_compositionVisible);
                  }
                : null,
            onFrameTap: isGuided
                ? () {
                    markCameraUiInteraction(ref);
                    setState(() => _frameVisible = !_frameVisible);
                  }
                : null,
            guidanceChip: isGuided ? const _PoseCoachingChip() : null,
            croppedOverlay: isGuided && coachingGuidance != null && analysis != null
                ? GuidedCameraOverlayStack(
                    guidance: coachingGuidance,
                    imageBytes: analysis.imageBytes,
                    sourceAspectRatio: analysis.sourceAspectRatio,
                    cameraAspectRatio: cameraAspectRatio,
                    compositionVisible: _compositionVisible,
                    frameVisible: _frameVisible,
                    partLabels: partLabels,
                  )
                : null,
            overlay: isGuided
                ? Stack(
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
                            if (guidance != null) ...[
                              const SizedBox(height: 8),
                              AppCameraToolButton(
                                icon: Icons.aspect_ratio_rounded,
                                tooltip: l10n.chooseFrameTemplate,
                                onTap: () {
                                  ref
                                      .read(referenceAnalysisProvider.notifier)
                                      .setFrameTemplate(
                                        guidance.frameTemplate.next,
                                      );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          );

          final sessionChild = isGuided
              ? PoseSilhouetteAutoCaptureListener(child: scaffold)
              : scaffold;

          return CameraModeScope(
            mode: isGuided ? CameraUiMode.guided : CameraUiMode.free,
            onActivated: isGuided ? _applyAnalysisGuidance : null,
            child: CameraSessionLifecycle(
              controller: controller,
              enableAr: !isGuided,
              shootSessionMode: isGuided
                  ? ShootSessionMode.guided
                  : ShootSessionMode.free,
              child: sessionChild,
            ),
          );
        },
      ),
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

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white70)),
        ],
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
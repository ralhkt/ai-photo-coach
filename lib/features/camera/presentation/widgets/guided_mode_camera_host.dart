import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/coaching_guidance_helper.dart';
import '../../../../core/utils/guidance_text.dart';
import '../../../../core/utils/pose_coaching_hint.dart';
import '../../../../core/widgets/app_glass_widgets.dart';
import '../../../../models/camera_guidance.dart';
import '../../../../models/photo_analysis_result.dart';
import '../../../../models/photo_frame_template.dart';
import '../../../../models/shoot_session.dart';
import '../../../frames/presentation/guided_camera_overlay_stack.dart';
import '../../../pose/platform/pose_silhouette_auto_capture_listener.dart';
import '../../../pose/providers/pose_coaching_provider.dart';
import '../../../reference/providers/guided_frame_providers.dart';
import '../../../reference/providers/reference_providers.dart';
import '../../../scene_stabilization/providers/scene_stability_provider.dart';
import '../../providers/camera_interaction_provider.dart';
import '../../providers/camera_mode_settings_provider.dart';
import '../../providers/camera_settings_provider.dart';
import '../camera_shell_mode.dart';
import 'camera_mode_scope.dart';
import 'camera_session_lifecycle.dart';
import 'guided_overlay_tools_sheet.dart';
import 'guided_toggle_button.dart';
import 'ios_camera_scaffold.dart';

/// Guided camera subtree — visibility toggles use Riverpod, not [setState].
class GuidedModeCameraHost extends ConsumerStatefulWidget {
  const GuidedModeCameraHost({
    super.key,
    required this.controller,
    required this.analysis,
    required this.shellMode,
    required this.onApplyGuidance,
  });

  final CameraController controller;
  final PhotoAnalysisResult analysis;
  final CameraShellMode shellMode;
  final Future<void> Function() onApplyGuidance;

  @override
  ConsumerState<GuidedModeCameraHost> createState() =>
      _GuidedModeCameraHostState();
}

class _GuidedModeCameraHostState extends ConsumerState<GuidedModeCameraHost> {
  CameraGuidance? _overlayGuidance;

  @override
  void initState() {
    super.initState();
    _overlayGuidance = _buildOverlayGuidance(widget.analysis.guidance);
  }

  @override
  void didUpdateWidget(covariant GuidedModeCameraHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.analysis.guidance != widget.analysis.guidance) {
      _overlayGuidance = _buildOverlayGuidance(widget.analysis.guidance);
    }
  }

  CameraGuidance _buildOverlayGuidance(CameraGuidance guidance) {
    return CoachingGuidanceHelper().forGuidedOverlay(
      CoachingGuidanceHelper().ensureHumanSilhouette(guidance),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final guidance = widget.analysis.guidance;
    final overlayGuidance = _overlayGuidance;

    final scaffold = IosCameraScaffold(
      controller: widget.controller,
      enablePhase2: false,
      shootSessionMode: ShootSessionMode.guided,
      modeLabel: l10n.cameraModeGuided,
      centerTopLabel: null,
      useGuidedGridProvider: false,
      guidanceChip: const _PoseCoachingChip(),
      croppedOverlay: overlayGuidance == null
          ? null
          : _GuidedOverlayHost(
              guidance: overlayGuidance,
              imageBytes: widget.analysis.imageBytes,
              sourceAspectRatio: widget.analysis.sourceAspectRatio,
            ),
      overlay: _GuidedToolbar(
        initialTemplate: guidance.frameTemplate,
        onOpenTools: () {
          markGuidedUserActivity(ref);
          showGuidedOverlayToolsSheet(context);
        },
      ),
    );

    return CameraModeScope(
      mode: CameraUiMode.guided,
      onActivated: widget.onApplyGuidance,
      child: CameraSessionLifecycle(
        controller: widget.controller,
        enableAr: false,
        shootSessionMode: ShootSessionMode.guided,
        child: PoseSilhouetteAutoCaptureListener(child: scaffold),
      ),
    );
  }
}

/// Watches aspect ratio only — grid/frame toggles skip this subtree.
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
    final top = MediaQuery.paddingOf(context).top + 56;

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 0,
            right: 0,
            child: Center(
              child: _GuidedTemplateChipHost(initialTemplate: initialTemplate),
            ),
          ),
          Positioned(
            right: 12,
            top: top,
            child: _GuidedToolbarButtons(
              initialTemplate: initialTemplate,
              onOpenTools: onOpenTools,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidedTemplateChipHost extends ConsumerWidget {
  const _GuidedTemplateChipHost({required this.initialTemplate});

  final PhotoFrameTemplate initialTemplate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final template = ref.watch(guidedFrameTemplateProvider) ?? initialTemplate;
    return _GuidedTemplateChip(label: frameTemplateLabel(l10n, template));
  }
}

class _GuidedToolbarButtons extends ConsumerWidget {
  const _GuidedToolbarButtons({
    required this.initialTemplate,
    required this.onOpenTools,
  });

  final PhotoFrameTemplate initialTemplate;
  final VoidCallback onOpenTools;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        GuidedOptimisticToggleButton(
          visibleProvider: guidedCompositionVisibleProvider,
          onIcon: Icons.grid_on_rounded,
          offIcon: Icons.grid_off_rounded,
          tooltip: l10n.toggleOverlay,
          onToggle: toggleGuidedCompositionVisible,
        ),
        const SizedBox(height: 8),
        GuidedOptimisticToggleButton(
          visibleProvider: guidedFrameVisibleProvider,
          onIcon: Icons.crop_free_rounded,
          offIcon: Icons.crop_free_outlined,
          tooltip: l10n.toggleFrame,
          onToggle: toggleGuidedFrameVisible,
        ),
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
            current:
                ref.read(guidedFrameTemplateProvider) ?? initialTemplate,
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

    return RepaintBoundary(
      child: AppCoachPillLite(
        message: resolvePoseCoachingMessage(
          l10n: l10n,
          stability: stability,
          coaching: fullCoaching,
        ),
        icon: aligned
            ? Icons.check_circle_outline_rounded
            : Icons.accessibility_new_rounded,
        maxLines: 2,
      ),
    );
  }
}
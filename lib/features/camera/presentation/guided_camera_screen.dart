import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/settings/app_settings_provider.dart';
import '../../../core/utils/guidance_text.dart';
import '../../../core/utils/coaching_guidance_helper.dart';
import '../../../core/utils/prompt_strength.dart';
import '../../../models/camera_aspect_ratio.dart';
import '../../../models/shoot_session.dart';
import '../../../models/photo_frame_template.dart';
import '../../../models/subject_shape_kind.dart';
import '../../frames/presentation/body_part_alignment_chip.dart';
import '../../frames/presentation/photo_frame_overlay.dart';
import '../../frames/presentation/reference_ghost_overlay.dart';
import '../../overlays/presentation/composition_overlay.dart';
import '../../overlays/providers/overlay_providers.dart';
import '../../reference/providers/guided_frame_providers.dart';
import '../../reference/providers/reference_providers.dart';
import '../providers/camera_mode_settings_provider.dart';
import '../providers/camera_providers.dart';
import '../providers/camera_settings_provider.dart';
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
    final overlayType = ref.watch(overlayTypeProvider);
    final ghostVisible = ref.watch(referenceGhostVisibleProvider);
    final bodyPartsVisible = ref.watch(bodyPartGuidesVisibleProvider);
    final cameraAspectRatio = ref.watch(cameraAspectRatioProvider);

    if (analysis == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text(l10n.noReferenceLoaded)),
      );
    }

    final guidance = analysis.guidance;
    final hasBodyParts = guidance.bodyPartGuides != null;
    final partLabels = bodyPartLabels(l10n);
    final promptFilter = PromptStrengthFilter(ref.watch(promptStrengthProvider));

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

          final coachingGuidance =
              CoachingGuidanceHelper().ensureHumanSilhouette(guidance);

          return CameraModeScope(
                mode: CameraUiMode.guided,
                onActivated: _applyAnalysisGuidance,
                child: CameraSessionLifecycle(
                controller: controller,
                enableAr: true,
                shootSessionMode: ShootSessionMode.guided,
                child: IosCameraScaffold(
                  controller: controller,
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
                  guidanceChip: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasBodyParts && promptFilter.showBodyPartSteps)
                        BodyPartAlignmentChip(
                          labels: partLabels,
                          title: l10n.alignmentGuideTitle,
                          hasBodyParts: true,
                          maxSteps: promptFilter.bodyPartStepCount,
                        ),
                      if (hasBodyParts && promptFilter.showBodyPartSteps)
                        const SizedBox(height: 8),
                      _GuidanceChip(
                        hint: guidanceHintLabel(l10n, guidance.framingHintKey),
                        secondaryHint: promptFilter.showSecondaryHints
                            ? guidanceHintLabel(l10n, guidance.distanceHintKey)
                            : '',
                        exposureHint: promptFilter.showExposureHints
                            ? guidanceHintLabel(l10n, guidance.exposureHintKey)
                            : '',
                      ),
                    ],
                  ),
                  croppedOverlay: LayoutBuilder(
                    builder: (context, constraints) {
                      final viewport = Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      final cropAspectRatio =
                          cameraAspectRatio.displayCropRatio(viewport);
                      final frameSpec =
                          ref.read(frameGeneratorProvider).generate(
                                template: coachingGuidance.frameTemplate,
                                guidance: coachingGuidance,
                                viewportSize: viewport,
                                viewportIsCropArea: true,
                                sourceAspectRatio: analysis.sourceAspectRatio,
                                targetAspectRatio: cropAspectRatio,
                              );

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          CompositionOverlay(
                            type: overlayType,
                            visible: _compositionVisible,
                          ),
                          ReferenceGhostOverlay(
                            imageBytes: analysis.imageBytes,
                            frameSpec: frameSpec,
                            visible: ghostVisible && _frameVisible,
                          ),
                          PhotoFrameOverlay(
                            frameSpec: frameSpec,
                            templateLabel: frameTemplateLabel(
                              l10n,
                              coachingGuidance.frameTemplate,
                            ),
                            visible: _frameVisible,
                            bodyPartLabels: partLabels,
                            showBodyParts: bodyPartsVisible,
                          ),
                        ],
                      );
                    },
                  ),
                  overlay: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        right: 12,
                        top: 120,
                        child: Column(
                          children: [
                            _OverlayToggleButton(
                              icon: Icons.opacity_rounded,
                              active: ghostVisible,
                              tooltip: l10n.toggleGhostOverlay,
                              onTap: () {
                                ref
                                    .read(referenceGhostVisibleProvider.notifier)
                                    .state = !ghostVisible;
                              },
                            ),
                            const SizedBox(height: 8),
                            if (coachingGuidance.subjectShape ==
                                SubjectShapeKind.humanSilhouette)
                              _OverlayToggleButton(
                                icon: Icons.accessibility_new_rounded,
                                active: bodyPartsVisible,
                                tooltip: l10n.toggleBodyPartGuides,
                                onTap: () {
                                  ref
                                      .read(
                                          bodyPartGuidesVisibleProvider.notifier)
                                      .state = !bodyPartsVisible;
                                },
                              ),
                            const SizedBox(height: 8),
                            _FrameCycleButton(
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

class _GuidanceChip extends StatelessWidget {
  const _GuidanceChip({
    required this.hint,
    required this.secondaryHint,
    required this.exposureHint,
  });

  final String hint;
  final String secondaryHint;
  final String exposureHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hint,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (secondaryHint.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              secondaryHint,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
          if (exposureHint.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              exposureHint,
              style: const TextStyle(color: Color(0xFFFFD60A), fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _OverlayToggleButton extends StatelessWidget {
  const _OverlayToggleButton({
    required this.icon,
    required this.active,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: active
                ? const Color(0x55FFD60A)
                : Colors.black.withOpacity(0.45),
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? const Color(0xFFFFD60A) : Colors.white24,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _FrameCycleButton extends StatelessWidget {
  const _FrameCycleButton({required this.onTap, required this.tooltip});

  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.aspect_ratio_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
      ),
    );
  }
}
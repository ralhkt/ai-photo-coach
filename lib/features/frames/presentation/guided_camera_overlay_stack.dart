import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/utils/guidance_text.dart';
import '../../pose/platform/pose_silhouette_native_toast.dart';
import '../../pose/presentation/pose_alignment_coach_toast.dart';
import '../../pose/presentation/pose_skeleton_overlay.dart';
import '../../pose/providers/pose_coaching_provider.dart';
import '../../../models/body_part_labels.dart';
import '../../../models/composition_overlay_type.dart';
import '../../../models/camera_guidance.dart';
import '../../../models/camera_aspect_ratio.dart';
import '../../../models/photo_frame_template.dart';
import '../../camera/presentation/widgets/ios_camera_grid_overlay.dart';
import '../../overlays/presentation/composition_overlay.dart';
import '../../overlays/providers/overlay_providers.dart';
import '../../reference/providers/guided_frame_providers.dart';
import '../../reference/providers/reference_providers.dart';
import '../../reference/providers/reference_skeleton_providers.dart';
import '../../reference/services/frame_generator_service.dart';
import 'photo_frame_overlay.dart';
import 'reference_guided_overlay.dart';

/// Guided-mode overlays isolated from the camera preview repaint path.
class GuidedCameraOverlayStack extends ConsumerStatefulWidget {
  const GuidedCameraOverlayStack({
    super.key,
    required this.guidance,
    required this.imageBytes,
    required this.sourceAspectRatio,
    required this.cameraAspectRatio,
    required this.partLabels,
  });

  final CameraGuidance guidance;
  final Uint8List imageBytes;
  final double sourceAspectRatio;
  final CameraAspectRatio cameraAspectRatio;
  final BodyPartLabels partLabels;

  @override
  ConsumerState<GuidedCameraOverlayStack> createState() =>
      _GuidedCameraOverlayStackState();
}

class _GuidedCameraOverlayStackState
    extends ConsumerState<GuidedCameraOverlayStack> {
  GeneratedFrameSpec? _cachedSpec;
  Size? _cachedViewport;
  CameraAspectRatio? _cachedAspectRatio;

  GeneratedFrameSpec _frameSpecFor(Size viewport) {
    if (_cachedSpec != null &&
        _cachedViewport == viewport &&
        _cachedAspectRatio == widget.cameraAspectRatio) {
      return _cachedSpec!;
    }

    final cropAspectRatio =
        widget.cameraAspectRatio.displayCropRatio(viewport);
    final spec = ref.read(frameGeneratorProvider).generate(
          template: widget.guidance.frameTemplate,
          guidance: widget.guidance,
          viewportSize: viewport,
          viewportIsCropArea: true,
          sourceAspectRatio: widget.sourceAspectRatio,
          targetAspectRatio: cropAspectRatio,
        );
    _cachedSpec = spec;
    _cachedViewport = viewport;
    _cachedAspectRatio = widget.cameraAspectRatio;
    return spec;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        final frameSpec = _frameSpecFor(viewport);

        return RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _CompositionOverlayLayer(),
              _ReferenceGuidedLayer(
                imageBytes: widget.imageBytes,
                frameSpec: frameSpec,
                selectionContour:
                    widget.guidance.subjectSilhouettePoints ?? const [],
              ),
              _FrameOverlayLayer(
                frameSpec: frameSpec,
                template: widget.guidance.frameTemplate,
                partLabels: widget.partLabels,
              ),
              _LiveSkeletonOverlay(
                fallbackSkeletonCount:
                    widget.guidance.subjectPoseSkeleton?.length ?? 0,
              ),
              const PoseSilhouetteNativeToast(),
              const _GuidedCoachToastLayer(),
            ],
          ),
        );
      },
    );
  }
}

class _GuidedCoachToastLayer extends ConsumerWidget {
  const _GuidedCoachToastLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frameVisible = ref.watch(guidedFrameVisibleProvider);
    return PoseAlignmentCoachToast(visible: frameVisible);
  }
}

class _CompositionOverlayLayer extends ConsumerWidget {
  const _CompositionOverlayLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compositionVisible = ref.watch(guidedCompositionVisibleProvider);
    final overlayType = ref.watch(overlayTypeProvider);
    if (compositionVisible && overlayType == CompositionOverlayType.ruleOfThirds) {
      return const IosCameraGridOverlay();
    }
    return CompositionOverlay(type: overlayType, visible: compositionVisible);
  }
}

class _ReferenceGuidedLayer extends ConsumerWidget {
  const _ReferenceGuidedLayer({
    required this.imageBytes,
    required this.frameSpec,
    required this.selectionContour,
  });

  final Uint8List imageBytes;
  final GeneratedFrameSpec frameSpec;
  final List<Offset> selectionContour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ghostVisible = ref.watch(referenceGhostVisibleProvider);
    final frameVisible = ref.watch(guidedFrameVisibleProvider);
    final coachingScore =
        ref.watch(poseCoachingResultProvider.select((r) => r?.poseScore));
    final coaching = ref.read(poseCoachingResultProvider);

    return ReferenceGuidedOverlay(
      imageBytes: imageBytes,
      frameSpec: frameSpec,
      selectionContour: selectionContour,
      visible: frameVisible,
      showGhost: ghostVisible,
      showOutline: selectionContour.length >= 8,
      poseAligned: coaching?.poseMatched ?? false,
      alignmentScore: coachingScore,
    );
  }
}

class _FrameOverlayLayer extends ConsumerWidget {
  const _FrameOverlayLayer({
    required this.frameSpec,
    required this.template,
    required this.partLabels,
  });

  final GeneratedFrameSpec frameSpec;
  final PhotoFrameTemplate template;
  final BodyPartLabels partLabels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frameVisible = ref.watch(guidedFrameVisibleProvider);
    final bodyPartsVisible = ref.watch(bodyPartGuidesVisibleProvider);
    final coachingScore =
        ref.watch(poseCoachingResultProvider.select((r) => r?.poseScore));
    final coaching = ref.read(poseCoachingResultProvider);
    final skeletonStrokeWidth = ref.watch(skeletonStrokeWidthProvider);
    final l10n = AppLocalizations.of(context)!;

    return PhotoFrameOverlay(
      frameSpec: frameSpec,
      templateLabel: frameTemplateLabel(l10n, template),
      visible: frameVisible,
      bodyPartLabels: partLabels,
      showBodyParts: bodyPartsVisible,
      minimalPozeStyle: !bodyPartsVisible,
      poseAligned: coaching?.poseMatched ?? false,
      alignmentScore: coachingScore,
      renderHumanSilhouette: false,
      skeletonStrokeWidth: skeletonStrokeWidth,
    );
  }
}

class _LiveSkeletonOverlay extends ConsumerWidget {
  const _LiveSkeletonOverlay({required this.fallbackSkeletonCount});

  final int fallbackSkeletonCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frameVisible = ref.watch(guidedFrameVisibleProvider);
    if (fallbackSkeletonCount >= 4) {
      return const SizedBox.shrink();
    }
    return PoseSkeletonOverlay(visible: frameVisible);
  }
}
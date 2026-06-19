import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/utils/guidance_text.dart';
import '../../pose/platform/pose_silhouette_native_overlay.dart';
import '../../pose/platform/pose_silhouette_skeleton_builder.dart';
import '../../pose/platform/pose_silhouette_native_toast.dart';
import '../../pose/presentation/pose_alignment_coach_toast.dart';
import '../../pose/presentation/pose_skeleton_overlay.dart';
import '../../pose/providers/pose_coaching_provider.dart';
import '../../pose/providers/pose_silhouette_provider.dart';
import '../../../models/body_part_guides.dart';
import '../../../models/body_part_labels.dart';
import '../../../models/composition_overlay_type.dart';
import '../../../models/camera_guidance.dart';
import '../../camera/providers/camera_interaction_provider.dart';
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
import 'poze_wireframe_style.dart';
import 'reference_ghost_overlay.dart';

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
              _GhostOverlayLayer(
                imageBytes: widget.imageBytes,
                frameSpec: frameSpec,
              ),
              _FrameOverlayLayer(
                frameSpec: frameSpec,
                template: widget.guidance.frameTemplate,
                partLabels: widget.partLabels,
              ),
              _GuidedNativeSilhouetteLayer(frameSpec: frameSpec),
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

class _GuidedNativeSilhouetteLayer extends ConsumerStatefulWidget {
  const _GuidedNativeSilhouetteLayer({required this.frameSpec});

  final GeneratedFrameSpec frameSpec;

  @override
  ConsumerState<_GuidedNativeSilhouetteLayer> createState() =>
      _GuidedNativeSilhouetteLayerState();
}

class _GuidedNativeSilhouetteLayerState
    extends ConsumerState<_GuidedNativeSilhouetteLayer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncNativeOverlay());
  }

  @override
  void didUpdateWidget(covariant _GuidedNativeSilhouetteLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncNativeOverlay());
  }

  void _syncNativeOverlay() {
    if (ref.read(isCameraUiInteractionPausedProvider)) {
      return;
    }

    final supported =
        ref.read(poseSilhouetteNativeSupportedProvider).valueOrNull;
    if (supported != true) {
      return;
    }

    final frameVisible = ref.read(guidedFrameVisibleProvider);
    final coaching = ref.read(poseCoachingResultProvider);
    final points = widget.frameSpec.viewportSilhouettePoints;
    final skeleton = widget.frameSpec.viewportSkeletonSegments;
    final guides = widget.frameSpec.bodyPartGuides;
    final score = coaching?.poseScore ?? 0;
    final enabled = frameVisible && points.length >= 4;
    final renderMode = enabled ? 'silhouette' : 'skeleton';

    final skeletonSegments = skeleton.isNotEmpty
        ? skeleton
        : guides == null
            ? const <List<Offset>>[]
            : _viewportSkeletonFromGuides(guides);

    unawaited(
      ref.read(poseSilhouetteSyncControllerProvider).sync(
            service: ref.read(poseSilhouetteServiceProvider),
            supported: true,
            contour: enabled ? points : null,
            score: score,
            enabled: enabled || skeletonSegments.isNotEmpty,
            renderMode: renderMode,
            skeletonSegments: skeletonSegments,
          ),
    );
  }

  List<List<Offset>> _viewportSkeletonFromGuides(MappedBodyPartGuides guides) {
    final crop = widget.frameSpec.cropRect;
    if (crop.width <= 0 || crop.height <= 0) {
      return const [];
    }

    Offset norm(Offset point) => Offset(
          ((point.dx - crop.left) / crop.width).clamp(0.0, 1.0),
          ((point.dy - crop.top) / crop.height).clamp(0.0, 1.0),
        );

    final imageGuides = BodyPartGuides(
      headOval: guides.headOval,
      shoulders: guides.shoulders,
      torso: guides.torso,
      hips: guides.hips,
    );

    return PoseSilhouetteSkeletonBuilder.fromBodyGuides(imageGuides).map(
      (segment) => [for (final point in segment) norm(point)],
    ).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(poseCoachingResultProvider, (_, __) => _syncNativeOverlay());
    ref.listen(guidedFrameVisibleProvider, (_, __) => _syncNativeOverlay());
    ref.listen(poseSilhouetteNativeSupportedProvider, (previous, next) {
      if (previous?.valueOrNull != true && next.valueOrNull == true) {
        _syncNativeOverlay();
      }
    });

    final frameVisible = ref.watch(guidedFrameVisibleProvider);
    return PoseSilhouetteNativeOverlay(visible: frameVisible);
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

class _GhostOverlayLayer extends ConsumerWidget {
  const _GhostOverlayLayer({
    required this.imageBytes,
    required this.frameSpec,
  });

  final Uint8List imageBytes;
  final GeneratedFrameSpec frameSpec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ghostVisible = ref.watch(referenceGhostVisibleProvider);
    final frameVisible = ref.watch(guidedFrameVisibleProvider);
    return ReferenceGhostOverlay(
      imageBytes: imageBytes,
      frameSpec: frameSpec,
      visible: ghostVisible && frameVisible,
      opacity: PozeWireframeStyle.ghostOpacity,
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
    final nativeSilhouette =
        ref.watch(poseSilhouetteNativeSupportedProvider).valueOrNull ?? false;
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
      renderHumanSilhouette: !nativeSilhouette,
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
    final nativeSilhouette =
        ref.watch(poseSilhouetteNativeSupportedProvider).valueOrNull ?? false;
    if (nativeSilhouette || fallbackSkeletonCount >= 4) {
      return const SizedBox.shrink();
    }
    return PoseSkeletonOverlay(visible: frameVisible);
  }
}
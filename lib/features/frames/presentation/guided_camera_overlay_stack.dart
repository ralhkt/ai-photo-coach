import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/camera_aspect_ratio.dart';
import '../../../models/camera_guidance.dart';
import '../../../models/photo_frame_template.dart';
import '../../../models/composition_overlay_type.dart';
import '../../camera/presentation/widgets/ios_camera_grid_overlay.dart';
import '../../overlays/presentation/composition_overlay.dart';
import '../../overlays/providers/overlay_providers.dart';
import '../../reference/providers/guided_frame_providers.dart';
import '../../reference/providers/reference_providers.dart';
import '../../reference/services/frame_generator_service.dart';
import 'reference_guided_overlay.dart';

/// Guided-mode overlays: ghost reference + subject outline only.
class GuidedCameraOverlayStack extends ConsumerStatefulWidget {
  const GuidedCameraOverlayStack({
    super.key,
    required this.guidance,
    required this.imageBytes,
    required this.sourceAspectRatio,
    required this.cameraAspectRatio,
  });

  final CameraGuidance guidance;
  final Uint8List imageBytes;
  final double sourceAspectRatio;
  final CameraAspectRatio cameraAspectRatio;

  @override
  ConsumerState<GuidedCameraOverlayStack> createState() =>
      _GuidedCameraOverlayStackState();
}

class _GuidedCameraOverlayStackState
    extends ConsumerState<GuidedCameraOverlayStack> {
  GeneratedFrameSpec? _cachedSpec;
  Size? _cachedViewport;
  CameraAspectRatio? _cachedAspectRatio;
  PhotoFrameTemplate? _cachedTemplate;

  GeneratedFrameSpec _frameSpecFor(
    Size viewport,
    PhotoFrameTemplate template,
  ) {
    if (_cachedSpec != null &&
        _cachedViewport == viewport &&
        _cachedAspectRatio == widget.cameraAspectRatio &&
        _cachedTemplate == template) {
      return _cachedSpec!;
    }

    final cropAspectRatio =
        widget.cameraAspectRatio.displayCropRatio(viewport);
    final spec = ref.read(frameGeneratorProvider).generate(
          template: template,
          guidance: widget.guidance,
          viewportSize: viewport,
          viewportIsCropArea: true,
          sourceAspectRatio: widget.sourceAspectRatio,
          targetAspectRatio: cropAspectRatio,
        );
    _cachedSpec = spec;
    _cachedViewport = viewport;
    _cachedAspectRatio = widget.cameraAspectRatio;
    _cachedTemplate = template;
    return spec;
  }

  @override
  Widget build(BuildContext context) {
    final templateOverride = ref.watch(guidedFrameTemplateProvider);
    final template = resolveGuidedFrameTemplate(
      analysisTemplate: widget.guidance.frameTemplate,
      override: templateOverride,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        final frameSpec = _frameSpecFor(viewport, template);
        final contour =
            widget.guidance.subjectSilhouettePoints ?? const <Offset>[];

        return Stack(
          fit: StackFit.expand,
          children: [
            const _CompositionOverlayLayer(),
            _GuidedReferenceOverlay(
              imageBytes: widget.imageBytes,
              frameSpec: frameSpec,
              selectionContour: contour,
            ),
          ],
        );
      },
    );
  }
}

class _CompositionOverlayLayer extends ConsumerWidget {
  const _CompositionOverlayLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compositionVisible = ref.watch(guidedCompositionVisibleProvider);
    if (!compositionVisible) {
      return const SizedBox.shrink();
    }

    final overlayType = ref.watch(overlayTypeProvider);
    if (overlayType == CompositionOverlayType.ruleOfThirds) {
      return const RepaintBoundary(child: IosCameraGridOverlay());
    }
    return RepaintBoundary(
      child: CompositionOverlay(type: overlayType, visible: true),
    );
  }
}

class _GuidedReferenceOverlay extends ConsumerWidget {
  const _GuidedReferenceOverlay({
    required this.imageBytes,
    required this.frameSpec,
    required this.selectionContour,
  });

  final Uint8List imageBytes;
  final GeneratedFrameSpec frameSpec;
  final List<Offset> selectionContour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frameVisible = ref.watch(guidedFrameVisibleProvider);
    if (!frameVisible) {
      return const SizedBox.shrink();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        _GhostReferenceLayer(
          imageBytes: imageBytes,
          frameSpec: frameSpec,
        ),
        _OutlineReferenceLayer(
          imageBytes: imageBytes,
          frameSpec: frameSpec,
          selectionContour: selectionContour,
        ),
      ],
    );
  }
}

class _GhostReferenceLayer extends ConsumerWidget {
  const _GhostReferenceLayer({
    required this.imageBytes,
    required this.frameSpec,
  });

  final Uint8List imageBytes;
  final GeneratedFrameSpec frameSpec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ghostVisible = ref.watch(referenceGhostVisibleProvider);
    if (!ghostVisible) {
      return const SizedBox.shrink();
    }

    final ghostOpacity = ref.watch(referenceGhostOpacityProvider);

    return ReferenceGuidedOverlay(
      imageBytes: imageBytes,
      frameSpec: frameSpec,
      selectionContour: const [],
      visible: true,
      showGhost: true,
      showOutline: false,
      ghostOpacity: ghostOpacity,
    );
  }
}

class _OutlineReferenceLayer extends ConsumerWidget {
  const _OutlineReferenceLayer({
    required this.imageBytes,
    required this.frameSpec,
    required this.selectionContour,
  });

  final Uint8List imageBytes;
  final GeneratedFrameSpec frameSpec;
  final List<Offset> selectionContour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectionContour.length < 8) {
      return const SizedBox.shrink();
    }

    final alignmentPhase = ref.watch(poseCoachingAlignmentPhaseProvider);

    return ReferenceGuidedOverlay(
      imageBytes: imageBytes,
      frameSpec: frameSpec,
      selectionContour: selectionContour,
      visible: true,
      showGhost: false,
      showOutline: true,
      alignmentPhase: alignmentPhase,
    );
  }
}
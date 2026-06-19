import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/camera_aspect_ratio.dart';
import '../../../models/camera_guidance.dart';
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
        final contour = widget.guidance.subjectSilhouettePoints ?? const <Offset>[];

        return RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _CompositionOverlayLayer(),
              _OutlineOverlayLayer(
                imageBytes: widget.imageBytes,
                frameSpec: frameSpec,
                selectionContour: contour,
              ),
            ],
          ),
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
    final overlayType = ref.watch(overlayTypeProvider);
    if (compositionVisible && overlayType == CompositionOverlayType.ruleOfThirds) {
      return const IosCameraGridOverlay();
    }
    return CompositionOverlay(type: overlayType, visible: compositionVisible);
  }
}

class _OutlineOverlayLayer extends ConsumerWidget {
  const _OutlineOverlayLayer({
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
    final ghostVisible = ref.watch(referenceGhostVisibleProvider);
    final alignmentPhase = ref.watch(
      poseCoachingAlignmentPhaseProvider,
    );

    return ReferenceGuidedOverlay(
      imageBytes: imageBytes,
      frameSpec: frameSpec,
      selectionContour: selectionContour,
      visible: frameVisible,
      showGhost: ghostVisible,
      showOutline: selectionContour.length >= 8,
      alignmentPhase: alignmentPhase,
    );
  }
}
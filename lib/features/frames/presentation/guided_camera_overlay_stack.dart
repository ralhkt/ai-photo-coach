import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/utils/guidance_text.dart';
import '../../../core/utils/pose_coaching_hint.dart';
import '../../scene_stabilization/providers/scene_stability_provider.dart';
import '../../../models/body_part_labels.dart';
import '../../../models/camera_guidance.dart';
import '../../../models/camera_aspect_ratio.dart';
import '../../../models/photo_frame_template.dart';
import '../../overlays/presentation/composition_overlay.dart';
import '../../overlays/providers/overlay_providers.dart';
import '../../reference/providers/guided_frame_providers.dart';
import '../../reference/providers/reference_providers.dart';
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
    required this.compositionVisible,
    required this.frameVisible,
    required this.partLabels,
  });

  final CameraGuidance guidance;
  final Uint8List imageBytes;
  final double sourceAspectRatio;
  final CameraAspectRatio cameraAspectRatio;
  final bool compositionVisible;
  final bool frameVisible;
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
              _CompositionOverlayLayer(visible: widget.compositionVisible),
              _GhostOverlayLayer(
                imageBytes: widget.imageBytes,
                frameSpec: frameSpec,
                frameVisible: widget.frameVisible,
              ),
              _FrameOverlayLayer(
                frameSpec: frameSpec,
                template: widget.guidance.frameTemplate,
                frameVisible: widget.frameVisible,
                partLabels: widget.partLabels,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompositionOverlayLayer extends ConsumerWidget {
  const _CompositionOverlayLayer({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayType = ref.watch(overlayTypeProvider);
    return CompositionOverlay(type: overlayType, visible: visible);
  }
}

class _GhostOverlayLayer extends ConsumerWidget {
  const _GhostOverlayLayer({
    required this.imageBytes,
    required this.frameSpec,
    required this.frameVisible,
  });

  final Uint8List imageBytes;
  final GeneratedFrameSpec frameSpec;
  final bool frameVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ghostVisible = ref.watch(referenceGhostVisibleProvider);
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
    required this.frameVisible,
    required this.partLabels,
  });

  final GeneratedFrameSpec frameSpec;
  final PhotoFrameTemplate template;
  final bool frameVisible;
  final BodyPartLabels partLabels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyPartsVisible = ref.watch(bodyPartGuidesVisibleProvider);
    final stability = ref.watch(sceneStabilityProvider);
    final l10n = AppLocalizations.of(context)!;

    return PhotoFrameOverlay(
      frameSpec: frameSpec,
      templateLabel: frameTemplateLabel(l10n, template),
      visible: frameVisible,
      bodyPartLabels: partLabels,
      showBodyParts: bodyPartsVisible,
      minimalPozeStyle: !bodyPartsVisible,
      poseAligned: isPoseAligned(stability),
    );
  }
}
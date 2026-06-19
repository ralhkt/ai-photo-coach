import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import '../../../models/camera_aspect_ratio.dart';
import '../../camera/providers/camera_providers.dart';
import '../../camera/providers/camera_settings_provider.dart';
import '../models/pose_coaching_result.dart';
import '../providers/pose_coaching_provider.dart';
import '../services/alignment_overlay_state.dart';
import 'pose_skeleton_coordinate_mapper.dart';
import 'pose_skeleton_painter.dart';

/// Live detected-pose skeleton aligned to the camera preview crop.
class PoseSkeletonOverlay extends ConsumerWidget {
  const PoseSkeletonOverlay({
    super.key,
    this.visible = true,
    this.rotation = InputImageRotation.rotation0deg,
    this.dashed = false,
  });

  final bool visible;
  final InputImageRotation rotation;
  final bool dashed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    final coaching = ref.watch(poseCoachingResultProvider);
    final landmarks = coaching?.landmarks;
    if (landmarks == null || landmarks.isEmpty) {
      return const SizedBox.shrink();
    }

    final controller = ref.watch(cameraControllerProvider).value;
    final mirrorFront = ref.watch(frontMirrorEnabledProvider);
    final aspectRatio = ref.watch(cameraAspectRatioProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final previewSize = Size(constraints.maxWidth, constraints.maxHeight);
        final cropAspectRatio = aspectRatio.displayCropRatio(previewSize);
        final cropRect = cropAspectRatio == null
            ? (Offset.zero & previewSize)
            : _centeredCrop(previewSize, cropAspectRatio);

        final mapper = PoseSkeletonCoordinateMapper.fromCamera(
          imageSize: Size(
            coaching!.imageWidth.toDouble(),
            coaching.imageHeight.toDouble(),
          ),
          previewSize: previewSize,
          cropRect: cropRect,
          lensDirection: controller?.description.lensDirection ??
              CameraLensDirection.back,
          mirrorFront: mirrorFront,
          rotation: rotation,
        );

        final phase = AlignmentOverlayState.phaseForScore(coaching.poseScore);
        final strokeColor = AlignmentOverlayState.strokeColorForPhase(phase);
        final glowColor = AlignmentOverlayState.glowColorForPhase(phase);

        return IgnorePointer(
          child: CustomPaint(
            size: previewSize,
            painter: PoseSkeletonPainter(
              landmarks: landmarks,
              mapper: mapper,
              strokeColor: strokeColor,
              glowColor: glowColor,
              dashed: dashed || phase == AlignmentOverlayPhase.noMatch,
            ),
          ),
        );
      },
    );
  }

  static Rect _centeredCrop(Size viewport, double aspectRatio) {
    final viewRatio = viewport.width / viewport.height;
    if (viewRatio > aspectRatio) {
      final width = viewport.height * aspectRatio;
      final left = (viewport.width - width) / 2;
      return Rect.fromLTWH(left, 0, width, viewport.height);
    }

    final height = viewport.width / aspectRatio;
    final top = (viewport.height - height) / 2;
    return Rect.fromLTWH(0, top, viewport.width, height);
  }
}
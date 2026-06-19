import 'dart:ui';

import '../../features/frames/services/poze_frame_layout.dart';
import '../../features/reference/services/body_part_guide_service.dart';
import '../../features/reference/services/human_frame_shape_builder.dart';
import '../../models/camera_guidance.dart';
import '../../models/subject_shape_kind.dart';
import 'pose_contour_stabilizer.dart';

/// Ensures live-coaching overlays always receive a clean human-silhouette frame.
class CoachingGuidanceHelper {
  CoachingGuidanceHelper({
    HumanFrameShapeBuilder? shapeBuilder,
    BodyPartGuideService? bodyPartGuideService,
  })  : _shapeBuilder = shapeBuilder ?? HumanFrameShapeBuilder(),
        _bodyPartGuideService =
            bodyPartGuideService ?? BodyPartGuideService();

  final HumanFrameShapeBuilder _shapeBuilder;
  final BodyPartGuideService _bodyPartGuideService;

  CameraGuidance ensureHumanSilhouette(CameraGuidance guidance) {
    if (guidance.subjectShape == SubjectShapeKind.humanSilhouette &&
        guidance.subjectSilhouettePoints != null &&
        guidance.bodyPartGuides != null) {
      return guidance;
    }

    final templatePoints =
        _shapeBuilder.mapTemplateToSubject(guidance.subjectTargetRect);
    final bodyParts = guidance.bodyPartGuides ??
        _bodyPartGuideService.derive(
          subjectRect: guidance.subjectTargetRect,
          silhouettePoints: templatePoints,
        );

    return guidance.copyWith(
      subjectShape: SubjectShapeKind.humanSilhouette,
      subjectSilhouettePoints: templatePoints,
      bodyPartGuides: bodyParts,
    );
  }

  /// Guided camera: keep reference skeleton/silhouette when analysis found a pose.
  CameraGuidance forGuidedOverlay(
    CameraGuidance guidance, {
    PoseContourStabilizer? stabilizer,
  }) {
    final smoothed = stabilizer?.stabilize(guidance) ?? guidance;
    final skeleton = smoothed.subjectPoseSkeleton;
    if (skeleton != null &&
        skeleton.length >= 4 &&
        smoothed.subjectSilhouettePoints != null &&
        smoothed.subjectSilhouettePoints!.isNotEmpty) {
      return smoothed;
    }
    return forPozeOverlay(smoothed);
  }

  /// Poze overlay: seated phone pose, centered in the viewfinder.
  CameraGuidance forPozeOverlay(
    CameraGuidance guidance, {
    PoseContourStabilizer? stabilizer,
  }) {
    final smoothed = stabilizer?.stabilize(guidance) ?? guidance;
    final stabilized = PozeFrameLayout.seatedOverlayRect(
      smoothed.subjectTargetRect,
    );
    final templatePoints = _shapeBuilder
        .seatedPhonePosePoints()
        .map(
          (point) => Offset(
            stabilized.left + point.dx * stabilized.width,
            stabilized.top + point.dy * stabilized.height,
          ),
        )
        .toList();
    final bodyParts = _bodyPartGuideService.derive(
      subjectRect: stabilized,
      silhouettePoints: templatePoints,
    );

    return smoothed.copyWith(
      subjectShape: SubjectShapeKind.humanSilhouette,
      subjectTargetRect: stabilized,
      subjectSilhouettePoints: templatePoints,
      bodyPartGuides: bodyParts,
    );
  }
}
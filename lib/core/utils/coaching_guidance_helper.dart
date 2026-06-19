import 'dart:ui';

import '../../features/frames/services/poze_frame_layout.dart';
import '../../features/reference/services/body_part_guide_service.dart';
import '../../features/reference/services/human_frame_shape_builder.dart';
import '../../models/camera_guidance.dart';
import '../../models/subject_shape_kind.dart';

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

  /// Poze overlay: seated phone pose, centered in the viewfinder.
  CameraGuidance forPozeOverlay(CameraGuidance guidance) {
    final stabilized = PozeFrameLayout.seatedOverlayRect(
      guidance.subjectTargetRect,
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

    return guidance.copyWith(
      subjectShape: SubjectShapeKind.humanSilhouette,
      subjectTargetRect: stabilized,
      subjectSilhouettePoints: templatePoints,
      bodyPartGuides: bodyParts,
    );
  }
}
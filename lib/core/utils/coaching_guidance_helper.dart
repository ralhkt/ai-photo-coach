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
}
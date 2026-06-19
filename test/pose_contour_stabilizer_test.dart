import 'dart:ui';

import 'package:ai_photo_coach/core/utils/pose_contour_stabilizer.dart';
import 'package:ai_photo_coach/models/body_part_guides.dart';
import 'package:ai_photo_coach/models/camera_guidance.dart';
import 'package:ai_photo_coach/models/composition_overlay_type.dart';
import 'package:ai_photo_coach/models/photo_frame_template.dart';
import 'package:ai_photo_coach/models/subject_shape_kind.dart';
import 'package:flutter_test/flutter_test.dart';

CameraGuidance _guidance({
  required Rect subjectRect,
  List<Offset>? silhouette,
}) {
  return CameraGuidance(
    frameTemplate: PhotoFrameTemplate.portraitPost,
    overlayType: CompositionOverlayType.ruleOfThirds,
    subjectTargetRect: subjectRect,
    suggestedZoom: 1,
    angleDegrees: 0,
    exposureEv: 0,
    framingHintKey: 'hintFramingCenter',
    exposureHintKey: 'hintExposureBalanced',
    distanceHintKey: 'hintDistanceGood',
    angleHintKey: 'hintAngleLevel',
    subjectShape: SubjectShapeKind.humanSilhouette,
    subjectSilhouettePoints: silhouette,
    bodyPartGuides: const BodyPartGuides(
      headOval: Rect.fromLTWH(0.38, 0.12, 0.24, 0.18),
      shoulders: Rect.fromLTWH(0.30, 0.28, 0.40, 0.12),
      torso: Rect.fromLTWH(0.34, 0.38, 0.32, 0.28),
      hips: Rect.fromLTWH(0.34, 0.64, 0.32, 0.14),
    ),
  );
}

void main() {
  test('stabilizer damps subject rect jitter across frames', () {
    final stabilizer = PoseContourStabilizer(alpha: 0.3);

    final first = stabilizer.stabilize(
      _guidance(subjectRect: const Rect.fromLTWH(0.2, 0.2, 0.4, 0.6)),
    );
    final second = stabilizer.stabilize(
      _guidance(subjectRect: const Rect.fromLTWH(0.5, 0.2, 0.4, 0.6)),
    );

    expect(second.subjectTargetRect.left, lessThan(0.5));
    expect(second.subjectTargetRect.left, greaterThan(first.subjectTargetRect.left));
  });

  test('reset clears EMA history', () {
    final stabilizer = PoseContourStabilizer(alpha: 0.3);
    stabilizer.stabilize(
      _guidance(
        subjectRect: const Rect.fromLTWH(0.2, 0.2, 0.4, 0.6),
        silhouette: const [Offset(0.4, 0.2), Offset(0.6, 0.8)],
      ),
    );
    stabilizer.reset();

    final fresh = stabilizer.stabilize(
      _guidance(
        subjectRect: const Rect.fromLTWH(0.5, 0.2, 0.4, 0.6),
        silhouette: const [Offset(0.7, 0.2), Offset(0.9, 0.8)],
      ),
    );

    expect(fresh.subjectTargetRect.left, 0.5);
    expect(fresh.subjectSilhouettePoints!.first.dx, 0.7);
  });
}
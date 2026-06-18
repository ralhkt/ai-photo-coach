import 'dart:ui';

import 'package:ai_photo_coach/core/utils/coaching_guidance_helper.dart';
import 'package:ai_photo_coach/models/camera_guidance.dart';
import 'package:ai_photo_coach/models/composition_overlay_type.dart';
import 'package:ai_photo_coach/models/photo_frame_template.dart';
import 'package:ai_photo_coach/models/subject_shape_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ensureHumanSilhouette upgrades rectangle guidance', () {
    const guidance = CameraGuidance(
      frameTemplate: PhotoFrameTemplate.portraitPost,
      overlayType: CompositionOverlayType.ruleOfThirds,
      subjectTargetRect: Rect.fromLTWH(0.3, 0.12, 0.4, 0.72),
      suggestedZoom: 1,
      angleDegrees: 0,
      exposureEv: 0,
      framingHintKey: 'hintFramingCenter',
      exposureHintKey: 'hintExposureBalanced',
      distanceHintKey: 'hintDistanceGood',
      angleHintKey: 'hintAngleLevel',
      subjectShape: SubjectShapeKind.rectangle,
    );

    final upgraded = CoachingGuidanceHelper().ensureHumanSilhouette(guidance);

    expect(upgraded.subjectShape, SubjectShapeKind.humanSilhouette);
    expect(upgraded.subjectSilhouettePoints, isNotNull);
    expect(upgraded.subjectSilhouettePoints!.length, greaterThan(8));
    expect(upgraded.bodyPartGuides, isNotNull);
  });
}
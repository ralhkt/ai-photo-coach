import 'dart:ui';

import 'package:ai_photo_coach/core/utils/coaching_guidance_helper.dart';
import 'package:ai_photo_coach/features/frames/services/poze_frame_layout.dart';
import 'package:ai_photo_coach/models/camera_guidance.dart';
import 'package:ai_photo_coach/models/composition_overlay_type.dart';
import 'package:ai_photo_coach/models/photo_frame_template.dart';
import 'package:ai_photo_coach/models/subject_shape_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical standing rect stays centered', () {
    final rect = PozeFrameLayout.canonicalStandingRect();
    expect(rect.center.dx, closeTo(0.5, 0.01));
    expect(rect.center.dy, greaterThan(0.35));
    expect(rect.center.dy, lessThan(0.55));
  });

  test('stabilizeForOverlay recenters sideways drift', () {
    final drifted = Rect.fromLTWH(0.08, 0.14, 0.38, 0.72);
    final stabilized = PozeFrameLayout.stabilizeForOverlay(drifted);

    expect(stabilized.center.dx, closeTo(0.5, 0.01));
    expect(stabilized.width, greaterThan(0.4));
    expect(stabilized.height, greaterThan(0.6));
  });

  test('seated overlay rect stays centered for sideways drift', () {
    final drifted = Rect.fromLTWH(0.08, 0.20, 0.40, 0.70);
    final seated = PozeFrameLayout.seatedOverlayRect(drifted);

    expect(seated.center.dx, closeTo(0.52, 0.02));
    expect(seated.width, closeTo(0.56, 0.02));
    expect(seated.height, closeTo(0.72, 0.02));
  });

  test('forPozeOverlay produces centered human silhouette', () {
    const guidance = CameraGuidance(
      frameTemplate: PhotoFrameTemplate.portraitPost,
      overlayType: CompositionOverlayType.ruleOfThirds,
      subjectTargetRect: Rect.fromLTWH(0.12, 0.18, 0.34, 0.68),
      suggestedZoom: 1,
      angleDegrees: 0,
      exposureEv: 0,
      framingHintKey: 'hintFramingLeft',
      exposureHintKey: 'hintExposureBalanced',
      distanceHintKey: 'hintDistanceGood',
      angleHintKey: 'hintAngleLevel',
      subjectShape: SubjectShapeKind.rectangle,
    );

    final overlay = CoachingGuidanceHelper().forPozeOverlay(guidance);

    expect(overlay.subjectShape, SubjectShapeKind.humanSilhouette);
    expect(overlay.subjectTargetRect.center.dx, closeTo(0.52, 0.02));
    expect(overlay.subjectSilhouettePoints, isNotNull);
  });
}
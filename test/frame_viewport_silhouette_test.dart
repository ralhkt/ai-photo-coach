import 'dart:ui';

import 'package:ai_photo_coach/features/reference/services/frame_generator_service.dart';
import 'package:ai_photo_coach/models/camera_guidance.dart';
import 'package:ai_photo_coach/models/composition_overlay_type.dart';
import 'package:ai_photo_coach/models/photo_frame_template.dart';
import 'package:ai_photo_coach/models/subject_shape_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('viewport silhouette stays centered after cover-fit remap', () {
    const viewport = Size(390, 844);
    const sourceAspect = 1080 / 1350;
    const targetAspect = 3 / 4;

    final silhouette = [
      for (var i = 0; i < 16; i++)
        Offset(
          0.45 + 0.1 * (i % 4) / 3,
          0.2 + 0.6 * (i ~/ 4) / 3,
        ),
    ];

    final spec = FrameGeneratorService().generate(
      template: PhotoFrameTemplate.portraitPost,
      guidance: CameraGuidance(
        frameTemplate: PhotoFrameTemplate.portraitPost,
        overlayType: CompositionOverlayType.center,
        subjectTargetRect: const Rect.fromLTWH(0.28, 0.12, 0.44, 0.76),
        suggestedZoom: 1,
        angleDegrees: 0,
        exposureEv: 0,
        framingHintKey: 'hintFramingCenter',
        exposureHintKey: 'hintExposureBalanced',
        distanceHintKey: 'hintDistanceGood',
        angleHintKey: 'hintAngleLevel',
        subjectShape: SubjectShapeKind.humanSilhouette,
        subjectSilhouettePoints: silhouette,
      ),
      viewportSize: viewport,
      viewportIsCropArea: true,
      sourceAspectRatio: sourceAspect,
      targetAspectRatio: targetAspect,
    );

    expect(spec.viewportSilhouettePoints.length, greaterThan(8));

    final xs = spec.viewportSilhouettePoints.map((p) => p.dx);
    final ys = spec.viewportSilhouettePoints.map((p) => p.dy);
    final centerX = (xs.reduce((a, b) => a + b) / xs.length);
    final centerY = (ys.reduce((a, b) => a + b) / ys.length);

    expect(centerX, closeTo(0.5, 0.12));
    expect(centerY, inInclusiveRange(0.25, 0.75));
    for (final point in spec.viewportSilhouettePoints) {
      expect(point.dx, inInclusiveRange(0, 1));
      expect(point.dy, inInclusiveRange(0, 1));
    }
  });
}
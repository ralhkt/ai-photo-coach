import 'dart:typed_data';
import 'dart:ui';

import 'package:ai_photo_coach/features/reference/services/frame_generator_service.dart';
import 'package:ai_photo_coach/features/reference/services/image_analyzer_service.dart';
import 'package:ai_photo_coach/features/reference/services/subject_silhouette_service.dart';
import 'package:ai_photo_coach/models/camera_guidance.dart';
import 'package:ai_photo_coach/models/composition_overlay_type.dart';
import 'package:ai_photo_coach/models/photo_frame_template.dart';
import 'package:ai_photo_coach/models/scene_type.dart';
import 'package:ai_photo_coach/models/subject_shape_kind.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('portrait scene produces human silhouette guidance', () async {
    final image = img.Image(width: 800, height: 1000);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final inSubject = x > 300 && x < 500 && y > 120 && y < 900;
        final color = inSubject
            ? img.ColorRgb8(210, 170, 150)
            : img.ColorRgb8(30, 35, 45);
        image.setPixel(x, y, color);
      }
    }

    final bytes = Uint8List.fromList(img.encodeJpg(image));
    final result = await ImageAnalyzerService().analyze(
      bytes,
      userSceneType: SceneType.portrait,
    );

    expect(result.guidance.subjectShape, SubjectShapeKind.humanSilhouette);
    expect(result.guidance.subjectSilhouettePoints, isNotNull);
    expect(result.guidance.subjectSilhouettePoints!.length, greaterThan(8));
    expect(result.guidance.bodyPartGuides, isNotNull);
    expect(result.deepInsights, isNotNull);
    expect(result.deepInsights!.detailedTips, isNotEmpty);
  });

  test('silhouette service extracts contour or template', () {
    final image = img.Image(width: 400, height: 600);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final inSubject = x > 140 && x < 260 && y > 80 && y < 520;
        image.setPixel(
          x,
          y,
          inSubject
              ? img.ColorRgb8(220, 180, 160)
              : img.ColorRgb8(25, 30, 40),
        );
      }
    }

    const subject = Rect.fromLTWH(0.3, 0.1, 0.4, 0.75);
    final points =
        SubjectSilhouetteService().extractPortraitSilhouette(image, subject);

    expect(points, isNotNull);
    expect(points!.length, greaterThan(8));
  });

  test('frame generator maps silhouette path for guided overlay', () {
    final points = [
      const Offset(0.4, 0.1),
      const Offset(0.5, 0.05),
      const Offset(0.6, 0.1),
      const Offset(0.65, 0.3),
      const Offset(0.65, 0.5),
      const Offset(0.55, 0.9),
      const Offset(0.45, 0.9),
      const Offset(0.35, 0.5),
      const Offset(0.35, 0.3),
    ];

    final spec = FrameGeneratorService().generate(
      template: PhotoFrameTemplate.portraitPost,
      guidance: CameraGuidance(
        frameTemplate: PhotoFrameTemplate.portraitPost,
        overlayType: CompositionOverlayType.center,
        subjectTargetRect: const Rect.fromLTWH(0.3, 0.1, 0.4, 0.75),
        suggestedZoom: 1,
        angleDegrees: 0,
        exposureEv: 0,
        framingHintKey: 'hintFramingCenter',
        exposureHintKey: 'hintExposureBalanced',
        distanceHintKey: 'hintDistanceGood',
        angleHintKey: 'hintAngleLevel',
        subjectShape: SubjectShapeKind.humanSilhouette,
        subjectSilhouettePoints: points,
      ),
      viewportSize: const Size(390, 844),
    );

    expect(spec.subjectShape, SubjectShapeKind.humanSilhouette);
    expect(spec.subjectSilhouettePath, isNotNull);
  });
}
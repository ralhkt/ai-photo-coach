import 'dart:typed_data';
import 'dart:ui';

import 'package:ai_photo_coach/features/reference/services/frame_generator_service.dart';
import 'package:ai_photo_coach/features/reference/services/image_analyzer_service.dart';
import 'package:ai_photo_coach/models/scene_type.dart';
import 'package:ai_photo_coach/models/subject_shape_kind.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('auto portrait-like image uses human silhouette without ML Kit', () async {
    final image = img.Image(width: 900, height: 1200);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final inSubject = x > 320 && x < 580 && y > 180 && y < 1020;
        image.setPixel(
          x,
          y,
          inSubject
              ? img.ColorRgb8(215, 175, 155)
              : img.ColorRgb8(28, 32, 42),
        );
      }
    }

    final analysis = await ImageAnalyzerService().analyze(
      Uint8List.fromList(img.encodeJpg(image)),
      userSceneType: SceneType.auto,
    );

    expect(analysis.guidance.subjectShape, SubjectShapeKind.humanSilhouette);
    expect(analysis.guidance.subjectSilhouettePoints, isNotNull);
    expect(analysis.guidance.subjectSilhouettePoints!.length, greaterThan(8));
    expect(analysis.guidance.bodyPartGuides, isNotNull);

    final spec = FrameGeneratorService().generate(
      template: analysis.guidance.frameTemplate,
      guidance: analysis.guidance,
      viewportSize: const Size(390, 844),
    );

    expect(spec.subjectShape, SubjectShapeKind.humanSilhouette);
    expect(spec.subjectSilhouettePath, isNotNull);
  });
}
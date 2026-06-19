import 'dart:typed_data';
import 'dart:ui';

import 'package:ai_photo_coach/features/frames/presentation/photo_frame_painter.dart';
import 'package:ai_photo_coach/features/reference/services/frame_generator_service.dart';
import 'package:ai_photo_coach/features/reference/services/human_frame_shape_builder.dart';
import 'package:ai_photo_coach/features/reference/services/image_analyzer_service.dart';
import 'package:ai_photo_coach/models/scene_type.dart';
import 'package:ai_photo_coach/models/subject_shape_kind.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('human template produces elliptical head with enough contour points', () {
    const subject = Rect.fromLTWH(0.3, 0.1, 0.4, 0.75);
    final builder = HumanFrameShapeBuilder();
    final points = builder.mapTemplateToSubject(subject);
    final headPoints = points
        .where((p) => p.dy <= subject.top + subject.height * 0.20)
        .toList();

    expect(points.length, greaterThan(18));
    expect(headPoints.length, greaterThan(4));

    final headWidth =
        headPoints.map((p) => p.dx).reduce((a, b) => a > b ? a : b) -
            headPoints.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
    final headHeight =
        headPoints.map((p) => p.dy).reduce((a, b) => a > b ? a : b) -
            headPoints.map((p) => p.dy).reduce((a, b) => a < b ? a : b);

    expect(headWidth, greaterThan(headHeight * 0.72));
    expect(headWidth, lessThan(subject.width * 0.5));
  });

  test('portrait guided frame uses human silhouette path not subject rectangle', () async {
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
      userSceneType: SceneType.portrait,
    );

    expect(analysis.guidance.subjectShape, SubjectShapeKind.humanSilhouette);

    final spec = FrameGeneratorService().generate(
      template: analysis.guidance.frameTemplate,
      guidance: analysis.guidance,
      viewportSize: const Size(390, 844),
    );

    expect(spec.subjectSilhouettePath, isNotNull);
    expect(spec.subjectShape, SubjectShapeKind.humanSilhouette);
    expect(spec.bodyPartGuides, isNotNull);

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    PhotoFramePainter(
      frameSpec: spec,
      templateLabel: 'Portrait',
      showBodyParts: true,
    ).paint(canvas, const Size(390, 844));

    expect(recorder.endRecording(), isNotNull);
  });
}
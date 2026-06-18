import 'dart:typed_data';
import 'dart:ui';

import 'package:ai_photo_coach/features/reference/services/frame_generator_service.dart';
import 'package:ai_photo_coach/features/reference/services/image_analyzer_service.dart';
import 'package:ai_photo_coach/features/frames/presentation/photo_frame_painter.dart';
import 'package:ai_photo_coach/models/scene_type.dart';
import 'package:ai_photo_coach/models/subject_shape_kind.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Verifies analysis results are actually consumable by the guided camera overlay.
void main() {
  late Uint8List portraitBytes;

  setUp(() {
    final image = img.Image(width: 1080, height: 1350);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final inSubject = x > 340 && x < 740 && y > 260 && y < 1050;
        image.setPixel(
          x,
          y,
          inSubject
              ? img.ColorRgb8(220, 180, 160)
              : img.ColorRgb8(30, 35, 45),
        );
      }
    }
    portraitBytes = Uint8List.fromList(img.encodeJpg(image));
  });

  test('portrait analysis flows into guided frame with body-part zones', () async {
    final analysis = await ImageAnalyzerService().analyze(
      portraitBytes,
      userSceneType: SceneType.portrait,
    );

    expect(analysis.guidance.subjectShape, SubjectShapeKind.humanSilhouette);
    expect(analysis.guidance.subjectSilhouettePoints, isNotNull);
    expect(analysis.guidance.bodyPartGuides, isNotNull);

    const viewport = Size(390, 844);
    final frame = FrameGeneratorService().generate(
      template: analysis.guidance.frameTemplate,
      guidance: analysis.guidance,
      viewportSize: viewport,
    );

    expect(frame.bodyPartGuides, isNotNull);
    expect(frame.subjectSilhouettePath, isNotNull);
    expect(frame.headCenter, isNotNull);
    expect(frame.cropRect.contains(frame.headCenter!), isTrue);

    final head = frame.bodyPartGuides!.headOval;
    final shoulders = frame.bodyPartGuides!.shoulders;
    final torso = frame.bodyPartGuides!.torso;
    final hips = frame.bodyPartGuides!.hips;

    expect(frame.cropRect.contains(head.center), isTrue);
    expect(frame.cropRect.contains(shoulders.center), isTrue);
    expect(frame.cropRect.contains(torso.center), isTrue);
    expect(frame.cropRect.contains(hips.center), isTrue);

    expect(head.top, lessThan(shoulders.top));
    expect(shoulders.top, lessThan(torso.top));
    expect(torso.top, lessThan(hips.top));

    expect(
      (head.center - frame.headCenter!).distance,
      lessThan(head.width * 0.2),
    );

    expect(analysis.guidance.suggestedZoom, greaterThan(0));
    expect(analysis.guidance.exposureEv, inInclusiveRange(-1.2, 1.2));
  });

  test('photo frame painter renders body-part guides without error', () async {
    final analysis = await ImageAnalyzerService().analyze(
      portraitBytes,
      userSceneType: SceneType.portrait,
    );
    const viewport = Size(390, 844);
    final frame = FrameGeneratorService().generate(
      template: analysis.guidance.frameTemplate,
      guidance: analysis.guidance,
      viewportSize: viewport,
    );

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    PhotoFramePainter(
      frameSpec: frame,
      templateLabel: 'Portrait Post (4:5)',
    ).paint(canvas, viewport);

    expect(recorder.endRecording(), isNotNull);
  });

  test('camera guidance params are ready for applyGuidanceSettings', () async {
    final analysis = await ImageAnalyzerService().analyze(
      portraitBytes,
      userSceneType: SceneType.portrait,
    );

    expect(analysis.guidance.suggestedZoom, isNonZero);
    expect(analysis.guidance.overlayType.name, isNotEmpty);
    expect(analysis.guidance.framingHintKey, startsWith('hint'));
    expect(analysis.guidance.exposureHintKey, startsWith('hint'));
  });
}
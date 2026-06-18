import 'dart:typed_data';
import 'dart:ui';

import 'package:ai_photo_coach/features/reference/services/frame_generator_service.dart';
import 'package:ai_photo_coach/features/reference/services/image_analyzer_service.dart';
import 'package:ai_photo_coach/models/scene_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('crop-area viewport places skeleton inside full visible region', () async {
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
    );
    const cropViewport = Size(390, 520);

    final frame = FrameGeneratorService().generate(
      template: analysis.guidance.frameTemplate,
      guidance: analysis.guidance,
      viewportSize: cropViewport,
      viewportIsCropArea: true,
    );

    expect(frame.cropRect.left, closeTo(0, 0.01));
    expect(frame.cropRect.top, closeTo(0, 0.01));
    expect(frame.cropRect.width, closeTo(cropViewport.width, 0.01));
    expect(frame.cropRect.height, closeTo(cropViewport.height, 0.01));
    expect(frame.cropRect.contains(frame.subjectZone.topLeft), isTrue);
    expect(frame.cropRect.contains(frame.subjectZone.bottomRight), isTrue);
    expect(frame.subjectSilhouettePath, isNotNull);
    expect(
      frame.subjectSilhouettePath!.getBounds().left,
      greaterThanOrEqualTo(0),
    );
    expect(
      frame.subjectSilhouettePath!.getBounds().right,
      lessThanOrEqualTo(cropViewport.width),
    );
  });

  test('mismatched aspect ratios keep centered subject near crop center', () async {
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
    const cropViewport = Size(390, 693);
    const cameraCropRatio = 9 / 16;

    final frame = FrameGeneratorService().generate(
      template: analysis.guidance.frameTemplate,
      guidance: analysis.guidance,
      viewportSize: cropViewport,
      viewportIsCropArea: true,
      sourceAspectRatio: analysis.sourceAspectRatio,
      targetAspectRatio: cameraCropRatio,
    );

    final subjectCenter = frame.subjectZone.center;
    final cropCenter = frame.cropRect.center;
    expect(
      (subjectCenter.dx - cropCenter.dx).abs(),
      lessThan(frame.cropRect.width * 0.2),
    );
    expect(frame.cropRect.contains(frame.subjectZone.topLeft), isTrue);
    expect(frame.cropRect.contains(frame.subjectZone.bottomRight), isTrue);
  });
}
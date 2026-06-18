import 'dart:typed_data';
import 'dart:ui';

import 'package:ai_photo_coach/features/reference/services/frame_generator_service.dart';
import 'package:ai_photo_coach/features/reference/services/image_analyzer_service.dart';
import 'package:ai_photo_coach/models/photo_frame_template.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  group('reference → guided camera pipeline', () {
    late Uint8List portraitBytes;

    setUp(() {
      final image = img.Image(width: 1080, height: 1350);
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final inSubject = x > 340 && x < 740 && y > 260 && y < 1050;
          final color = inSubject
              ? img.ColorRgb8(220, 180, 160)
              : img.ColorRgb8(30, 35, 45);
          image.setPixel(x, y, color);
        }
      }
      portraitBytes = Uint8List.fromList(img.encodeJpg(image));
    });

    test('analyzer produces portrait guidance from uploaded-like image', () async {
      final result = await ImageAnalyzerService().analyze(portraitBytes);

      expect(result.sourceAspectRatio, closeTo(0.8, 0.02));
      expect(result.recommendedFrame, PhotoFrameTemplate.portraitPost);
      expect(
        ['scenePortrait', 'sceneLifestyle'],
        contains(result.sceneTypeKey),
      );
      expect(result.guidance.subjectTargetRect.width, greaterThan(0.1));
      expect(result.guidance.subjectTargetRect.height, greaterThan(0.1));
      expect(result.guidance.framingHintKey, isNotEmpty);
      expect(result.guidance.suggestedZoom, greaterThan(0));
      expect(result.imageBytes, portraitBytes);
    });

    test('frame generator maps subject zone inside crop rect', () async {
      final analysis = await ImageAnalyzerService().analyze(portraitBytes);
      const viewport = Size(390, 844);
      final frame = FrameGeneratorService().generate(
        template: analysis.recommendedFrame,
        guidance: analysis.guidance,
        viewportSize: viewport,
      );

      expect(frame.cropRect.width / frame.cropRect.height, closeTo(0.8, 0.02));
      expect(frame.cropRect.left, greaterThanOrEqualTo(0));
      expect(frame.cropRect.bottom, lessThanOrEqualTo(viewport.height));

      final subject = frame.subjectZone;
      expect(frame.cropRect.contains(subject.topLeft), isTrue);
      expect(frame.cropRect.contains(subject.bottomRight), isTrue);
      expect(subject.width, greaterThan(40));
      expect(subject.height, greaterThan(40));
    });

    test('portrait post frame keeps subject in upper-mid area for centered subject', () async {
      final analysis = await ImageAnalyzerService().analyze(portraitBytes);
      const viewport = Size(390, 844);
      final frame = FrameGeneratorService().generate(
        template: PhotoFrameTemplate.portraitPost,
        guidance: analysis.guidance,
        viewportSize: viewport,
      );

      final subjectCenter = frame.subjectZone.center;
      final cropCenter = frame.cropRect.center;
      expect((subjectCenter.dx - cropCenter.dx).abs(), lessThan(frame.cropRect.width * 0.35));
    });
  });
}
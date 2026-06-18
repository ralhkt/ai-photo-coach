import 'dart:typed_data';

import 'package:ai_photo_coach/features/reference/services/image_analyzer_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('image analyzer returns guidance for generated portrait image', () async {
    final image = img.Image(width: 800, height: 1000);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final inSubject = x > 260 && x < 540 && y > 180 && y < 760;
        final color = inSubject ? img.ColorRgb8(210, 170, 150) : img.ColorRgb8(40, 45, 55);
        image.setPixel(x, y, color);
      }
    }

    final bytes = Uint8List.fromList(img.encodeJpg(image));
    final result = await ImageAnalyzerService().analyze(bytes);

    expect(result.sourceAspectRatio, closeTo(0.8, 0.01));
    expect(result.brightness, greaterThan(0));
    expect(result.guidance.subjectTargetRect.width, greaterThan(0));
    expect(result.recommendedFrame.name, isNotEmpty);
  });
}
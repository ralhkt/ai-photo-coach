import 'dart:typed_data';

import 'package:ai_photo_coach/features/ml/services/heuristic_vision_analyzer.dart';
import 'package:ai_photo_coach/features/reference/services/exif_reader_service.dart';
import 'package:ai_photo_coach/features/reference/services/image_analyzer_service.dart';
import 'package:ai_photo_coach/models/scene_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('upload without ML person uses center placeholder and flags unreliable', () async {
    final image = img.Image(width: 800, height: 1200);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        image.setPixel(x, y, img.ColorRgb8(40, 45, 55));
      }
    }

    final service = ImageAnalyzerService(
      exifReader: const ExifReaderService(),
      visionAnalyzer: HeuristicVisionAnalyzer(),
    );

    final result = await service.analyze(
      Uint8List.fromList(img.encodeJpg(image)),
      userSceneType: SceneType.portrait,
    );

    expect(result.subjectDetectionReliable, isFalse);
    expect(result.guidance.subjectShape.name, 'rectangle');
    expect(result.guidance.subjectTargetRect.center.dx, closeTo(0.5, 0.05));
  });
}
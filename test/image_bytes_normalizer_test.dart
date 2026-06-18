import 'dart:typed_data';

import 'package:ai_photo_coach/core/utils/image_bytes_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('normalizer re-encodes generated jpeg for analysis', () {
    final image = img.Image(width: 640, height: 480);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        image.setPixel(x, y, img.ColorRgb8(120, 80, 60));
      }
    }

    final source = Uint8List.fromList(img.encodeJpg(image));
    final normalized = ImageBytesNormalizer.forAnalysis(source, maxSide: 320);

    expect(normalized, isNotEmpty);
    expect(img.decodeJpg(normalized), isNotNull);
  });
}
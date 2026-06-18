import 'dart:typed_data';

import 'package:ai_photo_coach/features/scene_stabilization/services/phash_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  final service = PHashService();

  Uint8List encodeSolid(int r, int g, int b) {
    final image = img.Image(width: 64, height: 64);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        image.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }
    return Uint8List.fromList(img.encodeJpg(image));
  }

  test('pHash is stable for identical images', () {
    final bytes = encodeSolid(120, 80, 60);
    final first = service.computeFromJpeg(bytes);
    final second = service.computeFromJpeg(bytes);

    expect(first, second);
    expect(service.hammingDistance(first, second), 0);
  });

  test('pHash differs for visually distinct images', () {
    final dark = service.computeFromJpeg(encodeSolid(20, 25, 30));
    final light = service.computeFromJpeg(encodeSolid(220, 210, 200));

    expect(service.hammingDistance(dark, light), greaterThan(0));
  });

  test('hamming distance handles mismatched hash lengths', () {
    expect(service.hammingDistance('1010', '10101'), 5);
  });
}
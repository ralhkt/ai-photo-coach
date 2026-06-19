import 'dart:typed_data';
import 'dart:ui';

import 'package:ai_photo_coach/features/reference/services/portrait_contour_extractor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('extracts closed contour from high-contrast portrait ROI', () {
    final image = img.Image(width: 600, height: 900);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final inSubject = x > 200 && x < 400 && y > 150 && y < 780;
        image.setPixel(
          x,
          y,
          inSubject
              ? img.ColorRgb8(215, 175, 155)
              : img.ColorRgb8(28, 32, 42),
        );
      }
    }

    const subject = Rect.fromLTWH(0.28, 0.14, 0.44, 0.72);
    final points = const PortraitContourExtractor().extract(image, subject);

    expect(points, isNotNull);
    expect(points!.length, greaterThanOrEqualTo(8));
    for (final p in points) {
      expect(p.dx, inInclusiveRange(0, 1));
      expect(p.dy, inInclusiveRange(0, 1));
    }
  });

  test('returns null for tiny subject rect', () {
    final image = img.Image(width: 100, height: 100);
    final bytes = Uint8List.fromList(img.encodeJpg(image));
    final decoded = img.decodeImage(bytes)!;
    final points = const PortraitContourExtractor().extract(
      decoded,
      const Rect.fromLTWH(0.4, 0.4, 0.05, 0.05),
    );
    expect(points, isNull);
  });
}
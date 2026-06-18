import 'dart:ui';

import 'package:ai_photo_coach/core/utils/viewport_letterbox.dart';
import 'package:ai_photo_coach/models/camera_aspect_ratio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('4:3 in portrait uses full width and centered vertical crop', () {
    const viewport = Size(390, 844);
    final ratio = CameraAspectRatio.ratio4x3.displayCropRatio(viewport)!;

    expect(ratio, closeTo(3 / 4, 0.001));

    final crop = ViewportLetterbox.cropRectForRatio(ratio, viewport);

    expect(crop.left, closeTo(0, 0.01));
    expect(crop.width, closeTo(viewport.width, 0.01));
    expect(crop.top, closeTo((viewport.height - crop.height) / 2, 0.01));
    expect(crop.width / crop.height, closeTo(3 / 4, 0.001));
  });

  test('16:9 in portrait is taller than 4:3 crop', () {
    const viewport = Size(390, 844);
    final ratio43 = CameraAspectRatio.ratio4x3.displayCropRatio(viewport)!;
    final ratio169 = CameraAspectRatio.ratio16x9.displayCropRatio(viewport)!;

    final crop43 = ViewportLetterbox.cropRectForRatio(ratio43, viewport);
    final crop169 = ViewportLetterbox.cropRectForRatio(ratio169, viewport);

    expect(crop169.height, greaterThan(crop43.height));
    expect(crop169.top, lessThan(crop43.top));
  });

  test('full mode returns null crop ratio', () {
    const viewport = Size(390, 844);
    expect(CameraAspectRatio.full.displayCropRatio(viewport), isNull);
  });
}
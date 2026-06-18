import 'dart:ui';

import 'package:ai_photo_coach/core/utils/viewport_letterbox.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('16:9 crop is centered in portrait viewport', () {
    const viewport = Size(390, 844);
    const ratio = 16 / 9;

    final crop = ViewportLetterbox.cropRectForRatio(ratio, viewport);

    expect(crop.width / crop.height, closeTo(ratio, 0.001));
    expect(crop.left, closeTo((viewport.width - crop.width) / 2, 0.01));
    expect(crop.top, greaterThan(0));
    expect(crop.bottom, lessThan(viewport.height));
  });

  test('4:5 crop is centered in landscape viewport', () {
    const viewport = Size(844, 390);
    const ratio = 4 / 5;

    final crop = ViewportLetterbox.cropRectForRatio(ratio, viewport);

    expect(crop.width / crop.height, closeTo(ratio, 0.001));
    expect(crop.top, closeTo((viewport.height - crop.height) / 2, 0.01));
    expect(crop.left, greaterThan(0));
  });

  test('cropViewportSize matches crop rect dimensions', () {
    const viewport = Size(390, 844);
    const ratio = 4 / 5;

    final crop = ViewportLetterbox.cropRectForRatio(ratio, viewport);
    final cropViewport = ViewportLetterbox.cropViewportSize(ratio, viewport);

    expect(cropViewport.width, crop.width);
    expect(cropViewport.height, crop.height);
    expect(cropViewport.width / cropViewport.height, closeTo(ratio, 0.001));
  });
}
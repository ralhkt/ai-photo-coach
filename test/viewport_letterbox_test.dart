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

  test('cover-fit mapping keeps image center aligned across aspect ratios', () {
    const sourceCenter = Offset(0.5, 0.5);

    final widerTarget = ViewportLetterbox.mapNormalizedPointCoverFit(
      sourceCenter,
      sourceAspectRatio: 0.8,
      targetAspectRatio: 9 / 16,
    );
    final tallerTarget = ViewportLetterbox.mapNormalizedPointCoverFit(
      sourceCenter,
      sourceAspectRatio: 9 / 16,
      targetAspectRatio: 0.8,
    );

    expect(widerTarget.dx, closeTo(0.5, 0.01));
    expect(widerTarget.dy, closeTo(0.5, 0.01));
    expect(tallerTarget.dx, closeTo(0.5, 0.01));
    expect(tallerTarget.dy, closeTo(0.5, 0.01));
  });

  test('cover-fit dest rect preserves image aspect inside crop', () {
    const crop = Rect.fromLTWH(0, 40, 390, 520);

    final dest = ViewportLetterbox.coverFitDestRect(
      cropRect: crop,
      imageAspectRatio: 0.8,
    );

    expect(dest.width / dest.height, closeTo(0.8, 0.001));
    expect(crop.contains(dest.center), isTrue);
    expect(dest.width, greaterThanOrEqualTo(crop.width));
    expect(dest.height, greaterThanOrEqualTo(crop.height));
  });
}
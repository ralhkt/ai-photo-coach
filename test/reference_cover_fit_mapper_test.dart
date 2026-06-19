import 'dart:ui';

import 'package:ai_photo_coach/core/utils/reference_cover_fit_mapper.dart';
import 'package:ai_photo_coach/core/utils/viewport_letterbox.dart';
import 'package:flutter_test/flutter_test.dart';

Offset _centroid(Iterable<Offset> points) {
  var sx = 0.0;
  var sy = 0.0;
  var count = 0;
  for (final point in points) {
    sx += point.dx;
    sy += point.dy;
    count++;
  }
  return Offset(sx / count, sy / count);
}

void main() {
  test('selection contour maps into the same dest rect as the ghost image', () {
    const cropRect = Rect.fromLTWH(0, 0, 390, 520);
    const imageAspect = 1080 / 1350;
    const selection = [
      Offset(0.4, 0.15),
      Offset(0.6, 0.15),
      Offset(0.65, 0.5),
      Offset(0.55, 0.9),
      Offset(0.45, 0.9),
      Offset(0.35, 0.5),
    ];

    final dest = ReferenceCoverFitMapper.imageDestRect(
      cropRect: cropRect,
      imageAspectRatio: imageAspect,
    );
    final mapped = ReferenceCoverFitMapper.mapContour(selection, dest);
    final centroid = _centroid(mapped);

    expect(dest.contains(centroid), isTrue);
    expect(
      (centroid - dest.center).distance,
      lessThan(dest.shortestSide * 0.2),
    );
  });

  test('mapper matches legacy cover-fit when aspects agree', () {
    const cropRect = Rect.fromLTWH(0, 0, 390, 693);
    const imageAspect = 0.75;
    const targetAspect = 9 / 16;
    const point = Offset(0.42, 0.33);

    final dest = ReferenceCoverFitMapper.imageDestRect(
      cropRect: cropRect,
      imageAspectRatio: imageAspect,
    );
    final mapped = ReferenceCoverFitMapper.mapImageNormalizedPoint(point, dest);

    final legacyNormalized = ViewportLetterbox.mapNormalizedPointCoverFit(
      point,
      sourceAspectRatio: imageAspect,
      targetAspectRatio: targetAspect,
    );
    final legacyMapped = Offset(
      cropRect.left + legacyNormalized.dx * cropRect.width,
      cropRect.top + legacyNormalized.dy * cropRect.height,
    );

    expect(mapped.dx, closeTo(legacyMapped.dx, 0.5));
    expect(mapped.dy, closeTo(legacyMapped.dy, 0.5));
  });
}
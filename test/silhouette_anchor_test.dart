import 'dart:ui';

import 'package:ai_photo_coach/core/utils/silhouette_anchor.dart';
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
  test('alignToSubject recenters drifted contour onto subject rect', () {
    const subject = Rect.fromLTWH(0.3, 0.15, 0.4, 0.7);
    final drifted = [
      for (var i = 0; i < 16; i++)
        Offset(
          0.62 + 0.08 * (i % 4) / 3,
          0.55 + 0.2 * (i ~/ 4) / 3,
        ),
    ];

    final anchored = SilhouetteAnchor.alignToSubject(drifted, subject);
    final delta = (_centroid(anchored) - subject.center).distance;

    expect(delta, lessThan(0.02));
    for (final point in anchored) {
      expect(subject.inflate(0.08).contains(point), isTrue);
    }
  });

  test('alignToSubject leaves already-centered contour unchanged', () {
    const subject = Rect.fromLTWH(0.35, 0.12, 0.3, 0.78);
    final centered = [
      for (var i = 0; i < 12; i++)
        Offset(
          subject.center.dx + 0.04 * (i.isEven ? 1 : -1),
          subject.top + subject.height * (i / 11),
        ),
    ];

    expect(
      SilhouetteAnchor.alignToSubject(centered, subject),
      centered,
    );
  });
}
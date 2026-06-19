import 'dart:ui';

import 'package:ai_photo_coach/core/utils/contour_smoother.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catmullRomPath produces smooth closed bounds', () {
    final points = <Offset>[
      const Offset(0.5, 0.1),
      const Offset(0.35, 0.25),
      const Offset(0.32, 0.5),
      const Offset(0.38, 0.8),
      const Offset(0.5, 0.95),
      const Offset(0.62, 0.8),
      const Offset(0.68, 0.5),
      const Offset(0.65, 0.25),
    ];

    final path = ContourSmoother.catmullRomPath(points);
    final bounds = path.getBounds();

    expect(bounds.width, greaterThan(0.2));
    expect(bounds.height, greaterThan(0.7));
  });

  test('douglasPeucker reduces noisy polyline', () {
    final noisy = <Offset>[
      const Offset(0, 0),
      const Offset(0.01, 0.02),
      const Offset(0.02, 0.01),
      const Offset(0.5, 0.5),
      const Offset(0.98, 0.99),
      const Offset(1, 1),
    ];

    final simplified = ContourSmoother.douglasPeucker(noisy, epsilon: 0.05);

    expect(simplified.length, lessThan(noisy.length));
    expect(simplified.first, const Offset(0, 0));
    expect(simplified.last, const Offset(1, 1));
  });

  test('temporalEma damps sudden jumps', () {
    const previous = [
      Offset(0.5, 0.5),
      Offset(0.52, 0.52),
    ];
    const current = [
      Offset(0.8, 0.8),
      Offset(0.82, 0.82),
    ];

    final smoothed = ContourSmoother.temporalEma(
      current,
      previous: previous,
      alpha: 0.3,
    );

    expect(smoothed.first.dx, lessThan(0.8));
    expect(smoothed.first.dx, greaterThan(0.5));
  });
}
import 'dart:ui';

/// Poze-style contour post-processing: simplify, smooth, and temporally stabilize.
abstract final class ContourSmoother {
  /// Builds a closed Catmull-Rom spline as cubic Bézier segments.
  static Path catmullRomPath(
    List<Offset> points, {
    double tension = 0.5,
    bool closed = true,
  }) {
    final path = Path();
    if (points.isEmpty) {
      return path;
    }
    if (points.length == 1) {
      path.addOval(Rect.fromCenter(center: points.first, width: 1, height: 1));
      return path;
    }
    if (points.length == 2) {
      path.moveTo(points[0].dx, points[0].dy);
      path.lineTo(points[1].dx, points[1].dy);
      return path;
    }
    if (points.length == 3) {
      path.moveTo(points[0].dx, points[0].dy);
      path.quadraticBezierTo(
        points[1].dx,
        points[1].dy,
        points[2].dx,
        points[2].dy,
      );
      if (closed) {
        path.close();
      }
      return path;
    }

    final count = points.length;
    final loop = closed ? count : count - 1;
    path.moveTo(points.first.dx, points.first.dy);

    for (var i = 0; i < loop; i++) {
      final p0 = points[(i - 1 + count) % count];
      final p1 = points[i];
      final p2 = points[(i + 1) % count];
      final p3 = points[(i + 2) % count];

      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) * tension / 6,
        p1.dy + (p2.dy - p0.dy) * tension / 6,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) * tension / 6,
        p2.dy - (p3.dy - p1.dy) * tension / 6,
      );

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    if (closed) {
      path.close();
    }
    return path;
  }

  /// Ramer–Douglas–Peucker polyline simplification.
  static List<Offset> douglasPeucker(
    List<Offset> points, {
    required double epsilon,
  }) {
    if (points.length < 3) {
      return List<Offset>.from(points);
    }

    var maxDistance = 0.0;
    var index = 0;
    final end = points.length - 1;
    final start = points.first;
    final finish = points.last;

    for (var i = 1; i < end; i++) {
      final distance = _perpendicularDistance(points[i], start, finish);
      if (distance > maxDistance) {
        maxDistance = distance;
        index = i;
      }
    }

    if (maxDistance > epsilon) {
      final left = douglasPeucker(points.sublist(0, index + 1), epsilon: epsilon);
      final right = douglasPeucker(points.sublist(index), epsilon: epsilon);
      return [...left.sublist(0, left.length - 1), ...right];
    }

    return [start, finish];
  }

  /// Exponential moving average for control points (same cardinality).
  static List<Offset> temporalEma(
    List<Offset> current, {
    List<Offset>? previous,
    double alpha = 0.32,
  }) {
    if (previous == null || previous.length != current.length) {
      return List<Offset>.from(current);
    }

    final clampedAlpha = alpha.clamp(0.05, 1.0);
    return [
      for (var i = 0; i < current.length; i++)
        Offset(
          previous[i].dx * (1 - clampedAlpha) + current[i].dx * clampedAlpha,
          previous[i].dy * (1 - clampedAlpha) + current[i].dy * clampedAlpha,
        ),
    ];
  }

  static double _perpendicularDistance(Offset point, Offset lineStart, Offset lineEnd) {
    final dx = lineEnd.dx - lineStart.dx;
    final dy = lineEnd.dy - lineStart.dy;
    final lengthSq = dx * dx + dy * dy;
    if (lengthSq == 0) {
      return (point - lineStart).distance;
    }

    final t = ((point.dx - lineStart.dx) * dx + (point.dy - lineStart.dy) * dy) /
        lengthSq;
    final projection = Offset(
      lineStart.dx + t * dx,
      lineStart.dy + t * dy,
    );
    return (point - projection).distance;
  }
}

/// Smoothstep for template warping helpers.
double smoothstep(double edge0, double edge1, double value) {
  final t = ((value - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
  return t * t * (3 - 2 * t);
}

double lerpDouble(double a, double b, double t) => a + (b - a) * t;
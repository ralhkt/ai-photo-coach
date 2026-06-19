import 'dart:math' as math;
import 'dart:ui';

/// Re-aligns extracted silhouette points onto [subjectRect].
///
/// Vision / edge extraction can drift from ML subject boxes; anchoring keeps
/// the guided outline on the ghost reference person.
class SilhouetteAnchor {
  const SilhouetteAnchor._();

  static const double maxUnanchoredCenterOffset = 0.06;

  static List<Offset> alignToSubject(
    List<Offset> points,
    Rect subjectRect, {
    double maxCenterOffset = maxUnanchoredCenterOffset,
    double fitPadding = 0.94,
  }) {
    if (points.length < 4 || subjectRect.isEmpty) {
      return points;
    }

    final bounds = _bounds(points);
    if (bounds.width < 0.02 || bounds.height < 0.02) {
      return points;
    }

    final centerDelta = subjectRect.center - bounds.center;
    if (centerDelta.distance <= maxCenterOffset) {
      return points;
    }

    final scaleX = subjectRect.width / bounds.width * fitPadding;
    final scaleY = subjectRect.height / bounds.height * fitPadding;
    final scale = math.min(scaleX, scaleY).clamp(0.7, 1.4);
    final targetCenter = subjectRect.center;

    return [
      for (final point in points)
        Offset(
          targetCenter.dx + (point.dx - bounds.center.dx) * scale,
          targetCenter.dy + (point.dy - bounds.center.dy) * scale,
        ),
    ];
  }

  static Rect _bounds(List<Offset> points) {
    var minX = double.infinity;
    var maxX = -double.infinity;
    var minY = double.infinity;
    var maxY = -double.infinity;

    for (final point in points) {
      minX = math.min(minX, point.dx);
      maxX = math.max(maxX, point.dx);
      minY = math.min(minY, point.dy);
      maxY = math.max(maxY, point.dy);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}
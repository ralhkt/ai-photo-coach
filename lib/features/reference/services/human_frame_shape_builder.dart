import 'dart:math' as math;
import 'dart:ui';

import '../../../models/body_part_guides.dart';

/// Builds smooth, anatomical human outline points and paths for guided framing.
class HumanFrameShapeBuilder {
  /// Normalized template points (0–1 within subject rect) with elliptical head.
  ///
  /// Points trace one continuous clockwise contour so smoothing never crosses
  /// the body (the previous two-arc layout jumped from neck-left to head-right).
  List<Offset> templatePoints() {
    const headCenter = Offset(0.50, 0.13);
    const headRx = 0.16;
    const headRy = 0.12;

    return [
      ..._ellipseArc(
        center: headCenter,
        rx: headRx,
        ry: headRy,
        startAngle: -math.pi / 2,
        sweepAngle: math.pi,
        steps: 10,
      ),
      const Offset(0.66, 0.26),
      const Offset(0.74, 0.34),
      const Offset(0.76, 0.46),
      const Offset(0.74, 0.58),
      const Offset(0.68, 0.70),
      const Offset(0.62, 0.82),
      const Offset(0.56, 0.94),
      const Offset(0.50, 0.98),
      const Offset(0.44, 0.94),
      const Offset(0.38, 0.82),
      const Offset(0.32, 0.70),
      const Offset(0.26, 0.58),
      const Offset(0.24, 0.46),
      const Offset(0.26, 0.34),
      const Offset(0.34, 0.26),
      ..._ellipseArc(
        center: headCenter,
        rx: headRx,
        ry: headRy,
        startAngle: math.pi / 2,
        sweepAngle: math.pi,
        steps: 10,
      ),
    ];
  }

  List<Offset> mapTemplateToSubject(Rect subjectRect) {
    return templatePoints()
        .map(
          (point) => Offset(
            subjectRect.left + point.dx * subjectRect.width,
            subjectRect.top + point.dy * subjectRect.height,
          ),
        )
        .toList();
  }

  /// Maps the anatomical template onto pose / body-part guides (stable silhouette).
  List<Offset> silhouetteFromBodyGuides(BodyPartGuides guides) {
    return mapTemplateToSubject(_subjectBoundsFromGuides(guides));
  }

  Rect _subjectBoundsFromGuides(BodyPartGuides guides) {
    final left = math.min(
      math.min(guides.shoulders.left, guides.hips.left),
      guides.torso.left,
    );
    final right = math.max(
      math.max(guides.shoulders.right, guides.hips.right),
      guides.torso.right,
    );
    final top = guides.headOval.top - guides.headOval.height * 0.18;
    final bottom = guides.hips.bottom + guides.hips.height * 0.22;
    final padX = (right - left) * 0.06;

    return Rect.fromLTRB(
      (left - padX).clamp(0.0, 1.0),
      top.clamp(0.0, 1.0),
      (right + padX).clamp(0.0, 1.0),
      bottom.clamp(0.0, 1.0),
    );
  }

  Path pointsToSmoothPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) {
      return path;
    }
    if (points.length < 4) {
      path.moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      path.close();
      return path;
    }

    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final mid = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      path.quadraticBezierTo(current.dx, current.dy, mid.dx, mid.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);
    path.close();
    return path;
  }

  List<Offset> _ellipseArc({
    required Offset center,
    required double rx,
    required double ry,
    required double startAngle,
    required double sweepAngle,
    required int steps,
  }) {
    final points = <Offset>[];
    for (var i = 0; i <= steps; i++) {
      final t = startAngle + sweepAngle * (i / steps);
      points.add(
        Offset(
          center.dx + rx * math.cos(t),
          center.dy + ry * math.sin(t),
        ),
      );
    }
    return points;
  }

  Offset _nearestPoint(List<Offset> candidates, Offset target) {
    var best = candidates.first;
    var bestDistance = (best - target).distance;
    for (final candidate in candidates) {
      final distance = (candidate - target).distance;
      if (distance < bestDistance) {
        best = candidate;
        bestDistance = distance;
      }
    }
    return best;
  }

  List<Offset> _dedupe(List<Offset> points) {
    if (points.length < 3) {
      return points;
    }
    final result = <Offset>[points.first];
    for (var i = 1; i < points.length; i++) {
      if ((points[i] - result.last).distance > 0.006) {
        result.add(points[i]);
      }
    }
    return result;
  }
}
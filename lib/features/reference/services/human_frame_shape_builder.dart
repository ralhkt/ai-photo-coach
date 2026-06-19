import 'dart:math' as math;
import 'dart:ui';

import '../../../core/utils/contour_smoother.dart';
import '../../../models/body_part_guides.dart';

/// Builds smooth, anatomical human outline points and paths for guided framing.
class HumanFrameShapeBuilder {
  /// Poze-style seated side profile — phone toward face, legs bent.
  ///
  /// Arms are drawn separately via [PozeWireframeLimbs.seatedPhone].
  List<Offset> seatedPhonePosePoints() {
    const headCenter = Offset(0.58, 0.115);
    const headRx = 0.11;
    const headRy = 0.085;

    return [
      ..._ellipseArc(
        center: headCenter,
        rx: headRx,
        ry: headRy,
        startAngle: -math.pi / 2,
        sweepAngle: math.pi,
        steps: 12,
      ),
      const Offset(0.52, 0.22),
      const Offset(0.48, 0.30),
      const Offset(0.44, 0.42),
      const Offset(0.42, 0.54),
      const Offset(0.40, 0.66),
      const Offset(0.38, 0.78),
      const Offset(0.36, 0.90),
      const Offset(0.40, 0.98),
      const Offset(0.50, 1.00),
      const Offset(0.58, 0.96),
      const Offset(0.62, 0.84),
      const Offset(0.64, 0.70),
      const Offset(0.66, 0.56),
      const Offset(0.68, 0.42),
      const Offset(0.66, 0.30),
      const Offset(0.62, 0.22),
      ..._ellipseArc(
        center: headCenter,
        rx: headRx,
        ry: headRy,
        startAngle: math.pi / 2,
        sweepAngle: math.pi,
        steps: 12,
      ),
    ];
  }

  /// Poze造型-style standing contour (normalized 0–1 within subject rect).
  ///
  /// Slim torso, oval head, slight hip width — arms are drawn separately.
  List<Offset> templatePoints() {
    const headCenter = Offset(0.50, 0.115);
    const headRx = 0.135;
    const headRy = 0.105;

    return [
      ..._ellipseArc(
        center: headCenter,
        rx: headRx,
        ry: headRy,
        startAngle: -math.pi / 2,
        sweepAngle: math.pi,
        steps: 14,
      ),
      const Offset(0.40, 0.24),
      const Offset(0.36, 0.30),
      const Offset(0.34, 0.42),
      const Offset(0.36, 0.54),
      const Offset(0.38, 0.66),
      const Offset(0.40, 0.78),
      const Offset(0.42, 0.90),
      const Offset(0.46, 0.98),
      const Offset(0.50, 1.00),
      const Offset(0.54, 0.98),
      const Offset(0.58, 0.90),
      const Offset(0.60, 0.78),
      const Offset(0.62, 0.66),
      const Offset(0.64, 0.54),
      const Offset(0.66, 0.42),
      const Offset(0.64, 0.30),
      const Offset(0.60, 0.24),
      ..._ellipseArc(
        center: headCenter,
        rx: headRx,
        ry: headRy,
        startAngle: math.pi / 2,
        sweepAngle: math.pi,
        steps: 14,
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

  Path pointsToSmoothPath(List<Offset> points, {double tension = 0.5}) {
    if (points.isEmpty) {
      return Path();
    }
    final cleaned = _dedupe(points);
    return ContourSmoother.catmullRomPath(
      cleaned,
      tension: tension,
      closed: true,
    );
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
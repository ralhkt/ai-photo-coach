import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/body_part_labels.dart';
import '../../../models/subject_shape_kind.dart';
import '../../reference/services/frame_generator_service.dart';
import '../../reference/services/human_frame_shape_builder.dart';

class PhotoFramePainter extends CustomPainter {
  PhotoFramePainter({
    required this.frameSpec,
    required this.templateLabel,
    this.bodyPartLabels,
    this.showBodyParts = true,
  });

  final GeneratedFrameSpec frameSpec;
  final String templateLabel;
  final BodyPartLabels? bodyPartLabels;
  final bool showBodyParts;

  @override
  void paint(Canvas canvas, Size size) {
    final crop = frameSpec.cropRect;
    final subject = frameSpec.subjectZone;
    final isHumanFrame =
        frameSpec.subjectShape == SubjectShapeKind.humanSilhouette;

    final borderPaint = Paint()
      ..color = isHumanFrame
          ? AppTheme.overlayAccent.withOpacity(0.55)
          : AppTheme.overlayAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHumanFrame ? 1.5 : 2;

    canvas.drawRect(crop, borderPaint);
    if (!isHumanFrame) {
      _drawCornerBrackets(canvas, crop, borderPaint);
    }

    if (isHumanFrame) {
      _drawHumanSubjectFrame(canvas, frameSpec, subject);
    } else if (showBodyParts && frameSpec.bodyPartGuides != null) {
      _drawBodyPartGuides(canvas, frameSpec.bodyPartGuides!);
    } else {
      final subjectPaint = Paint()
        ..color = Colors.white.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final dashPath = Path()
        ..addRRect(RRect.fromRectAndRadius(subject, const Radius.circular(12)));
      _drawDashedPath(canvas, dashPath, subjectPaint);
    }

    if (!isHumanFrame && frameSpec.headCenter != null) {
      _drawHeadCrosshair(canvas, frameSpec.headCenter!);
    }

    final labelPainter = TextPainter(
      text: TextSpan(
        text: templateLabel,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        crop.left + 12,
        crop.top + 12,
        labelPainter.width + 16,
        labelPainter.height + 10,
      ),
      const Radius.circular(8),
    );

    canvas.drawRRect(
      labelRect,
      Paint()..color = Colors.black.withOpacity(0.55),
    );
    labelPainter.paint(canvas, Offset(crop.left + 20, crop.top + 17));
  }

  void _drawHumanSubjectFrame(
    Canvas canvas,
    GeneratedFrameSpec spec,
    Rect subject,
  ) {
    final silhouette = spec.subjectSilhouettePath ??
        HumanFrameShapeBuilder().pointsToSmoothPath(
          HumanFrameShapeBuilder().templatePoints().map(
            (point) => Offset(
              subject.left + point.dx * subject.width,
              subject.top + point.dy * subject.height,
            ),
          ).toList(),
        );
    final guides = spec.bodyPartGuides;

    canvas.drawPath(
      silhouette,
      Paint()
        ..color = const Color(0x28FFD60A)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      silhouette,
      Paint()
        ..color = const Color(0xEEFFD60A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeJoin = StrokeJoin.round,
    );

    _drawDashedPath(
      canvas,
      silhouette,
      Paint()
        ..color = Colors.white.withOpacity(0.82)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    if (guides != null) {
      _drawHeadOvalGuide(canvas, guides.headOval);
      if (showBodyParts) {
        _drawAnatomicalGuides(canvas, guides, silhouette);
      }
    }

    if (spec.headCenter != null) {
      _drawHeadCrosshair(canvas, spec.headCenter!);
    }
  }

  void _drawHeadOvalGuide(Canvas canvas, Rect headOval) {
    final headPath = Path()..addOval(headOval);

    canvas.drawPath(
      headPath,
      Paint()
        ..color = const Color(0x33FFD60A)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      headPath,
      Paint()
        ..color = const Color(0xFFFFD60A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8,
    );
    canvas.drawPath(
      headPath,
      Paint()
        ..color = Colors.white.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final labels = bodyPartLabels;
    if (labels != null) {
      _drawPartLabel(canvas, headOval.topLeft, labels.head, const Color(0xFFFFD60A));
    }
  }

  void _drawAnatomicalGuides(
    Canvas canvas,
    MappedBodyPartGuides guides,
    Path silhouette,
  ) {
    final labels = bodyPartLabels;

    _drawShoulderArc(canvas, guides.shoulders, labels?.shoulders ?? 'Shoulders');
    _drawTorsoContours(canvas, guides, silhouette, labels?.torso ?? 'Torso');
    _drawHipArc(canvas, guides.hips, labels?.hips ?? 'Hips');

    _drawConnector(canvas, guides.headOval.center, guides.shoulders.topCenter);
    _drawConnector(canvas, guides.shoulders.bottomCenter, guides.torso.topCenter);
    _drawConnector(canvas, guides.torso.bottomCenter, guides.hips.topCenter);
  }

  void _drawShoulderArc(Canvas canvas, Rect shoulders, String label) {
    final arcRect = Rect.fromCenter(
      center: shoulders.center,
      width: shoulders.width,
      height: shoulders.height * 1.6,
    );
    final path = Path()
      ..addArc(arcRect, math.pi, math.pi);

    _drawDashedPath(
      canvas,
      path,
      Paint()
        ..color = const Color(0xDD80DEEA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _drawPartLabel(canvas, shoulders.topLeft, label, const Color(0xCC80DEEA));
  }

  void _drawTorsoContours(
    Canvas canvas,
    MappedBodyPartGuides guides,
    Path silhouette,
    String label,
  ) {
    final leftPath = _extractSilhouetteSide(
      silhouette,
      guides.torso.top,
      guides.torso.bottom,
      leftSide: true,
    );
    final rightPath = _extractSilhouetteSide(
      silhouette,
      guides.torso.top,
      guides.torso.bottom,
      leftSide: false,
    );

    final stroke = Paint()
      ..color = const Color(0xCCFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    if (leftPath != null) {
      _drawDashedPath(canvas, leftPath, stroke);
    }
    if (rightPath != null) {
      _drawDashedPath(canvas, rightPath, stroke);
    }

    _drawPartLabel(canvas, guides.torso.topLeft, label, const Color(0xCCFFFFFF));
  }

  Path? _extractSilhouetteSide(
    Path silhouette,
    double topY,
    double bottomY, {
    required bool leftSide,
  }) {
    final metrics = silhouette.computeMetrics().toList();
    if (metrics.isEmpty) {
      return null;
    }

    final points = <Offset>[];
    final metric = metrics.first;
    const step = 4.0;
    for (var distance = 0.0; distance < metric.length; distance += step) {
      final tangent = metric.getTangentForOffset(distance);
      if (tangent == null) {
        continue;
      }
      final point = tangent.position;
      if (point.dy < topY || point.dy > bottomY) {
        continue;
      }
      points.add(point);
    }

    if (points.length < 2) {
      return null;
    }

    points.sort((a, b) => a.dy.compareTo(b.dy));
    final grouped = <double, List<Offset>>{};
    for (final point in points) {
      final bucket = (point.dy / 8).round() * 8.0;
      grouped.putIfAbsent(bucket, () => []).add(point);
    }

    final sidePoints = <Offset>[];
    final buckets = grouped.keys.toList()..sort();
    for (final bucket in buckets) {
      final bucketPoints = grouped[bucket]!;
      sidePoints.add(
        leftSide
            ? bucketPoints.reduce(
                (a, b) => a.dx < b.dx ? a : b,
              )
            : bucketPoints.reduce(
                (a, b) => a.dx > b.dx ? a : b,
              ),
      );
    }

    if (sidePoints.length < 2) {
      return null;
    }

    final path = Path()..moveTo(sidePoints.first.dx, sidePoints.first.dy);
    for (var i = 1; i < sidePoints.length; i++) {
      path.lineTo(sidePoints[i].dx, sidePoints[i].dy);
    }
    return path;
  }

  void _drawHipArc(Canvas canvas, Rect hips, String label) {
    final arcRect = Rect.fromCenter(
      center: Offset(hips.center.dx, hips.bottom - hips.height * 0.15),
      width: hips.width,
      height: hips.height * 1.4,
    );
    final path = Path()..addArc(arcRect, 0, math.pi);

    _drawDashedPath(
      canvas,
      path,
      Paint()
        ..color = const Color(0xCCCE93D8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _drawPartLabel(canvas, hips.topLeft, label, const Color(0xCCCE93D8));
  }

  void _drawHeadCrosshair(Canvas canvas, Offset center) {
    const arm = 14.0;
    final paint = Paint()
      ..color = const Color(0xAAFFD60A)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(center.dx - arm, center.dy),
      Offset(center.dx + arm, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - arm),
      Offset(center.dx, center.dy + arm),
      paint,
    );
    canvas.drawCircle(center, 4, paint..style = PaintingStyle.stroke);
  }

  void _drawBodyPartGuides(Canvas canvas, MappedBodyPartGuides guides) {
    final labels = bodyPartLabels;

    _drawPartZone(
      canvas,
      guides.headOval,
      fill: const Color(0x22FFD60A),
      stroke: const Color(0xFFFFD60A),
      strokeWidth: 2.4,
      isOval: true,
      label: labels?.head ?? 'Head',
    );
    _drawPartZone(
      canvas,
      guides.shoulders,
      fill: const Color(0x1880DEEA),
      stroke: const Color(0xCC80DEEA),
      label: labels?.shoulders ?? 'Shoulders',
    );
    _drawPartZone(
      canvas,
      guides.torso,
      fill: const Color(0x18FFFFFF),
      stroke: const Color(0xCCFFFFFF),
      label: labels?.torso ?? 'Torso',
    );
    _drawPartZone(
      canvas,
      guides.hips,
      fill: const Color(0x18CE93D8),
      stroke: const Color(0xCCCE93D8),
      label: labels?.hips ?? 'Hips',
    );

    _drawConnector(canvas, guides.headOval.center, guides.shoulders.topCenter);
    _drawConnector(canvas, guides.shoulders.bottomCenter, guides.torso.topCenter);
    _drawConnector(canvas, guides.torso.bottomCenter, guides.hips.topCenter);
  }

  void _drawConnector(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(from, to, paint);
  }

  void _drawPartZone(
    Canvas canvas,
    Rect rect, {
    required Color fill,
    required Color stroke,
    double strokeWidth = 1.8,
    bool isOval = false,
    required String label,
  }) {
    final path = isOval
        ? (Path()..addOval(rect))
        : (Path()
          ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10))));

    canvas.drawPath(path, Paint()..color = fill);
    _drawDashedPath(
      canvas,
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    _drawPartLabel(canvas, rect.topLeft, label, stroke);
  }

  void _drawPartLabel(Canvas canvas, Offset anchor, String label, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final bg = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        anchor.dx + 4,
        anchor.dy + 2,
        painter.width + 8,
        painter.height + 4,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(bg, Paint()..color = Colors.black.withOpacity(0.55));
    painter.paint(canvas, Offset(anchor.dx + 8, anchor.dy + 4));
  }

  void _drawCornerBrackets(Canvas canvas, Rect rect, Paint paint) {
    const length = 22.0;
    final corners = [
      (rect.topLeft, Offset(1, 1)),
      (rect.topRight, Offset(-1, 1)),
      (rect.bottomLeft, Offset(1, -1)),
      (rect.bottomRight, Offset(-1, -1)),
    ];

    for (final (origin, direction) in corners) {
      canvas.drawLine(
        origin,
        origin + Offset(length * direction.dx, 0),
        paint..strokeWidth = 3,
      );
      canvas.drawLine(
        origin,
        origin + Offset(0, length * direction.dy),
        paint,
      );
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant PhotoFramePainter oldDelegate) {
    return oldDelegate.frameSpec != frameSpec ||
        oldDelegate.templateLabel != templateLabel ||
        oldDelegate.showBodyParts != showBodyParts;
  }
}
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/body_part_labels.dart';
import '../../../models/subject_shape_kind.dart';
import '../../reference/services/frame_generator_service.dart';
import '../../reference/services/human_frame_shape_builder.dart';
import 'poze_wireframe_style.dart';

class PhotoFramePainter extends CustomPainter {
  PhotoFramePainter({
    required this.frameSpec,
    required this.templateLabel,
    this.bodyPartLabels,
    this.showBodyParts = true,
    this.minimalPozeStyle = true,
    this.poseAligned = false,
  });

  final GeneratedFrameSpec frameSpec;
  final String templateLabel;
  final BodyPartLabels? bodyPartLabels;
  final bool showBodyParts;
  final bool minimalPozeStyle;
  final bool poseAligned;

  @override
  void paint(Canvas canvas, Size size) {
    final crop = frameSpec.cropRect;
    final subject = frameSpec.subjectZone;
    final isHumanFrame =
        frameSpec.subjectShape == SubjectShapeKind.humanSilhouette;

    if (!isHumanFrame) {
      final borderPaint = Paint()
        ..color = AppTheme.overlayAccent.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
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

    if (!isHumanFrame && templateLabel.isNotEmpty) {
      _drawTemplateLabel(canvas, crop);
    }
  }

  void _drawTemplateLabel(Canvas canvas, Rect crop) {
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

    if (minimalPozeStyle) {
      _drawPozeMinimalGuide(
        canvas,
        subject: subject,
        silhouette: silhouette,
        headOval: spec.bodyPartGuides?.headOval,
      );
      return;
    }

    final guides = spec.bodyPartGuides;

    canvas.drawPath(
      silhouette,
      Paint()
        ..color = PozeWireframeStyle.glowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = PozeWireframeStyle.glowStrokeWidth
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(
      silhouette,
      Paint()
        ..color = PozeWireframeStyle.lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = PozeWireframeStyle.bodyStrokeWidth
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    _drawPozeLimbs(canvas, subject, PozeWireframeLimbs.standing);

    if (guides != null && showBodyParts) {
      _drawPozeHeadGuide(canvas, guides.headOval);
      _drawAnatomicalGuides(canvas, guides, silhouette);
    }
  }

  void _drawPozeMinimalGuide(
    Canvas canvas, {
    required Rect subject,
    required Path silhouette,
    Rect? headOval,
  }) {
    final strokeColor =
        poseAligned ? PozeWireframeStyle.alignedColor : PozeWireframeStyle.lineColor;

    canvas.drawPath(
      silhouette,
      Paint()
        ..color = PozeWireframeStyle.silhouetteFillColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );

    _drawPozeLimbs(canvas, subject, PozeWireframeLimbs.seatedPhone, strokeColor);

    canvas.drawPath(
      silhouette,
      Paint()
        ..color = PozeWireframeStyle.glowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = PozeWireframeStyle.glowStrokeWidth
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true,
    );

    canvas.drawPath(
      silhouette,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = PozeWireframeStyle.minimalBodyStrokeWidth
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true,
    );

    if (headOval != null) {
      _drawPozeFaceFocusFrame(canvas, headOval, strokeColor);
    }

    _drawPozeViewfinderCrosshair(canvas, subject);
  }

  void _drawPozeFaceFocusFrame(Canvas canvas, Rect headOval, Color strokeColor) {
    final focusRect = Rect.fromCenter(
      center: headOval.center,
      width: headOval.width * 1.08,
      height: headOval.height * 1.12,
    );
    final rounded = RRect.fromRectAndRadius(
      focusRect,
      Radius.circular(focusRect.width * 0.28),
    );
    final path = Path()..addRRect(rounded);

    canvas.drawPath(
      path,
      Paint()
        ..color = PozeWireframeStyle.faceFocusGlowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = PozeWireframeStyle.faceFocusGlowStrokeWidth,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = poseAligned ? strokeColor : PozeWireframeStyle.faceFocusColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = PozeWireframeStyle.faceFocusStrokeWidth,
    );
  }

  void _drawPozeViewfinderCrosshair(Canvas canvas, Rect subject) {
    final center = subject.center;
    const arm = PozeWireframeStyle.crosshairArm;
    final paint = Paint()
      ..color = PozeWireframeStyle.crosshairColor
      ..strokeWidth = 0.5
      ..strokeCap = StrokeCap.round;

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
  }

  void _drawPozeLimbs(
    Canvas canvas,
    Rect subject,
    PozeWireframeLimbs limbs, [
    Color? strokeColor,
  ]) {
    final limbPaint = Paint()
      ..color = strokeColor ?? PozeWireframeStyle.lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = PozeWireframeStyle.limbStrokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    for (final guide in [
      limbs.leftArm,
      limbs.rightArm,
      limbs.leftLeg,
      limbs.rightLeg,
      limbs.spine,
    ]) {
      _drawLimbPolyline(canvas, subject, guide.points, limbPaint);
    }
  }

  void _drawLimbPolyline(
    Canvas canvas,
    Rect subject,
    List<Offset> normalizedPoints,
    Paint paint,
  ) {
    if (normalizedPoints.length < 2) {
      return;
    }

    final path = Path();
    final first = Offset(
      subject.left + normalizedPoints.first.dx * subject.width,
      subject.top + normalizedPoints.first.dy * subject.height,
    );
    path.moveTo(first.dx, first.dy);
    for (var i = 1; i < normalizedPoints.length; i++) {
      final point = Offset(
        subject.left + normalizedPoints[i].dx * subject.width,
        subject.top + normalizedPoints[i].dy * subject.height,
      );
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawPozeHeadGuide(Canvas canvas, Rect headOval) {
    canvas.drawPath(
      Path()..addOval(headOval),
      Paint()
        ..color = PozeWireframeStyle.lineColor.withValues(alpha: 0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = PozeWireframeStyle.limbStrokeWidth,
    );
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
    const arm = PozeWireframeStyle.crosshairArm;
    final paint = Paint()
      ..color = PozeWireframeStyle.crosshairColor
      ..strokeWidth = 0.5
      ..strokeCap = StrokeCap.round;
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
        oldDelegate.showBodyParts != showBodyParts ||
        oldDelegate.minimalPozeStyle != minimalPozeStyle ||
        oldDelegate.poseAligned != poseAligned;
  }
}
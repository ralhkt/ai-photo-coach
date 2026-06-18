import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/camera_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/composition_overlay_type.dart';

class CompositionOverlayPainter extends CustomPainter {
  CompositionOverlayPainter({
    required this.type,
    this.lineColor = AppTheme.overlayLine,
    this.accentColor = AppTheme.overlayAccent,
  });

  final CompositionOverlayType type;
  final Color lineColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = CameraConstants.overlayStrokeWidth
      ..style = PaintingStyle.stroke;

    final accentPaint = Paint()
      ..color = accentColor
      ..strokeWidth = CameraConstants.overlayAccentStrokeWidth
      ..style = PaintingStyle.stroke;

    switch (type) {
      case CompositionOverlayType.ruleOfThirds:
        _drawRuleOfThirds(canvas, size, linePaint, accentPaint);
      case CompositionOverlayType.goldenRatio:
        _drawGoldenRatio(canvas, size, linePaint, accentPaint);
      case CompositionOverlayType.center:
        _drawCenter(canvas, size, linePaint, accentPaint);
      case CompositionOverlayType.diagonal:
        _drawDiagonal(canvas, size, linePaint, accentPaint);
    }
  }

  void _drawRuleOfThirds(
    Canvas canvas,
    Size size,
    Paint linePaint,
    Paint accentPaint,
  ) {
    final thirdW = size.width / 3;
    final thirdH = size.height / 3;

    for (var i = 1; i <= 2; i++) {
      canvas.drawLine(Offset(thirdW * i, 0), Offset(thirdW * i, size.height), linePaint);
      canvas.drawLine(Offset(0, thirdH * i), Offset(size.width, thirdH * i), linePaint);
    }

    _drawPowerPoints(canvas, [
      Offset(thirdW, thirdH),
      Offset(thirdW * 2, thirdH),
      Offset(thirdW, thirdH * 2),
      Offset(thirdW * 2, thirdH * 2),
    ], accentPaint);
  }

  void _drawGoldenRatio(
    Canvas canvas,
    Size size,
    Paint linePaint,
    Paint accentPaint,
  ) {
    final phi = CameraConstants.goldenRatio;
    final minor = size.width / (1 + phi);
    final major = size.width - minor;
    final minorH = size.height / (1 + phi);
    final majorH = size.height - minorH;

    canvas.drawLine(Offset(major, 0), Offset(major, size.height), linePaint);
    canvas.drawLine(Offset(minor, 0), Offset(minor, size.height), linePaint);
    canvas.drawLine(Offset(0, majorH), Offset(size.width, majorH), linePaint);
    canvas.drawLine(Offset(0, minorH), Offset(size.width, minorH), linePaint);

    _drawPowerPoints(canvas, [
      Offset(major, majorH),
      Offset(minor, majorH),
      Offset(major, minorH),
      Offset(minor, minorH),
    ], accentPaint);
  }

  void _drawCenter(
    Canvas canvas,
    Size size,
    Paint linePaint,
    Paint accentPaint,
  ) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);

    final radius = math.min(size.width, size.height) * 0.18;
    canvas.drawCircle(center, radius, linePaint);
    _drawPowerPoints(canvas, [center], accentPaint);
  }

  void _drawDiagonal(
    Canvas canvas,
    Size size,
    Paint linePaint,
    Paint accentPaint,
  ) {
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), linePaint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), linePaint);

    _drawPowerPoints(canvas, [
      Offset(size.width * 0.33, size.height * 0.33),
      Offset(size.width * 0.67, size.height * 0.67),
      Offset(size.width * 0.67, size.height * 0.33),
      Offset(size.width * 0.33, size.height * 0.67),
    ], accentPaint);
  }

  void _drawPowerPoints(Canvas canvas, List<Offset> points, Paint paint) {
    const radius = 4.0;
    for (final point in points) {
      canvas.drawCircle(point, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CompositionOverlayPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.accentColor != accentColor;
  }
}
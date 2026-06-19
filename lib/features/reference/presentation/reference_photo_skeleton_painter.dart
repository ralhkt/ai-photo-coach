import 'dart:ui';

import 'package:flutter/material.dart';

import '../../pose/presentation/pose_skeleton_coordinate_mapper.dart';

/// Draws normalized skeleton segments over a reference photo preview.
class ReferencePhotoSkeletonPainter extends CustomPainter {
  const ReferencePhotoSkeletonPainter({
    required this.segments,
    required this.mapper,
    this.strokeColor,
    this.glowColor,
    this.strokeWidth = 2.2,
    this.drawJoints = true,
  });

  final List<List<Offset>> segments;
  final PoseSkeletonCoordinateMapper mapper;
  final Color? strokeColor;
  final Color? glowColor;
  final double strokeWidth;
  final bool drawJoints;

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) {
      return;
    }

    final lineColor = strokeColor ?? Colors.white.withValues(alpha: 0.92);
    final haloColor = glowColor ?? const Color(0xFFFFD60A).withValues(alpha: 0.5);

    final glowPaint = Paint()
      ..color = haloColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final bonePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final joints = <Offset>{};

    for (final segment in segments) {
      if (segment.length < 2) {
        continue;
      }
      final start = mapper.mapNormalized(segment.first);
      final end = mapper.mapNormalized(segment.last);
      canvas.drawLine(start, end, glowPaint);
      canvas.drawLine(start, end, bonePaint);
      joints.add(start);
      joints.add(end);
    }

    if (!drawJoints) {
      return;
    }

    final jointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (final joint in joints) {
      canvas.drawCircle(joint, strokeWidth * 0.85, jointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ReferencePhotoSkeletonPainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.mapper.imageSize != mapper.imageSize ||
        oldDelegate.mapper.previewSize != mapper.previewSize ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.drawJoints != drawJoints;
  }
}
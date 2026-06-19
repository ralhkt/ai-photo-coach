import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../frames/presentation/poze_wireframe_style.dart';
import '../models/pose_point3d.dart';
import '../services/pose_landmark_utils.dart';
import '../services/pose_skeleton_segment_builder.dart';
import 'pose_skeleton_coordinate_mapper.dart';

/// Draws live ML Kit pose bones aligned to the camera preview.
class PoseSkeletonPainter extends CustomPainter {
  PoseSkeletonPainter({
    required this.landmarks,
    required this.mapper,
    this.minLikelihood = PoseLandmarkUtils.minLikelihood,
    this.strokeColor,
    this.glowColor,
    this.strokeWidth = PozeWireframeStyle.limbStrokeWidth,
    this.drawJoints = true,
    this.dashed = false,
  });

  final Map<PoseLandmarkType, PosePoint3D> landmarks;
  final PoseSkeletonCoordinateMapper mapper;
  final double minLikelihood;
  final Color? strokeColor;
  final Color? glowColor;
  final double strokeWidth;
  final bool drawJoints;
  final bool dashed;

  static const bonePairs = PoseSkeletonSegmentBuilder.bonePairs;

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty) {
      return;
    }

    final lineColor = strokeColor ?? PozeWireframeStyle.lineColor;
    final haloColor = glowColor ?? PozeWireframeStyle.glowColor;

    final glowPaint = Paint()
      ..color = haloColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2.2
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

    for (final (fromType, toType) in bonePairs) {
      final from = landmarks[fromType];
      final to = landmarks[toType];
      if (!_isDrawable(from) || !_isDrawable(to)) {
        continue;
      }

      final start = mapper.mapLandmark(from!);
      final end = mapper.mapLandmark(to!);

      canvas.drawLine(start, end, glowPaint);
      if (dashed) {
        _drawDashedLine(canvas, start, end, bonePaint);
      } else {
        canvas.drawLine(start, end, bonePaint);
      }
    }

    if (!drawJoints) {
      return;
    }

    final jointPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (final point in landmarks.values) {
      if (!_isDrawable(point)) {
        continue;
      }
      final mapped = mapper.mapLandmark(point);
      canvas.drawCircle(mapped, strokeWidth * 0.9, jointPaint);
    }
  }

  bool _isDrawable(PosePoint3D? point) {
    return point != null && point.likelihood >= minLikelihood;
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 7.0;
    const gapLength = 5.0;
    final delta = end - start;
    final distance = delta.distance;
    if (distance <= 0) {
      return;
    }

    final direction = delta / distance;
    var drawn = 0.0;
    while (drawn < distance) {
      final dashEnd = (drawn + dashLength).clamp(0.0, distance);
      canvas.drawLine(
        start + direction * drawn,
        start + direction * dashEnd,
        paint,
      );
      drawn += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant PoseSkeletonPainter oldDelegate) {
    return oldDelegate.landmarks != landmarks ||
        oldDelegate.mapper.imageSize != mapper.imageSize ||
        oldDelegate.mapper.previewSize != mapper.previewSize ||
        oldDelegate.mapper.rotation != mapper.rotation ||
        oldDelegate.mapper.isFrontCamera != mapper.isFrontCamera ||
        oldDelegate.mapper.mirrorFront != mapper.mirrorFront ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.dashed != dashed;
  }
}
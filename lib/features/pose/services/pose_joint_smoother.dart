import 'dart:ui';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/pose_point3d.dart';

/// Temporal EMA smoothing for normalized pose landmarks (reduces jitter).
class PoseJointSmoother {
  PoseJointSmoother({this.baseAlpha = 0.38});

  final double baseAlpha;
  final Map<PoseLandmarkType, Offset> _smoothed = {};

  Map<PoseLandmarkType, PosePoint3D> smooth(
    Map<PoseLandmarkType, PosePoint3D> raw,
  ) {
    final out = <PoseLandmarkType, PosePoint3D>{};

    for (final entry in raw.entries) {
      final type = entry.key;
      final point = entry.value;
      final alpha = baseAlpha * point.likelihood.clamp(0.35, 1.0);
      final prev = _smoothed[type];

      final smoothed = prev == null
          ? Offset(point.x, point.y)
          : Offset(
              prev.dx + alpha * (point.x - prev.dx),
              prev.dy + alpha * (point.y - prev.dy),
            );

      _smoothed[type] = smoothed;
      out[type] = PosePoint3D(
        x: smoothed.dx,
        y: smoothed.dy,
        z: point.z,
        type: type,
        likelihood: point.likelihood,
      );
    }

    return out;
  }

  void reset() {
    _smoothed.clear();
  }
}
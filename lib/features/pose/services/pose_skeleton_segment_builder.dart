import 'dart:ui';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/pose_point3d.dart';
import 'pose_landmark_utils.dart';

/// Builds art-student style bone polylines from ML Kit landmarks (normalized 0–1).
abstract final class PoseSkeletonSegmentBuilder {
  static const bonePairs = <(PoseLandmarkType, PoseLandmarkType)>[
    (PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder),
    (PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow),
    (PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist),
    (PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow),
    (PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist),
    (PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip),
    (PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip),
    (PoseLandmarkType.leftHip, PoseLandmarkType.rightHip),
    (PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee),
    (PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle),
    (PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee),
    (PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle),
    (PoseLandmarkType.nose, PoseLandmarkType.leftEye),
    (PoseLandmarkType.nose, PoseLandmarkType.rightEye),
    (PoseLandmarkType.leftEye, PoseLandmarkType.leftEar),
    (PoseLandmarkType.rightEye, PoseLandmarkType.rightEar),
    (PoseLandmarkType.nose, PoseLandmarkType.leftShoulder),
    (PoseLandmarkType.nose, PoseLandmarkType.rightShoulder),
  ];

  static List<List<Offset>> fromLandmarks(
    Map<PoseLandmarkType, PosePoint3D> landmarks, {
    double minLikelihood = PoseLandmarkUtils.minLikelihood,
  }) {
    if (landmarks.isEmpty) {
      return const [];
    }

    final segments = <List<Offset>>[];
    for (final (fromType, toType) in bonePairs) {
      final from = landmarks[fromType];
      final to = landmarks[toType];
      if (!_isDrawable(from, minLikelihood) || !_isDrawable(to, minLikelihood)) {
        continue;
      }
      segments.add([
        Offset(from!.x, from.y),
        Offset(to!.x, to.y),
      ]);
    }
    return segments;
  }

  static bool _isDrawable(PosePoint3D? point, double minLikelihood) {
    return point != null && point.likelihood >= minLikelihood;
  }
}
import 'dart:math' as math;
import 'dart:ui';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/pose_point3d.dart';

/// Helpers to read ML Kit pose landmarks in normalized image space.
abstract final class PoseLandmarkUtils {
  static const minLikelihood = 0.45;

  /// Canonical order — all 33 ML Kit landmarks.
  static const landmarkOrder = PoseLandmarkType.values;

  static PosePoint3D? landmarkAsPoint3D(
    Pose pose,
    PoseLandmarkType type, {
    required int imageWidth,
    required int imageHeight,
  }) {
    final landmark = pose.landmarks[type];
    if (landmark == null || landmark.likelihood < minLikelihood) {
      return null;
    }
    if (imageWidth <= 0 || imageHeight <= 0) {
      return null;
    }

    return PosePoint3D(
      x: (landmark.x / imageWidth).clamp(0.0, 1.0),
      y: (landmark.y / imageHeight).clamp(0.0, 1.0),
      z: landmark.z,
      type: type,
      likelihood: landmark.likelihood,
    );
  }

  static Map<PoseLandmarkType, PosePoint3D> poseToNormalizedMap(
    Pose pose, {
    required int imageWidth,
    required int imageHeight,
  }) {
    final result = <PoseLandmarkType, PosePoint3D>{};
    for (final type in landmarkOrder) {
      final point = landmarkAsPoint3D(
        pose,
        type,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );
      if (point != null) {
        result[type] = point;
      }
    }
    return result;
  }

  static Map<PoseLandmarkType, PosePoint3D> templateToMap(
    List<PosePoint3D> templatePose,
  ) {
    final result = <PoseLandmarkType, PosePoint3D>{};
    for (final point in templatePose) {
      final type = point.type;
      if (type != null) {
        result[type] = point;
      }
    }
    return result;
  }

  /// Hip-centered, torso-scaled feature vector for cosine matching.
  static List<double> buildFeatureVector(Map<PoseLandmarkType, PosePoint3D> points) {
    final types = landmarkOrder.where(points.containsKey).toList(growable: false);
    return _buildFeatureVectorForTypes(points, types);
  }

  /// Builds aligned user/template vectors using only landmarks present in both maps.
  static ({List<double> user, List<double> template}) buildMatchedFeatureVectors(
    Map<PoseLandmarkType, PosePoint3D> userPoints,
    Map<PoseLandmarkType, PosePoint3D> templatePoints,
  ) {
    final sharedTypes = landmarkOrder
        .where(
          (type) => userPoints.containsKey(type) && templatePoints.containsKey(type),
        )
        .toList(growable: false);

    if (sharedTypes.isEmpty) {
      return (user: <double>[], template: <double>[]);
    }

    return (
      user: _buildFeatureVectorForTypes(userPoints, sharedTypes),
      template: _buildFeatureVectorForTypes(templatePoints, sharedTypes),
    );
  }

  static List<double> _buildFeatureVectorForTypes(
    Map<PoseLandmarkType, PosePoint3D> points,
    List<PoseLandmarkType> types,
  ) {
    final center = _normalizationAnchor(points);
    final scale = _normalizationScale(points);
    final safeScale = scale <= 1e-6 ? 1.0 : scale;

    final vector = <double>[];
    for (final type in types) {
      final point = points[type];
      if (point == null) {
        continue;
      }
      vector
        ..add((point.x - center.dx) / safeScale)
        ..add((point.y - center.dy) / safeScale);
    }
    return vector;
  }

  static Offset _normalizationAnchor(Map<PoseLandmarkType, PosePoint3D> points) {
    final leftHip = points[PoseLandmarkType.leftHip];
    final rightHip = points[PoseLandmarkType.rightHip];
    if (leftHip != null && rightHip != null) {
      return Offset(
        (leftHip.x + rightHip.x) / 2,
        (leftHip.y + rightHip.y) / 2,
      );
    }

    final leftShoulder = points[PoseLandmarkType.leftShoulder];
    final rightShoulder = points[PoseLandmarkType.rightShoulder];
    if (leftShoulder != null && rightShoulder != null) {
      return Offset(
        (leftShoulder.x + rightShoulder.x) / 2,
        (leftShoulder.y + rightShoulder.y) / 2,
      );
    }

    final nose = points[PoseLandmarkType.nose];
    return nose == null ? const Offset(0.5, 0.5) : Offset(nose.x, nose.y);
  }

  static double _normalizationScale(Map<PoseLandmarkType, PosePoint3D> points) {
    final leftShoulder = points[PoseLandmarkType.leftShoulder];
    final rightShoulder = points[PoseLandmarkType.rightShoulder];
    final leftHip = points[PoseLandmarkType.leftHip];
    final rightHip = points[PoseLandmarkType.rightHip];

    if (leftShoulder != null &&
        rightShoulder != null &&
        leftHip != null &&
        rightHip != null) {
      final shoulder = Offset(
        (leftShoulder.x + rightShoulder.x) / 2,
        (leftShoulder.y + rightShoulder.y) / 2,
      );
      final hip = Offset(
        (leftHip.x + rightHip.x) / 2,
        (leftHip.y + rightHip.y) / 2,
      );
      return (shoulder - hip).distance.clamp(0.08, 1.0);
    }

    if (leftShoulder != null && rightShoulder != null) {
      return (rightShoulder.x - leftShoulder.x).abs().clamp(0.08, 1.0);
    }

    return 0.25;
  }

  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty || a.length != b.length) {
      return 0;
    }

    var dot = 0.0;
    var normA = 0.0;
    var normB = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA <= 1e-9 || normB <= 1e-9) {
      return 0;
    }
    return (dot / (math.sqrt(normA) * math.sqrt(normB))).clamp(-1.0, 1.0);
  }
}
import 'dart:math' as math;
import 'dart:ui';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/pose_point3d.dart';
import 'pose_landmark_utils.dart';

/// 2D similarity (Kabsch) alignment for rotation-aware pose matching.
abstract final class PoseAligner {
  static const minSharedLandmarks = 4;
  static const maxRmsForPerfect = 0.04;
  static const maxRmsForZero = 0.28;

  /// Returns 0–100 similarity score after aligning template → user.
  static int similarityScore(
    Map<PoseLandmarkType, PosePoint3D> userPoints,
    Map<PoseLandmarkType, PosePoint3D> templatePoints,
  ) {
    final shared = PoseLandmarkUtils.landmarkOrder
        .where(
          (type) => userPoints.containsKey(type) && templatePoints.containsKey(type),
        )
        .toList(growable: false);

    if (shared.length < minSharedLandmarks) {
      return _fallbackCosineScore(userPoints, templatePoints);
    }

    final userOffsets = <Offset>[];
    final templateOffsets = <Offset>[];
    final weights = <double>[];

    for (final type in shared) {
      final user = userPoints[type]!;
      final template = templatePoints[type]!;
      userOffsets.add(Offset(user.x, user.y));
      templateOffsets.add(Offset(template.x, template.y));
      weights.add(
        math.min(user.likelihood, template.likelihood).clamp(0.2, 1.0),
      );
    }

    final rms = _weightedAlignedRms(templateOffsets, userOffsets, weights);
    return _rmsToScore(rms);
  }

  static double _weightedAlignedRms(
    List<Offset> templatePoints,
    List<Offset> userPoints,
    List<double> weights,
  ) {
    final tCentroid = _weightedCentroid(templatePoints, weights);
    final uCentroid = _weightedCentroid(userPoints, weights);

    final tCentered = templatePoints
        .map((p) => p - tCentroid)
        .toList(growable: false);
    final uCentered =
        userPoints.map((p) => p - uCentroid).toList(growable: false);

    var numerator = 0.0;
    var denominator = 0.0;
    for (var i = 0; i < weights.length; i++) {
      final w = weights[i];
      final t = tCentered[i];
      final u = uCentered[i];
      numerator += w * (t.dx * u.dy - t.dy * u.dx);
      denominator += w * (t.dx * u.dx + t.dy * u.dy);
    }

    final theta = math.atan2(numerator, denominator);

    var scaleNumerator = 0.0;
    var scaleDenominator = 0.0;
    for (var i = 0; i < weights.length; i++) {
      final w = weights[i];
      final rotated = _rotate(tCentered[i], theta);
      final u = uCentered[i];
      scaleNumerator += w * (rotated.dx * u.dx + rotated.dy * u.dy);
      scaleDenominator += w * (rotated.dx * rotated.dx + rotated.dy * rotated.dy);
    }

    final scale = scaleDenominator <= 1e-9 ? 1.0 : scaleNumerator / scaleDenominator;

    var weightedSq = 0.0;
    var weightSum = 0.0;
    for (var i = 0; i < weights.length; i++) {
      final aligned = _rotate(tCentered[i], theta) * scale + uCentroid;
      final err = (aligned - userPoints[i]).distance;
      weightedSq += weights[i] * err * err;
      weightSum += weights[i];
    }

    if (weightSum <= 1e-9) {
      return maxRmsForZero;
    }
    return math.sqrt(weightedSq / weightSum);
  }

  static Offset _weightedCentroid(List<Offset> points, List<double> weights) {
    var sumX = 0.0;
    var sumY = 0.0;
    var sumW = 0.0;
    for (var i = 0; i < points.length; i++) {
      sumX += points[i].dx * weights[i];
      sumY += points[i].dy * weights[i];
      sumW += weights[i];
    }
    if (sumW <= 1e-9) {
      return Offset.zero;
    }
    return Offset(sumX / sumW, sumY / sumW);
  }

  static Offset _rotate(Offset point, double theta) {
    final cosT = math.cos(theta);
    final sinT = math.sin(theta);
    return Offset(
      point.dx * cosT - point.dy * sinT,
      point.dx * sinT + point.dy * cosT,
    );
  }

  static int _rmsToScore(double rms) {
    if (rms <= maxRmsForPerfect) {
      return 100;
    }
    if (rms >= maxRmsForZero) {
      return 0;
    }
    final t = (rms - maxRmsForPerfect) / (maxRmsForZero - maxRmsForPerfect);
    return ((1 - t) * 100).round().clamp(0, 100);
  }

  static int _fallbackCosineScore(
    Map<PoseLandmarkType, PosePoint3D> userPoints,
    Map<PoseLandmarkType, PosePoint3D> templatePoints,
  ) {
    final matched = PoseLandmarkUtils.buildMatchedFeatureVectors(
      userPoints,
      templatePoints,
    );
    if (matched.user.isEmpty) {
      return 0;
    }
    final cosine = PoseLandmarkUtils.cosineSimilarity(matched.user, matched.template);
    return ((cosine + 1) / 2 * 100).round().clamp(0, 100);
  }
}
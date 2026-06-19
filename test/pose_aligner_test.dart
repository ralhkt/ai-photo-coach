import 'dart:math' as math;
import 'dart:ui';

import 'package:ai_photo_coach/features/pose/models/pose_point3d.dart';
import 'package:ai_photo_coach/features/pose/services/pose_aligner.dart';
import 'package:ai_photo_coach/features/pose/services/pose_landmark_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

void main() {
  test('identical poses score near 100', () {
    final template = _standingPose();
    final user = Map<PoseLandmarkType, PosePoint3D>.from(template);

    final score = PoseAligner.similarityScore(user, template);
    expect(score, greaterThan(95));
  });

  test('rotated pose scores higher than independent cosine would', () {
    final template = _standingPose();
    final rotated = <PoseLandmarkType, PosePoint3D>{};
    const pivot = Offset(0.5, 0.5);
    const theta = 0.35;

    for (final entry in template.entries) {
      final point = entry.value;
      final dx = point.x - pivot.dx;
      final dy = point.y - pivot.dy;
      final cosT = math.cos(theta);
      final sinT = math.sin(theta);
      rotated[entry.key] = PosePoint3D(
        x: pivot.dx + dx * cosT - dy * sinT,
        y: pivot.dy + dx * sinT + dy * cosT,
        z: point.z,
        type: entry.key,
        likelihood: point.likelihood,
      );
    }

    final alignedScore = PoseAligner.similarityScore(rotated, template);
    final matched = PoseLandmarkUtils.buildMatchedFeatureVectors(rotated, template);
    final cosineScore = ((PoseLandmarkUtils.cosineSimilarity(
              matched.user,
              matched.template,
            ) +
            1) /
        2 *
        100)
        .round();

    expect(alignedScore, greaterThan(cosineScore));
  });
}

Map<PoseLandmarkType, PosePoint3D> _standingPose() {
  return {
    PoseLandmarkType.nose: const PosePoint3D(x: 0.5, y: 0.18, z: 0, type: PoseLandmarkType.nose, likelihood: 0.95),
    PoseLandmarkType.leftShoulder: const PosePoint3D(x: 0.42, y: 0.28, z: 0, type: PoseLandmarkType.leftShoulder, likelihood: 0.9),
    PoseLandmarkType.rightShoulder: const PosePoint3D(x: 0.58, y: 0.28, z: 0, type: PoseLandmarkType.rightShoulder, likelihood: 0.9),
    PoseLandmarkType.leftHip: const PosePoint3D(x: 0.44, y: 0.48, z: 0, type: PoseLandmarkType.leftHip, likelihood: 0.88),
    PoseLandmarkType.rightHip: const PosePoint3D(x: 0.56, y: 0.48, z: 0, type: PoseLandmarkType.rightHip, likelihood: 0.88),
    PoseLandmarkType.leftKnee: const PosePoint3D(x: 0.43, y: 0.68, z: 0, type: PoseLandmarkType.leftKnee, likelihood: 0.85),
    PoseLandmarkType.rightKnee: const PosePoint3D(x: 0.57, y: 0.68, z: 0, type: PoseLandmarkType.rightKnee, likelihood: 0.85),
  };
}
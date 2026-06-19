import 'dart:ui';

import 'package:ai_photo_coach/features/reference/services/pose_aware_silhouette_builder.dart';
import 'package:ai_photo_coach/models/body_part_guides.dart';
import 'package:ai_photo_coach/features/pose/models/pose_point3d.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

void main() {
  const builder = PoseAwareSilhouetteBuilder();

  test('builds closed contour from standing pose landmarks', () {
    final landmarks = <PosePoint3D>[
      const PosePoint3D(type: PoseLandmarkType.nose, x: 0.50, y: 0.18, z: 0),
      const PosePoint3D(type: PoseLandmarkType.leftEar, x: 0.44, y: 0.16, z: 0),
      const PosePoint3D(type: PoseLandmarkType.rightEar, x: 0.56, y: 0.16, z: 0),
      const PosePoint3D(type: PoseLandmarkType.leftShoulder, x: 0.40, y: 0.28, z: 0),
      const PosePoint3D(type: PoseLandmarkType.rightShoulder, x: 0.60, y: 0.28, z: 0),
      const PosePoint3D(type: PoseLandmarkType.leftHip, x: 0.42, y: 0.52, z: 0),
      const PosePoint3D(type: PoseLandmarkType.rightHip, x: 0.58, y: 0.52, z: 0),
      const PosePoint3D(type: PoseLandmarkType.leftKnee, x: 0.40, y: 0.72, z: 0),
      const PosePoint3D(type: PoseLandmarkType.rightKnee, x: 0.56, y: 0.70, z: 0),
      const PosePoint3D(type: PoseLandmarkType.leftAnkle, x: 0.38, y: 0.92, z: 0),
      const PosePoint3D(type: PoseLandmarkType.rightAnkle, x: 0.54, y: 0.90, z: 0),
    ];

    expect(builder.canBuild(landmarks), isTrue);
    final points = builder.build(landmarks);

    expect(points.length, greaterThan(16));
    for (final point in points) {
      expect(point.dx, inInclusiveRange(0, 1));
      expect(point.dy, inInclusiveRange(0, 1));
    }

    final minY = points.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((p) => p.dy).reduce((a, b) => a > b ? a : b);
    expect(maxY - minY, greaterThan(0.45));
  });

  test('buildFromBodyGuides produces anatomical envelope', () {
    const guides = BodyPartGuides(
      headOval: Rect.fromLTWH(0.38, 0.12, 0.24, 0.18),
      shoulders: Rect.fromLTWH(0.30, 0.28, 0.40, 0.12),
      torso: Rect.fromLTWH(0.34, 0.38, 0.32, 0.28),
      hips: Rect.fromLTWH(0.34, 0.64, 0.32, 0.14),
    );

    final points = builder.buildFromBodyGuides(guides);
    expect(points.length, greaterThan(12));
    final minY = points.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((p) => p.dy).reduce((a, b) => a > b ? a : b);
    expect(minY, lessThan(guides.headOval.center.dy));
    expect(maxY, greaterThan(guides.hips.bottom - 0.05));
  });
}
import 'package:ai_photo_coach/features/pose/services/pose_landmark_utils.dart';
import 'package:ai_photo_coach/features/pose/services/pose_skeleton_segment_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'package:ai_photo_coach/features/pose/models/pose_point3d.dart';

void main() {
  test('segment builder connects shoulders and arms when landmarks exist', () {
    final landmarks = {
      PoseLandmarkType.leftShoulder: const PosePoint3D(x: 0.4, y: 0.3),
      PoseLandmarkType.rightShoulder: const PosePoint3D(x: 0.6, y: 0.3),
      PoseLandmarkType.leftElbow: const PosePoint3D(x: 0.35, y: 0.45),
      PoseLandmarkType.leftWrist: const PosePoint3D(x: 0.32, y: 0.55),
    };

    final segments = PoseSkeletonSegmentBuilder.fromLandmarks(landmarks);

    expect(segments, isNotEmpty);
    expect(
      segments.any(
        (segment) =>
            segment.length == 2 &&
            segment.first.dx == 0.4 &&
            segment.last.dx == 0.35,
      ),
      isTrue,
    );
  });

  test('imputed wrists extend skeleton for partial detections', () {
    final raw = {
      PoseLandmarkType.leftShoulder: const PosePoint3D(x: 0.4, y: 0.3),
      PoseLandmarkType.leftElbow: const PosePoint3D(x: 0.35, y: 0.45),
    };
    final imputed = PoseLandmarkUtils.imputeMissingLandmarks(raw);
    final segments = PoseSkeletonSegmentBuilder.fromLandmarks(imputed);
    expect(segments.length, greaterThanOrEqualTo(1));
  });
}
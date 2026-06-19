import 'package:ai_photo_coach/features/pose/services/pose_joint_smoother.dart';
import 'package:ai_photo_coach/features/pose/models/pose_point3d.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

void main() {
  test('smooths jitter toward running average', () {
    final smoother = PoseJointSmoother(baseAlpha: 0.5);
    final type = PoseLandmarkType.nose;

    final first = smoother.smooth({
      type: const PosePoint3D(
        x: 0.5,
        y: 0.3,
        z: 0,
        type: PoseLandmarkType.nose,
        likelihood: 0.9,
      ),
    });

    final second = smoother.smooth({
      type: const PosePoint3D(
        x: 0.56,
        y: 0.3,
        z: 0,
        type: PoseLandmarkType.nose,
        likelihood: 0.9,
      ),
    });

    expect(first[type]!.x, 0.5);
    expect(second[type]!.x, greaterThan(0.5));
    expect(second[type]!.x, lessThan(0.56));
  });
}
import 'package:ai_photo_coach/features/pose/services/subject_pose_tracker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

void main() {
  test('selects largest centered pose on first frame', () {
    final tracker = SubjectPoseTracker();
    final centerPose = _poseAt(0.5, 0.45, scale: 1.0);
    final edgePose = _poseAt(0.15, 0.45, scale: 0.55);

    final selected = tracker.selectPrimary(
      [edgePose, centerPose],
      imageWidth: 1000,
      imageHeight: 1200,
    );

    expect(selected, centerPose);
  });

  test('tracks same subject via IoU across frames', () {
    final tracker = SubjectPoseTracker();
    final subjectA = _poseAt(0.5, 0.45, scale: 1.0);
    final subjectB = _poseAt(0.2, 0.45, scale: 0.9);

    tracker.selectPrimary([subjectA], imageWidth: 1000, imageHeight: 1200);
    final second = tracker.selectPrimary(
      [subjectB, subjectA],
      imageWidth: 1000,
      imageHeight: 1200,
    );

    expect(second, subjectA);
  });
}

Pose _poseAt(double cx, double cy, {required double scale}) {
  const imageWidth = 1000;
  const imageHeight = 1200;
  final landmarks = <PoseLandmarkType, PoseLandmark>{};
  final halfW = 0.08 * scale;

  void add(PoseLandmarkType type, double nx, double ny) {
    landmarks[type] = PoseLandmark(
      type: type,
      x: nx * imageWidth,
      y: ny * imageHeight,
      z: 0,
      likelihood: 0.9,
    );
  }

  add(PoseLandmarkType.nose, cx, cy - 0.18 * scale);
  add(PoseLandmarkType.leftShoulder, cx - halfW, cy - 0.08 * scale);
  add(PoseLandmarkType.rightShoulder, cx + halfW, cy - 0.08 * scale);
  add(PoseLandmarkType.leftHip, cx - halfW * 0.85, cy + 0.12 * scale);
  add(PoseLandmarkType.rightHip, cx + halfW * 0.85, cy + 0.12 * scale);
  add(PoseLandmarkType.leftKnee, cx - halfW * 0.7, cy + 0.28 * scale);
  add(PoseLandmarkType.rightKnee, cx + halfW * 0.7, cy + 0.28 * scale);

  return Pose(landmarks: landmarks);
}
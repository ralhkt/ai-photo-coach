import 'dart:math' as math;
import 'dart:ui';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../models/body_part_guides.dart';

/// Maps ML Kit pose landmarks into normalized body-part guides.
class PoseBodyGuideMapper {
  BodyPartGuides? fromPose(Pose pose, {required int imageWidth, required int imageHeight}) {
    if (imageWidth <= 0 || imageHeight <= 0) {
      return null;
    }

    final nose = _landmark(pose, PoseLandmarkType.nose);
    final leftEar = _landmark(pose, PoseLandmarkType.leftEar);
    final rightEar = _landmark(pose, PoseLandmarkType.rightEar);
    final leftShoulder = _landmark(pose, PoseLandmarkType.leftShoulder);
    final rightShoulder = _landmark(pose, PoseLandmarkType.rightShoulder);
    final leftHip = _landmark(pose, PoseLandmarkType.leftHip);
    final rightHip = _landmark(pose, PoseLandmarkType.rightHip);
    final leftKnee = _landmark(pose, PoseLandmarkType.leftKnee);
    final rightKnee = _landmark(pose, PoseLandmarkType.rightKnee);

    if (nose == null || leftShoulder == null || rightShoulder == null) {
      return null;
    }

    final nosePoint = _normalize(nose, imageWidth, imageHeight);
    final shoulderLeft = _normalize(leftShoulder, imageWidth, imageHeight);
    final shoulderRight = _normalize(rightShoulder, imageWidth, imageHeight);

    final earLeft = leftEar != null
        ? _normalize(leftEar, imageWidth, imageHeight)
        : Offset(nosePoint.dx - 0.06, nosePoint.dy);
    final earRight = rightEar != null
        ? _normalize(rightEar, imageWidth, imageHeight)
        : Offset(nosePoint.dx + 0.06, nosePoint.dy);

    final headWidth = (earRight.dx - earLeft.dx).abs().clamp(0.08, 0.45);
    final headHeight = headWidth * 1.18;
    final headCenterX = (earLeft.dx + earRight.dx) / 2;
    final headTop = math.min(earLeft.dy, earRight.dy) - headHeight * 0.35;

    final shoulderY = (shoulderLeft.dy + shoulderRight.dy) / 2;
    final shoulderWidth = (shoulderRight.dx - shoulderLeft.dx).abs().clamp(0.12, 0.75);

    final hipLeft = leftHip != null
        ? _normalize(leftHip, imageWidth, imageHeight)
        : Offset(shoulderLeft.dx + 0.02, shoulderY + 0.22);
    final hipRight = rightHip != null
        ? _normalize(rightHip, imageWidth, imageHeight)
        : Offset(shoulderRight.dx - 0.02, shoulderY + 0.22);

    final hipY = (hipLeft.dy + hipRight.dy) / 2;
    final kneeY = leftKnee != null && rightKnee != null
        ? (_normalize(leftKnee, imageWidth, imageHeight).dy +
                _normalize(rightKnee, imageWidth, imageHeight).dy) /
            2
        : hipY + 0.18;

    return BodyPartGuides(
      headOval: Rect.fromCenter(
        center: Offset(headCenterX, headTop + headHeight / 2),
        width: headWidth,
        height: headHeight,
      ),
      shoulders: Rect.fromCenter(
        center: Offset((shoulderLeft.dx + shoulderRight.dx) / 2, shoulderY),
        width: shoulderWidth,
        height: headHeight * 0.42,
      ),
      torso: Rect.fromLTRB(
        math.min(shoulderLeft.dx, hipLeft.dx),
        shoulderY + headHeight * 0.08,
        math.max(shoulderRight.dx, hipRight.dx),
        hipY,
      ),
      hips: Rect.fromCenter(
        center: Offset((hipLeft.dx + hipRight.dx) / 2, hipY),
        width: (hipRight.dx - hipLeft.dx).abs().clamp(0.14, 0.62),
        height: (kneeY - hipY).clamp(0.08, 0.28),
      ),
    );
  }

  Rect? subjectRectFromPose(Pose pose, {required int imageWidth, required int imageHeight}) {
    final guides = fromPose(pose, imageWidth: imageWidth, imageHeight: imageHeight);
    if (guides == null) {
      return null;
    }

    final top = guides.headOval.top - guides.headOval.height * 0.08;
    final bottom = guides.hips.bottom + guides.hips.height * 0.35;
    final left = math.min(guides.shoulders.left, guides.hips.left) - 0.03;
    final right = math.max(guides.shoulders.right, guides.hips.right) + 0.03;

    return Rect.fromLTRB(
      left.clamp(0.0, 1.0),
      top.clamp(0.0, 1.0),
      right.clamp(0.0, 1.0),
      bottom.clamp(0.0, 1.0),
    );
  }

  PoseLandmark? _landmark(Pose pose, PoseLandmarkType type) {
    final landmark = pose.landmarks[type];
    if (landmark == null || landmark.likelihood < 0.45) {
      return null;
    }
    return landmark;
  }

  Offset _normalize(PoseLandmark landmark, int width, int height) {
    return Offset(
      (landmark.x / width).clamp(0.0, 1.0),
      (landmark.y / height).clamp(0.0, 1.0),
    );
  }
}
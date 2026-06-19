import 'dart:math' as math;
import 'dart:ui';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../pose/models/pose_point3d.dart';
import '../../pose/services/pose_landmark_utils.dart';
import '../../../models/body_part_guides.dart';

/// Builds a pose-fitted body outline from ML Kit landmarks (reference / upload).
///
/// Used when person segmentation is unavailable or too coarse — follows the
/// detected posture instead of a generic standing template.
class PoseAwareSilhouetteBuilder {
  const PoseAwareSilhouetteBuilder();

  bool canBuild(List<PosePoint3D> landmarks) {
    final map = _toMap(landmarks);
    return map.containsKey(PoseLandmarkType.nose) &&
        map.containsKey(PoseLandmarkType.leftShoulder) &&
        map.containsKey(PoseLandmarkType.rightShoulder);
  }

  List<Offset> build(List<PosePoint3D> landmarks) {
    final map = PoseLandmarkUtils.imputeMissingLandmarks(_toMap(landmarks));
    final nose = map[PoseLandmarkType.nose]!;
    final leftShoulder = map[PoseLandmarkType.leftShoulder]!;
    final rightShoulder = map[PoseLandmarkType.rightShoulder]!;

    final centerX = (leftShoulder.x + rightShoulder.x) / 2;
    final shoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    final shoulderSpan = (rightShoulder.x - leftShoulder.x).abs().clamp(0.08, 0.9);

    final leftEar = map[PoseLandmarkType.leftEar];
    final rightEar = map[PoseLandmarkType.rightEar];
    final headWidth = leftEar != null && rightEar != null
        ? (rightEar.x - leftEar.x).abs().clamp(shoulderSpan * 0.35, shoulderSpan * 0.95)
        : shoulderSpan * 0.55;
    final headHeight = headWidth * 1.15;
    final headTop = math.min(
      leftEar?.y ?? nose.y,
      rightEar?.y ?? nose.y,
    ) - headHeight * 0.42;
    final headCenter = Offset(centerX, headTop + headHeight * 0.5);

    final leftHip = _offset(map[PoseLandmarkType.leftHip], fallback: Offset(
      leftShoulder.x,
      shoulderY + shoulderSpan * 0.55,
    ));
    final rightHip = _offset(map[PoseLandmarkType.rightHip], fallback: Offset(
      rightShoulder.x,
      shoulderY + shoulderSpan * 0.55,
    ));
    final hipY = (leftHip.dy + rightHip.dy) / 2;

    final leftKnee = _offset(map[PoseLandmarkType.leftKnee], fallback: Offset(
      leftHip.dx,
      hipY + shoulderSpan * 0.45,
    ));
    final rightKnee = _offset(map[PoseLandmarkType.rightKnee], fallback: Offset(
      rightHip.dx,
      hipY + shoulderSpan * 0.45,
    ));

    final leftAnkle = _offset(map[PoseLandmarkType.leftAnkle], fallback: Offset(
      leftKnee.dx,
      leftKnee.dy + shoulderSpan * 0.42,
    ));
    final rightAnkle = _offset(map[PoseLandmarkType.rightAnkle], fallback: Offset(
      rightKnee.dx,
      rightKnee.dy + shoulderSpan * 0.42,
    ));

    final leftElbow = map[PoseLandmarkType.leftElbow];
    final rightElbow = map[PoseLandmarkType.rightElbow];
    final leftWrist = map[PoseLandmarkType.leftWrist];
    final rightWrist = map[PoseLandmarkType.rightWrist];

    final pad = shoulderSpan * 0.08;

    Offset outward(Offset joint, Offset center, double extra) {
      final dir = joint - center;
      if (dir.distance < 1e-6) {
        return joint;
      }
      return joint + Offset.fromDirection(dir.direction, extra);
    }

    final bodyCenter = Offset(centerX, (shoulderY + hipY) / 2);

    final leftShoulderOut = outward(
      Offset(leftShoulder.x, leftShoulder.y),
      bodyCenter,
      pad * 1.2,
    );
    final rightShoulderOut = outward(
      Offset(rightShoulder.x, rightShoulder.y),
      bodyCenter,
      pad * 1.2,
    );
    final leftHipOut = outward(leftHip, bodyCenter, pad);
    final rightHipOut = outward(rightHip, bodyCenter, pad);
    final leftKneeOut = outward(leftKnee, Offset(centerX, leftKnee.dy), pad * 0.55);
    final rightKneeOut = outward(rightKnee, Offset(centerX, rightKnee.dy), pad * 0.55);
    final leftAnkleOut = outward(leftAnkle, Offset(centerX, leftAnkle.dy), pad * 0.35);
    final rightAnkleOut = outward(rightAnkle, Offset(centerX, rightAnkle.dy), pad * 0.35);

    final headTopArc = _ellipseArc(
      center: headCenter,
      rx: headWidth / 2,
      ry: headHeight / 2,
      startAngle: math.pi,
      sweepAngle: math.pi,
      steps: 14,
    );

    final leftElbowOut = leftElbow != null
        ? outward(Offset(leftElbow.x, leftElbow.y), bodyCenter, pad * 0.85)
        : Offset(leftShoulderOut.dx - pad * 0.25, shoulderY + shoulderSpan * 0.16);
    final rightElbowOut = rightElbow != null
        ? outward(Offset(rightElbow.x, rightElbow.y), bodyCenter, pad * 0.85)
        : Offset(rightShoulderOut.dx + pad * 0.25, shoulderY + shoulderSpan * 0.16);
    final leftWristOut = leftWrist != null
        ? outward(Offset(leftWrist.x, leftWrist.y), bodyCenter, pad * 0.45)
        : leftElbowOut;
    final rightWristOut = rightWrist != null
        ? outward(Offset(rightWrist.x, rightWrist.y), bodyCenter, pad * 0.45)
        : rightElbowOut;

    final footCenter = Offset(
      (leftAnkleOut.dx + rightAnkleOut.dx) / 2,
      math.max(leftAnkleOut.dy, rightAnkleOut.dy),
    );

    final points = <Offset>[
      ...headTopArc,
      rightShoulderOut,
      rightElbowOut,
      rightWristOut,
      rightHipOut,
      rightKneeOut,
      rightAnkleOut,
      footCenter,
      leftAnkleOut,
      leftKneeOut,
      leftHipOut,
      leftWristOut,
      leftElbowOut,
      leftShoulderOut,
    ];

    return _clampPoints(_dedupe(points));
  }

  /// Pose landmarks mapped into [guides] bounds when only body guides exist.
  List<Offset> buildFromBodyGuides(BodyPartGuides guides) {
    final centerX = guides.headOval.center.dx;
    final top = guides.headOval.top;
    final bottom = guides.hips.bottom;
    final height = (bottom - top).clamp(0.2, 1.0);

    final leftShoulder = Offset(guides.shoulders.left, guides.shoulders.center.dy);
    final rightShoulder = Offset(guides.shoulders.right, guides.shoulders.center.dy);
    final leftHip = Offset(guides.hips.left, guides.hips.center.dy);
    final rightHip = Offset(guides.hips.right, guides.hips.center.dy);
    final padX = guides.shoulders.width * 0.06;

    final headArc = _ellipseArc(
      center: guides.headOval.center,
      rx: guides.headOval.width / 2,
      ry: guides.headOval.height / 2,
      startAngle: math.pi,
      sweepAngle: math.pi,
      steps: 12,
    );

    final leftSide = <Offset>[
      Offset(leftShoulder.dx - padX, leftShoulder.dy),
      Offset(leftHip.dx - padX * 0.5, (leftShoulder.dy + leftHip.dy) / 2),
      Offset(leftHip.dx - padX, leftHip.dy),
      Offset(leftHip.dx - padX * 0.7, bottom - height * 0.06),
      Offset((leftHip.dx + rightHip.dx) / 2, bottom),
    ];

    final rightSide = <Offset>[
      Offset((leftHip.dx + rightHip.dx) / 2, bottom),
      Offset(rightHip.dx + padX * 0.7, bottom - height * 0.06),
      Offset(rightHip.dx + padX, rightHip.dy),
      Offset(rightHip.dx + padX * 0.5, (rightShoulder.dy + rightHip.dy) / 2),
      Offset(rightShoulder.dx + padX, rightShoulder.dy),
    ];

    return _clampPoints(_dedupe([...headArc, ...leftSide, ...rightSide]));
  }

  Map<PoseLandmarkType, PosePoint3D> _toMap(List<PosePoint3D> landmarks) {
    final result = <PoseLandmarkType, PosePoint3D>{};
    for (final point in landmarks) {
      final type = point.type;
      if (type != null) {
        result[type] = point;
      }
    }
    return result;
  }

  Offset _offset(PosePoint3D? point, {required Offset fallback}) {
    if (point == null) {
      return fallback;
    }
    return Offset(point.x, point.y);
  }

  List<Offset> _ellipseArc({
    required Offset center,
    required double rx,
    required double ry,
    required double startAngle,
    required double sweepAngle,
    required int steps,
  }) {
    final points = <Offset>[];
    for (var i = 0; i <= steps; i++) {
      final t = startAngle + sweepAngle * (i / steps);
      points.add(
        Offset(
          center.dx + rx * math.cos(t),
          center.dy + ry * math.sin(t),
        ),
      );
    }
    return points;
  }

  List<Offset> _dedupe(List<Offset> points) {
    if (points.length < 3) {
      return points;
    }
    final result = <Offset>[points.first];
    for (var i = 1; i < points.length; i++) {
      if ((points[i] - result.last).distance > 0.004) {
        result.add(points[i]);
      }
    }
    return result;
  }

  List<Offset> _clampPoints(List<Offset> points) {
    return points
        .map(
          (point) => Offset(
            point.dx.clamp(0.0, 1.0),
            point.dy.clamp(0.0, 1.0),
          ),
        )
        .toList(growable: false);
  }
}
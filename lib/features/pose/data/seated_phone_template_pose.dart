import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/pose_point3d.dart';

/// Reference skeleton for Poze-style seated phone selfie (normalized coords).
///
/// Curated for MVP cosine matching — replace with measured influencer samples later.
const seatedPhoneTemplatePose = <PosePoint3D>[
  PosePoint3D(type: PoseLandmarkType.nose, x: 0.56, y: 0.22, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftEar, x: 0.52, y: 0.20, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightEar, x: 0.60, y: 0.20, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftShoulder, x: 0.48, y: 0.30, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightShoulder, x: 0.58, y: 0.28, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftElbow, x: 0.44, y: 0.40, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightElbow, x: 0.50, y: 0.26, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftWrist, x: 0.42, y: 0.50, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightWrist, x: 0.36, y: 0.22, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftHip, x: 0.46, y: 0.56, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightHip, x: 0.54, y: 0.56, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftKnee, x: 0.40, y: 0.72, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightKnee, x: 0.52, y: 0.70, z: 0),
  PosePoint3D(type: PoseLandmarkType.leftAnkle, x: 0.38, y: 0.92, z: 0),
  PosePoint3D(type: PoseLandmarkType.rightAnkle, x: 0.50, y: 0.90, z: 0),
];
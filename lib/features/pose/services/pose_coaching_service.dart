import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/pose_coaching_result.dart';
import '../models/trendy_photo_template.dart';
import 'adaptive_coaching_scheduler.dart';
import 'pose_coaching_coordinator.dart';
import 'pose_joint_smoother.dart';
import 'pose_landmark_utils.dart';
import 'pose_preview_frame_prep.dart';
import 'subject_pose_tracker.dart';

/// Runs ML Kit pose inference on preview snapshots and aesthetic coaching math.
class PoseCoachingService {
  PoseCoachingService({
    PoseDetector? poseDetector,
    PoseCoachingCoordinator? coordinator,
    SubjectPoseTracker? subjectTracker,
    PoseJointSmoother? jointSmoother,
    AdaptiveCoachingScheduler? captureScheduler,
  })  : _poseDetector = poseDetector ??
            PoseDetector(
              options: PoseDetectorOptions(
                model: PoseDetectionModel.base,
                mode: PoseDetectionMode.single,
              ),
            ),
        _coordinator = coordinator ?? PoseCoachingCoordinator(),
        _subjectTracker = subjectTracker ?? SubjectPoseTracker(),
        _jointSmoother = jointSmoother ?? PoseJointSmoother(),
        _captureScheduler = captureScheduler ?? AdaptiveCoachingScheduler();

  final PoseDetector _poseDetector;
  final PoseCoachingCoordinator _coordinator;
  final SubjectPoseTracker _subjectTracker;
  final PoseJointSmoother _jointSmoother;
  final AdaptiveCoachingScheduler _captureScheduler;

  PoseCoachingCoordinator get coordinator => _coordinator;
  AdaptiveCoachingScheduler get captureScheduler => _captureScheduler;

  /// Whether ML inference should run (coordinator throttle gate).
  bool shouldRunInference({DateTime? now}) {
    return !_coordinator.isThrottled(now ?? DateTime.now());
  }

  /// Runs pose inference on a live BGRA camera frame (iOS image stream path).
  Future<PoseCoachingResult?> evaluateCameraImage({
    required CameraImage image,
    required int sensorOrientation,
    required double rollAngle,
    TrendyPhotoTemplate? trendyTemplate,
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();
    if (_coordinator.isThrottled(timestamp)) {
      return null;
    }

    final input = _inputFromCameraImage(image, sensorOrientation);
    return _evaluateInputImage(
      input: input,
      imageWidth: image.width,
      imageHeight: image.height,
      rollAngle: rollAngle,
      trendyTemplate: trendyTemplate,
      timestamp: timestamp,
    );
  }

  /// Decodes a JPEG/PNG preview frame, detects pose, returns throttled coaching.
  Future<PoseCoachingResult?> evaluatePreviewFrame({
    required Uint8List bytes,
    required double rollAngle,
    TrendyPhotoTemplate? trendyTemplate,
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();
    if (_coordinator.isThrottled(timestamp)) {
      return null;
    }

    final prepared = await compute(preparePreviewFrameForMl, bytes);
    if (prepared == null) {
      return null;
    }

    final input = InputImage.fromBytes(
      bytes: prepared.bgraBytes,
      metadata: InputImageMetadata(
        size: Size(prepared.width.toDouble(), prepared.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.bgra8888,
        bytesPerRow: prepared.width * 4,
      ),
    );
    return _evaluateInputImage(
      input: input,
      imageWidth: prepared.width,
      imageHeight: prepared.height,
      rollAngle: rollAngle,
      trendyTemplate: trendyTemplate,
      timestamp: timestamp,
    );
  }

  InputImage _inputFromCameraImage(CameraImage image, int sensorOrientation) {
    final plane = image.planes.first;
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation) ??
        InputImageRotation.rotation0deg;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.bgra8888,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Future<PoseCoachingResult?> _evaluateInputImage({
    required InputImage input,
    required int imageWidth,
    required int imageHeight,
    required double rollAngle,
    TrendyPhotoTemplate? trendyTemplate,
    required DateTime timestamp,
  }) async {
    List<Pose> poses;
    try {
      poses = await _poseDetector.processImage(input);
    } catch (error, stackTrace) {
      debugPrint('PoseCoachingService: pose detection failed: $error');
      debugPrint('$stackTrace');
      poses = const [];
    }

    final pose = _subjectTracker.selectPrimary(
      poses,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );

    if (pose == null) {
      return _coordinator.evaluateFromPose(
        pose: null,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        rollAngle: rollAngle,
        trendyTemplate: trendyTemplate,
        now: timestamp,
      );
    }

    final rawLandmarks = PoseLandmarkUtils.poseToNormalizedMap(
      pose,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
    final smoothed = _jointSmoother.smooth(rawLandmarks);

    return _coordinator.evaluateFromLandmarks(
      landmarks: smoothed,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      rollAngle: rollAngle,
      trendyTemplate: trendyTemplate,
      now: timestamp,
    );
  }

  void reset() {
    _coordinator.reset();
    _subjectTracker.reset();
    _jointSmoother.reset();
    _captureScheduler.reset();
  }

  Future<void> dispose() async {
    await _poseDetector.close();
  }
}
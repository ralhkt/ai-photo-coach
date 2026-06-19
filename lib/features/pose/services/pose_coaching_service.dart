import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image/image.dart' as img;

import '../../ml/services/ml_input_image_helper.dart';
import '../models/pose_coaching_result.dart';
import '../models/trendy_photo_template.dart';
import 'adaptive_coaching_scheduler.dart';
import 'pose_coaching_coordinator.dart';
import 'pose_joint_smoother.dart';
import 'pose_landmark_utils.dart';
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
                mode: PoseDetectionMode.stream,
              ),
            ),
        _coordinator = coordinator ?? PoseCoachingCoordinator(),
        _subjectTracker = subjectTracker ?? SubjectPoseTracker(),
        _jointSmoother = jointSmoother ?? PoseJointSmoother(),
        _captureScheduler = captureScheduler ?? AdaptiveCoachingScheduler();

  static const maxMlSide = 480;

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

    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return null;
    }

    final mlImage = _downscaleForMl(decoded);
    final input = MlInputImageHelper.fromDecodedImage(mlImage);

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
      imageWidth: mlImage.width,
      imageHeight: mlImage.height,
    );

    if (pose == null) {
      return _coordinator.evaluateFromPose(
        pose: null,
        imageWidth: mlImage.width,
        imageHeight: mlImage.height,
        rollAngle: rollAngle,
        trendyTemplate: trendyTemplate,
        now: timestamp,
      );
    }

    final rawLandmarks = PoseLandmarkUtils.poseToNormalizedMap(
      pose,
      imageWidth: mlImage.width,
      imageHeight: mlImage.height,
    );
    final smoothed = _jointSmoother.smooth(rawLandmarks);

    return _coordinator.evaluateFromLandmarks(
      landmarks: smoothed,
      imageWidth: mlImage.width,
      imageHeight: mlImage.height,
      rollAngle: rollAngle,
      trendyTemplate: trendyTemplate,
      now: timestamp,
    );
  }

  img.Image _downscaleForMl(img.Image image) {
    final longest = image.width > image.height ? image.width : image.height;
    if (longest <= maxMlSide) {
      return image;
    }

    final scale = maxMlSide / longest;
    return img.copyResize(
      image,
      width: (image.width * scale).round(),
      height: (image.height * scale).round(),
      interpolation: img.Interpolation.average,
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
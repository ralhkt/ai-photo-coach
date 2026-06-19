import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image/image.dart' as img;

import '../../ml/services/ml_input_image_helper.dart';
import '../models/pose_coaching_result.dart';
import '../models/trendy_photo_template.dart';
import 'pose_coaching_coordinator.dart';

/// Runs ML Kit pose inference on preview snapshots and aesthetic coaching math.
class PoseCoachingService {
  PoseCoachingService({
    PoseDetector? poseDetector,
    PoseCoachingCoordinator? coordinator,
  })  : _poseDetector = poseDetector ??
            PoseDetector(
              options: PoseDetectorOptions(
                model: PoseDetectionModel.base,
                mode: PoseDetectionMode.stream,
              ),
            ),
        _coordinator = coordinator ?? PoseCoachingCoordinator();

  static const maxMlSide = 480;

  final PoseDetector _poseDetector;
  final PoseCoachingCoordinator _coordinator;

  PoseCoachingCoordinator get coordinator => _coordinator;

  /// Decodes a JPEG/PNG preview frame, detects pose, returns throttled coaching.
  Future<PoseCoachingResult?> evaluatePreviewFrame({
    required Uint8List bytes,
    required double rollAngle,
    TrendyPhotoTemplate? trendyTemplate,
    DateTime? now,
  }) async {
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

    final pose = poses.isEmpty ? null : poses.first;
    final result = await _coordinator.evaluateFromPose(
      pose: pose,
      imageWidth: mlImage.width,
      imageHeight: mlImage.height,
      rollAngle: rollAngle,
      trendyTemplate: trendyTemplate,
      now: now,
    );

    return result ?? _coordinator.latestResult;
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
  }

  Future<void> dispose() async {
    await _poseDetector.close();
  }
}
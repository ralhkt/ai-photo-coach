import 'dart:ui';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../pose/services/pose_landmark_utils.dart';
import '../../pose/services/pose_skeleton_segment_builder.dart';

/// Extracts an art-student skeleton from a reference photo pose detection.
abstract final class ReferencePoseSkeletonExtractor {
  static List<List<Offset>> fromPose(
    Pose pose, {
    required int imageWidth,
    required int imageHeight,
    double minLikelihood = defaultMinLikelihood,
  }) {
    if (imageWidth <= 0 || imageHeight <= 0) {
      return const [];
    }

    final landmarks = PoseLandmarkUtils.imputeMissingLandmarks(
      PoseLandmarkUtils.poseToNormalizedMap(
        pose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        likelihoodThreshold: minLikelihood,
      ),
    );

    return PoseSkeletonSegmentBuilder.fromLandmarks(
      landmarks,
      minLikelihood: minLikelihood,
    );
  }

  /// Matches [ReferencePhotoPoseAnalyzer.referenceMinLikelihood].
  static const defaultMinLikelihood = 0.22;
}
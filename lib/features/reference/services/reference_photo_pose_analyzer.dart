import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image/image.dart' as img;

import '../../ml/services/ml_input_image_helper.dart';
import '../../pose/models/pose_point3d.dart';
import '../../pose/services/pose_landmark_utils.dart';
import '../../pose/services/subject_pose_tracker.dart';
import 'reference_pose_skeleton_extractor.dart';

/// High-accuracy pose extraction for uploaded reference photos (not live camera).
class ReferencePhotoPoseAnalyzer {
  ReferencePhotoPoseAnalyzer({
    PoseDetector? poseDetector,
    SubjectPoseTracker? subjectTracker,
  })  : _poseDetector = poseDetector ??
            PoseDetector(
              options: PoseDetectorOptions(
                model: PoseDetectionModel.accurate,
              ),
            ),
        _subjectTracker = subjectTracker ?? SubjectPoseTracker();

  static const int maxAnalysisSide = 1280;
  static const double referenceMinLikelihood = 0.22;

  final PoseDetector _poseDetector;
  final SubjectPoseTracker _subjectTracker;

  Future<ReferencePoseAnalysis> analyze(Uint8List bytes) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return const ReferencePoseAnalysis.empty();
    }

    final oriented = img.bakeOrientation(decoded);
    final mlImage = _downscale(oriented);
    final input = MlInputImageHelper.fromDecodedImage(mlImage);

    List<Pose> poses;
    try {
      poses = await _poseDetector.processImage(input);
    } catch (error, stackTrace) {
      debugPrint('ReferencePhotoPoseAnalyzer: pose failed: $error');
      debugPrint('$stackTrace');
      return ReferencePoseAnalysis(
        imageWidth: mlImage.width,
        imageHeight: mlImage.height,
        orientedAspectRatio: oriented.width / oriented.height,
      );
    }

    final primary = _subjectTracker.selectPrimary(
      poses,
      imageWidth: mlImage.width,
      imageHeight: mlImage.height,
    );
    if (primary == null) {
      return ReferencePoseAnalysis(
        imageWidth: mlImage.width,
        imageHeight: mlImage.height,
        orientedAspectRatio: oriented.width / oriented.height,
      );
    }

    final skeleton = ReferencePoseSkeletonExtractor.fromPose(
      primary,
      imageWidth: mlImage.width,
      imageHeight: mlImage.height,
      minLikelihood: referenceMinLikelihood,
    );
    final templateLandmarks = PoseLandmarkUtils.imputeMissingLandmarks(
      PoseLandmarkUtils.poseToNormalizedMap(
        primary,
        imageWidth: mlImage.width,
        imageHeight: mlImage.height,
        likelihoodThreshold: referenceMinLikelihood,
      ),
    ).values.toList(growable: false);

    return ReferencePoseAnalysis(
      imageWidth: mlImage.width,
      imageHeight: mlImage.height,
      orientedAspectRatio: oriented.width / oriented.height,
      skeletonSegments: skeleton,
      landmarkCount: primary.landmarks.length,
      templateLandmarks: templateLandmarks,
    );
  }

  img.Image _downscale(img.Image image) {
    final longest = image.width > image.height ? image.width : image.height;
    if (longest <= maxAnalysisSide) {
      return image;
    }
    final scale = maxAnalysisSide / longest;
    return img.copyResize(
      image,
      width: (image.width * scale).round(),
      height: (image.height * scale).round(),
      interpolation: img.Interpolation.linear,
    );
  }

  Future<void> dispose() async {
    await _poseDetector.close();
  }
}

class ReferencePoseAnalysis {
  const ReferencePoseAnalysis({
    required this.imageWidth,
    required this.imageHeight,
    required this.orientedAspectRatio,
    this.skeletonSegments = const [],
    this.landmarkCount = 0,
    this.templateLandmarks = const [],
  });

  const ReferencePoseAnalysis.empty()
      : imageWidth = 0,
        imageHeight = 0,
        orientedAspectRatio = 1,
        skeletonSegments = const [],
        landmarkCount = 0,
        templateLandmarks = const [];

  final int imageWidth;
  final int imageHeight;
  final double orientedAspectRatio;
  final List<List<Offset>> skeletonSegments;
  final int landmarkCount;
  final List<PosePoint3D> templateLandmarks;

  bool get hasSkeleton => skeletonSegments.length >= 4;
  bool get hasTemplateLandmarks => templateLandmarks.length >= 8;
}
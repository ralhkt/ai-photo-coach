import 'dart:ui';

import 'body_part_guides.dart';

/// On-device ML vision output used to refine subject framing and guidance.
class MlDetectionResult {
  const MlDetectionResult({
    required this.source,
    required this.inferenceMs,
    this.faceBounds = const [],
    this.primarySubjectRect,
    this.bodyPartGuides,
    this.sceneLabels = const [],
    this.aestheticScore,
    this.faceCount = 0,
    this.hasPose = false,
    this.poseSkeletonSegments = const [],
  });

  final String source;
  final int inferenceMs;
  final List<Rect> faceBounds;
  final Rect? primarySubjectRect;
  final BodyPartGuides? bodyPartGuides;
  final List<MlSceneLabel> sceneLabels;
  final double? aestheticScore;
  final int faceCount;
  final bool hasPose;

  /// Normalized bone polylines detected in the reference photo.
  final List<List<Offset>> poseSkeletonSegments;

  bool get hasFaces => faceBounds.isNotEmpty;

  bool get hasPoseSkeleton => poseSkeletonSegments.isNotEmpty;

  bool get isMlPowered => source == 'ml_kit';
}

class MlSceneLabel {
  const MlSceneLabel({required this.text, required this.confidence});

  final String text;
  final double confidence;
}
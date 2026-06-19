import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_point3d.dart';

/// Unified output for live pose / proportion / tilt coaching (MVP).
class PoseCoachingResult {
  const PoseCoachingResult({
    required this.isLevel,
    required this.poseScore,
    required this.proportionStatus,
    required this.tiltGuidance,
    required this.combinedGuidance,
    this.poseMatched = false,
    this.landmarks = const {},
    this.imageWidth = 0,
    this.imageHeight = 0,
  });

  final bool isLevel;
  final int poseScore;
  final String proportionStatus;
  final String tiltGuidance;
  final String combinedGuidance;

  /// True when [poseScore] >= 85.
  final bool poseMatched;

  /// Smoothed + imputed landmarks in normalized image space (0–1).
  final Map<PoseLandmarkType, PosePoint3D> landmarks;

  /// ML frame dimensions used when [landmarks] were produced.
  final int imageWidth;
  final int imageHeight;

  PoseCoachingResult copyWith({
    bool? isLevel,
    int? poseScore,
    String? proportionStatus,
    String? tiltGuidance,
    String? combinedGuidance,
    bool? poseMatched,
    Map<PoseLandmarkType, PosePoint3D>? landmarks,
    int? imageWidth,
    int? imageHeight,
  }) {
    return PoseCoachingResult(
      isLevel: isLevel ?? this.isLevel,
      poseScore: poseScore ?? this.poseScore,
      proportionStatus: proportionStatus ?? this.proportionStatus,
      tiltGuidance: tiltGuidance ?? this.tiltGuidance,
      combinedGuidance: combinedGuidance ?? this.combinedGuidance,
      poseMatched: poseMatched ?? this.poseMatched,
      landmarks: landmarks ?? this.landmarks,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
    );
  }

  Map<String, dynamic> toMap() => {
        'is_level': isLevel,
        'pose_score': poseScore,
        'proportion_status': proportionStatus,
        'combined_guidance': combinedGuidance,
        'tilt_guidance': tiltGuidance,
        'pose_matched': poseMatched,
      };

  factory PoseCoachingResult.fromMap(Map<String, dynamic> map) {
    final score = (map['pose_score'] as num?)?.toInt() ?? 0;
    return PoseCoachingResult(
      isLevel: map['is_level'] as bool? ?? true,
      poseScore: score,
      proportionStatus: map['proportion_status']?.toString() ?? '未知',
      tiltGuidance: map['tilt_guidance']?.toString() ?? 'OK',
      combinedGuidance: map['combined_guidance']?.toString() ?? 'OK',
      poseMatched: map['pose_matched'] as bool? ?? score >= 85,
    );
  }
}
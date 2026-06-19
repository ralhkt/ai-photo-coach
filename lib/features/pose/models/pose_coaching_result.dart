/// Unified output for live pose / proportion / tilt coaching (MVP).
class PoseCoachingResult {
  const PoseCoachingResult({
    required this.isLevel,
    required this.poseScore,
    required this.proportionStatus,
    required this.tiltGuidance,
    required this.combinedGuidance,
    this.poseMatched = false,
  });

  final bool isLevel;
  final int poseScore;
  final String proportionStatus;
  final String tiltGuidance;
  final String combinedGuidance;

  /// True when [poseScore] >= 85.
  final bool poseMatched;

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
import 'dart:ui';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/pose_coaching_result.dart';
import '../models/pose_point3d.dart';
import '../models/trendy_photo_template.dart';
import 'pose_aesthetic_analyzer.dart';
import 'pose_aligner.dart';
import 'pose_landmark_utils.dart';

/// Regional body grouping for partial pose coaching hints.
enum PoseBodyRegion {
  head('頭部'),
  leftArm('左手'),
  rightArm('右手'),
  torso('上半身'),
  leftLeg('左腿'),
  rightLeg('右腿');

  const PoseBodyRegion(this.labelZh);
  final String labelZh;
}

/// Per-region alignment error after scale-invariant normalization.
class RegionAlignmentScore {
  const RegionAlignmentScore({
    required this.region,
    required this.error,
    required this.deltaX,
    required this.deltaY,
    required this.landmarkCount,
  });

  final PoseBodyRegion region;
  final double error;
  final double deltaX;
  final double deltaY;
  final int landmarkCount;

  bool get isMisaligned => error >= TrendyPhotoAnalyzer.regionErrorThreshold;
}

/// Core trendy-photo coaching: scale-invariant pose match + body-part hints.
class TrendyPhotoAnalyzer {
  TrendyPhotoAnalyzer({this.template});

  static const posePassScore = PoseAestheticAnalyzer.posePassScore;
  static const regionErrorThreshold = 0.22;

  final TrendyPhotoTemplate? template;

  List<PosePoint3D> get templatePose =>
      template?.templatePoses3d ?? const [];

  /// Hip-centered, torso-length scale invariance — returns matched feature vectors.
  ({List<double> user, List<double> template}) normalizeAndAlign({
    required Map<PoseLandmarkType, PosePoint3D> userPoints,
    required Map<PoseLandmarkType, PosePoint3D> templatePoints,
  }) {
    return PoseLandmarkUtils.buildMatchedFeatureVectors(userPoints, templatePoints);
  }

  /// Cosine similarity mapped to 0–100. Scores > 85 mean pose pass.
  int calculatePoseSimilarity(
    Pose userPose, {
    required int imageWidth,
    required int imageHeight,
    List<PosePoint3D>? templatePoseOverride,
  }) {
    final poses = templatePoseOverride ?? templatePose;
    if (poses.isEmpty) {
      return 0;
    }

    final userMap = PoseLandmarkUtils.imputeMissingLandmarks(
      PoseLandmarkUtils.poseToNormalizedMap(
        userPose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      ),
    );
    final templateMap = PoseLandmarkUtils.templateToMap(poses);
    return PoseAligner.similarityScore(userMap, templateMap);
  }

  /// Evaluation using pre-smoothed landmark maps from live coaching pipeline.
  TrendyPhotoCoachingResult evaluateFromLandmarks({
    required Map<PoseLandmarkType, PosePoint3D> landmarks,
    required double rollAngle,
    TrendyPhotoTemplate? templateOverride,
  }) {
    final activeTemplate = templateOverride ?? template;
    final poses = activeTemplate?.templatePoses3d ?? const <PosePoint3D>[];
    final tiltGuidance = analyzeTiltAngle(rollAngle);
    final isLevel = tiltGuidance == 'OK';

    if (landmarks.isEmpty) {
      return TrendyPhotoCoachingResult(
        isLevel: isLevel,
        poseScore: 0,
        proportionStatus: '尚未偵測到身體',
        tiltGuidance: tiltGuidance,
        bodyPartGuidance: '請站入畫面中央',
        combinedGuidance: isLevel ? '請站入畫面中央' : tiltGuidance,
        template: activeTemplate,
      );
    }

    final imputed = PoseLandmarkUtils.imputeMissingLandmarks(landmarks);
    final proportionStatus =
        PoseAestheticAnalyzer.evaluateFromLandmarks(
          landmarks: imputed,
          rollAngle: rollAngle,
        ).proportionStatus;

    final templateMap = PoseLandmarkUtils.templateToMap(poses);
    final poseScore = templateMap.isEmpty
        ? 0
        : PoseAligner.similarityScore(imputed, templateMap);
    final poseMatched = poseScore >= posePassScore;

    final bodyPartGuidance = templateMap.isEmpty
        ? 'OK'
        : _bodyPartGuidanceFromMaps(imputed, templateMap);

    return TrendyPhotoCoachingResult(
      isLevel: isLevel,
      poseScore: poseScore,
      proportionStatus: proportionStatus,
      tiltGuidance: tiltGuidance,
      bodyPartGuidance: bodyPartGuidance,
      combinedGuidance: _combineGuidance(
        isLevel: isLevel,
        tiltGuidance: tiltGuidance,
        proportionStatus: proportionStatus,
        bodyPartGuidance: bodyPartGuidance,
        poseScore: poseScore,
        poseMatched: poseMatched,
        hasTemplate: poses.isNotEmpty,
        shootingTips: activeTemplate?.shootingTips,
      ),
      poseMatched: poseMatched,
      template: activeTemplate,
      regionScores: templateMap.isEmpty
          ? const []
          : scoreBodyRegions(
              userPoints: imputed,
              templatePoints: templateMap,
            ),
    );
  }

  String _bodyPartGuidanceFromMaps(
    Map<PoseLandmarkType, PosePoint3D> userMap,
    Map<PoseLandmarkType, PosePoint3D> templateMap,
  ) {
    final scores = scoreBodyRegions(
      userPoints: userMap,
      templatePoints: templateMap,
    );
    final worst = scores.where((s) => s.isMisaligned).firstOrNull;
    if (worst == null) {
      return 'OK';
    }
    return _hintForRegion(worst);
  }

  /// Scores each body region; highest-error region drives partial guidance.
  List<RegionAlignmentScore> scoreBodyRegions({
    required Map<PoseLandmarkType, PosePoint3D> userPoints,
    required Map<PoseLandmarkType, PosePoint3D> templatePoints,
  }) {
    final results = <RegionAlignmentScore>[];

    for (final region in PoseBodyRegion.values) {
      final types = _landmarksForRegion(region)
          .where(
            (t) => userPoints.containsKey(t) && templatePoints.containsKey(t),
          )
          .toList();
      if (types.isEmpty) {
        continue;
      }

      final userVec = PoseLandmarkUtils.buildFeatureVector(
        Map.fromEntries(types.map((t) => MapEntry(t, userPoints[t]!))),
      );
      final templateVec = PoseLandmarkUtils.buildFeatureVector(
        Map.fromEntries(types.map((t) => MapEntry(t, templatePoints[t]!))),
      );
      if (userVec.length != templateVec.length || userVec.isEmpty) {
        continue;
      }

      var sumError = 0.0;
      var sumDx = 0.0;
      var sumDy = 0.0;
      for (var i = 0; i < userVec.length; i += 2) {
        final dx = userVec[i] - templateVec[i];
        final dy = userVec[i + 1] - templateVec[i + 1];
        sumDx += dx;
        sumDy += dy;
        sumError += Offset(dx, dy).distance;
      }

      final count = types.length;
      results.add(
        RegionAlignmentScore(
          region: region,
          error: sumError / count,
          deltaX: sumDx / count,
          deltaY: sumDy / count,
          landmarkCount: count,
        ),
      );
    }

    results.sort((a, b) => b.error.compareTo(a.error));
    return results;
  }

  /// Generates the single most actionable partial-body hint in zh-TW.
  String generateBodyPartGuidance({
    required Pose userPose,
    required int imageWidth,
    required int imageHeight,
    List<PosePoint3D>? templatePoseOverride,
  }) {
    final poses = templatePoseOverride ?? templatePose;
    if (poses.isEmpty) {
      return 'OK';
    }

    final userMap = PoseLandmarkUtils.poseToNormalizedMap(
      userPose,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
    final templateMap = PoseLandmarkUtils.templateToMap(poses);
    final scores = scoreBodyRegions(
      userPoints: userMap,
      templatePoints: templateMap,
    );

    final worst = scores.where((s) => s.isMisaligned).firstOrNull;
    if (worst == null) {
      return 'OK';
    }

    return _hintForRegion(worst);
  }

  String analyzeProportion(
    Pose pose, {
    required int imageWidth,
    required int imageHeight,
  }) {
    return PoseAestheticAnalyzer.analyzeProportion(
      pose,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
  }

  String analyzeTiltAngle(double rollAngle) {
    return PoseAestheticAnalyzer.analyzeTiltAngle(rollAngle);
  }

  /// Full evaluation for live camera overlay.
  TrendyPhotoCoachingResult evaluate({
    required Pose? pose,
    required int imageWidth,
    required int imageHeight,
    required double rollAngle,
    TrendyPhotoTemplate? templateOverride,
  }) {
    final activeTemplate = templateOverride ?? template;
    final poses = activeTemplate?.templatePoses3d ?? const <PosePoint3D>[];
    final tiltGuidance = analyzeTiltAngle(rollAngle);
    final isLevel = tiltGuidance == 'OK';

    if (pose == null) {
      return TrendyPhotoCoachingResult(
        isLevel: isLevel,
        poseScore: 0,
        proportionStatus: '尚未偵測到身體',
        tiltGuidance: tiltGuidance,
        bodyPartGuidance: '請站入畫面中央',
        combinedGuidance: isLevel ? '請站入畫面中央' : tiltGuidance,
        template: activeTemplate,
      );
    }

    final proportionStatus = analyzeProportion(
      pose,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );

    final poseScore = poses.isEmpty
        ? 0
        : calculatePoseSimilarity(
            pose,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            templatePoseOverride: poses,
          );
    final poseMatched = poseScore >= posePassScore;

    final bodyPartGuidance = poses.isEmpty
        ? 'OK'
        : generateBodyPartGuidance(
            userPose: pose,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            templatePoseOverride: poses,
          );

    return TrendyPhotoCoachingResult(
      isLevel: isLevel,
      poseScore: poseScore,
      proportionStatus: proportionStatus,
      tiltGuidance: tiltGuidance,
      bodyPartGuidance: bodyPartGuidance,
      combinedGuidance: _combineGuidance(
        isLevel: isLevel,
        tiltGuidance: tiltGuidance,
        proportionStatus: proportionStatus,
        bodyPartGuidance: bodyPartGuidance,
        poseScore: poseScore,
        poseMatched: poseMatched,
        hasTemplate: poses.isNotEmpty,
        shootingTips: activeTemplate?.shootingTips,
      ),
      poseMatched: poseMatched,
      template: activeTemplate,
      regionScores: poses.isEmpty
          ? const []
          : scoreBodyRegions(
              userPoints: PoseLandmarkUtils.poseToNormalizedMap(
                pose,
                imageWidth: imageWidth,
                imageHeight: imageHeight,
              ),
              templatePoints: PoseLandmarkUtils.templateToMap(poses),
            ),
    );
  }

  static List<PoseLandmarkType> _landmarksForRegion(PoseBodyRegion region) {
    return switch (region) {
      PoseBodyRegion.head => const [
          PoseLandmarkType.nose,
          PoseLandmarkType.leftEar,
          PoseLandmarkType.rightEar,
          PoseLandmarkType.leftEye,
          PoseLandmarkType.rightEye,
        ],
      PoseBodyRegion.leftArm => const [
          PoseLandmarkType.leftShoulder,
          PoseLandmarkType.leftElbow,
          PoseLandmarkType.leftWrist,
        ],
      PoseBodyRegion.rightArm => const [
          PoseLandmarkType.rightShoulder,
          PoseLandmarkType.rightElbow,
          PoseLandmarkType.rightWrist,
        ],
      PoseBodyRegion.torso => const [
          PoseLandmarkType.leftShoulder,
          PoseLandmarkType.rightShoulder,
          PoseLandmarkType.leftHip,
          PoseLandmarkType.rightHip,
        ],
      PoseBodyRegion.leftLeg => const [
          PoseLandmarkType.leftHip,
          PoseLandmarkType.leftKnee,
          PoseLandmarkType.leftAnkle,
        ],
      PoseBodyRegion.rightLeg => const [
          PoseLandmarkType.rightHip,
          PoseLandmarkType.rightKnee,
          PoseLandmarkType.rightAnkle,
        ],
    };
  }

  static String _hintForRegion(RegionAlignmentScore score) {
    final label = score.region.labelZh;
    final parts = <String>[];

    if (score.deltaY.abs() > 0.08) {
      // Normalized space: positive deltaY => user landmark lower than template.
      parts.add(score.deltaY > 0 ? '$label再抬高一些' : '$label再放低一些');
    }
    if (score.deltaX.abs() > 0.08) {
      parts.add(score.deltaX > 0 ? '$label往左移一點' : '$label往右移一點');
    }

    if (parts.isEmpty) {
      return '調整$label，更接近範本姿勢';
    }
    return parts.first;
  }

  static String _combineGuidance({
    required bool isLevel,
    required String tiltGuidance,
    required String proportionStatus,
    required String bodyPartGuidance,
    required int poseScore,
    required bool poseMatched,
    required bool hasTemplate,
    String? shootingTips,
  }) {
    if (!isLevel) {
      return tiltGuidance;
    }
    if (proportionStatus != 'OK') {
      return proportionStatus;
    }
    if (hasTemplate && bodyPartGuidance != 'OK' && !poseMatched) {
      return bodyPartGuidance;
    }
    if (hasTemplate && !poseMatched) {
      return '整體動作再靠近範本（$poseScore 分，85 分過關）';
    }
    if (hasTemplate && poseMatched) {
      final tip = shootingTips?.trim();
      if (tip != null && tip.isNotEmpty) {
        return '完美！$tip';
      }
      return '完美！比例與動作都到位，可以拍了';
    }
    return '構圖比例 OK，可以拍了';
  }
}

/// Extended coaching result with trendy template metadata.
class TrendyPhotoCoachingResult extends PoseCoachingResult {
  const TrendyPhotoCoachingResult({
    required super.isLevel,
    required super.poseScore,
    required super.proportionStatus,
    required super.tiltGuidance,
    required super.combinedGuidance,
    required this.bodyPartGuidance,
    super.poseMatched = false,
    this.template,
    this.regionScores = const [],
  });

  final String bodyPartGuidance;
  final TrendyPhotoTemplate? template;
  final List<RegionAlignmentScore> regionScores;

  List<String> get tags => template?.tags ?? const [];

  String? get shootingTips => template?.shootingTips;

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'body_part_guidance': bodyPartGuidance,
        if (template != null) ...{
          'scene_type': template!.sceneType,
          'composition': template!.composition,
          'tags': template!.tags,
          'shooting_tips': template!.shootingTips,
        },
      };
}
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../data/seated_phone_template_pose.dart';
import '../models/pose_coaching_result.dart';
import '../models/pose_point3d.dart';
import '../models/trendy_photo_template.dart';
import 'pose_aesthetic_analyzer.dart';
import 'pose_landmark_utils.dart';
import 'trendy_photo_analyzer.dart';

/// Serializable snapshot for optional isolate offload.
@immutable
class PoseCoachingInput {
  const PoseCoachingInput({
    required this.normalizedLandmarks,
    required this.imageWidth,
    required this.imageHeight,
    required this.rollAngle,
    this.templatePose = seatedPhoneTemplatePose,
  });

  final Map<PoseLandmarkType, PosePoint3D> normalizedLandmarks;
  final int imageWidth;
  final int imageHeight;
  final double rollAngle;
  final List<PosePoint3D> templatePose;
}

/// Throttled bridge between camera stream, ML Kit pose, and aesthetic coaching.
///
/// Typical wiring inside a camera listener:
/// ```dart
/// // 1) ML Kit (native async) — never block UI while detecting
/// final poses = await poseDetector.processImage(input);
/// final pose = poses.isEmpty ? null : poses.first;
///
/// // 2) Gyroscope roll from DeviceAttitudeService (parallel stream)
/// final roll = latestAttitude.rollDegrees;
///
/// // 3) Coaching update throttled to ~5 Hz
/// final result = await coordinator.evaluateFromPose(
///   pose: pose,
///   imageWidth: image.width,
///   imageHeight: image.height,
///   rollAngle: roll,
/// );
/// if (result != null) {
///   ref.read(poseCoachingResultProvider.notifier).state = result;
/// }
/// ```
class PoseCoachingCoordinator {
  PoseCoachingCoordinator({
    this.minInterval = const Duration(milliseconds: 200),
    this.templatePose = seatedPhoneTemplatePose,
    this.offloadToIsolate = false,
  });

  final Duration minInterval;
  final List<PosePoint3D> templatePose;

  /// When true, runs vector math on a background isolate via [compute].
  /// Keep false for MVP — 15–30 landmarks is sub-millisecond on main isolate.
  final bool offloadToIsolate;

  DateTime _lastEvaluated = DateTime.fromMillisecondsSinceEpoch(0);
  PoseCoachingResult? _latestResult;

  PoseCoachingResult? get latestResult => _latestResult;

  /// True when the next evaluation would be dropped by [minInterval].
  bool isThrottled(DateTime now) {
    return now.difference(_lastEvaluated) < minInterval;
  }

  /// Returns null when throttled so callers can skip UI churn.
  Future<PoseCoachingResult?> evaluateFromPose({
    required Pose? pose,
    required int imageWidth,
    required int imageHeight,
    required double rollAngle,
    TrendyPhotoTemplate? trendyTemplate,
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();
    if (timestamp.difference(_lastEvaluated) < minInterval) {
      return null;
    }
    _lastEvaluated = timestamp;

    final PoseCoachingResult result;
    if (trendyTemplate != null && trendyTemplate.hasPoseTemplate) {
      result = TrendyPhotoAnalyzer(template: trendyTemplate).evaluate(
        pose: pose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        rollAngle: rollAngle,
      );
    } else if (offloadToIsolate && pose != null) {
      result = await _evaluateInIsolate(
        pose: pose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        rollAngle: rollAngle,
      );
    } else {
      result = PoseAestheticAnalyzer.evaluate(
        pose: pose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        rollAngle: rollAngle,
        templatePose: templatePose,
      );
    }

    _latestResult = result;
    return result;
  }

  /// Uses temporally smoothed landmarks (subject tracker + joint EMA upstream).
  Future<PoseCoachingResult?> evaluateFromLandmarks({
    required Map<PoseLandmarkType, PosePoint3D> landmarks,
    required int imageWidth,
    required int imageHeight,
    required double rollAngle,
    TrendyPhotoTemplate? trendyTemplate,
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();
    if (timestamp.difference(_lastEvaluated) < minInterval) {
      return null;
    }
    _lastEvaluated = timestamp;

    final imputed = PoseLandmarkUtils.imputeMissingLandmarks(landmarks);

    final PoseCoachingResult result;
    if (trendyTemplate != null && trendyTemplate.hasPoseTemplate) {
      result = TrendyPhotoAnalyzer(template: trendyTemplate).evaluateFromLandmarks(
        landmarks: imputed,
        rollAngle: rollAngle,
      );
    } else {
      result = PoseAestheticAnalyzer.evaluateFromLandmarks(
        landmarks: imputed,
        rollAngle: rollAngle,
        templatePose: templatePose,
      );
    }

    _latestResult = result;
    return result;
  }

  Future<PoseCoachingResult> _evaluateInIsolate({
    required Pose pose,
    required int imageWidth,
    required int imageHeight,
    required double rollAngle,
  }) async {
    final input = PoseCoachingInput(
      normalizedLandmarks: PoseLandmarkUtils.poseToNormalizedMap(
        pose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      ),
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      rollAngle: rollAngle,
      templatePose: templatePose,
    );

    return compute(_evaluateInputOnIsolate, input);
  }

  void reset() {
    _lastEvaluated = DateTime.fromMillisecondsSinceEpoch(0);
    _latestResult = null;
  }
}

/// Top-level for [compute] — must not capture closures.
PoseCoachingResult _evaluateInputOnIsolate(PoseCoachingInput input) {
  final tiltGuidance = PoseAestheticAnalyzer.analyzeTiltAngle(input.rollAngle);
  final isLevel = tiltGuidance == 'OK';

  if (input.normalizedLandmarks.isEmpty) {
    return PoseCoachingResult(
      isLevel: isLevel,
      poseScore: 0,
      proportionStatus: '尚未偵測到身體',
      tiltGuidance: tiltGuidance,
      combinedGuidance: isLevel ? '請站入畫面中央' : tiltGuidance,
    );
  }

  final proportionStatus = _analyzeProportionFromMap(input.normalizedLandmarks);
  final matched = PoseLandmarkUtils.buildMatchedFeatureVectors(
    input.normalizedLandmarks,
    PoseLandmarkUtils.templateToMap(input.templatePose),
  );

  final poseScore = matched.user.isEmpty
      ? 0
      : ((PoseLandmarkUtils.cosineSimilarity(matched.user, matched.template) + 1) /
                  2 *
              100)
          .round()
          .clamp(0, 100);

  final poseMatched = poseScore >= PoseAestheticAnalyzer.posePassScore;

  return PoseCoachingResult(
    isLevel: isLevel,
    poseScore: poseScore,
    proportionStatus: proportionStatus,
    tiltGuidance: tiltGuidance,
    combinedGuidance: _combineGuidance(
      isLevel: isLevel,
      tiltGuidance: tiltGuidance,
      proportionStatus: proportionStatus,
      poseScore: poseScore,
      poseMatched: poseMatched,
      hasTemplate: input.templatePose.isNotEmpty,
    ),
    poseMatched: poseMatched,
  );
}

String _analyzeProportionFromMap(Map<PoseLandmarkType, PosePoint3D> points) {
  final leftAnkle = points[PoseLandmarkType.leftAnkle];
  final rightAnkle = points[PoseLandmarkType.rightAnkle];
  final leftEar = points[PoseLandmarkType.leftEar];
  final rightEar = points[PoseLandmarkType.rightEar];
  final nose = points[PoseLandmarkType.nose];

  if (leftAnkle == null && rightAnkle == null) {
    return '請全身入鏡，確保雙腳可見';
  }

  final ankleY = _maxNormalizedY([leftAnkle, rightAnkle]);
  final headY = _minNormalizedY([leftEar, rightEar, nose]);

  if (headY == null) {
    return '請面向鏡頭，確保頭部在畫面內';
  }

  final anklesLowEnough =
      ankleY != null && ankleY > PoseAestheticAnalyzer.ankleBottomThreshold;
  final headInRange = headY >= PoseAestheticAnalyzer.headMinY &&
      headY <= PoseAestheticAnalyzer.headMaxY;

  if (!anklesLowEnough && !headInRange) {
    if (headY < PoseAestheticAnalyzer.headMinY) {
      return '手機拿低一點，仰拍顯腿長！頭頂也留多一點背景';
    }
    return '手機拿低一點，仰拍顯腿長！同時讓頭部落在畫面上方 20%–40%';
  }

  if (!anklesLowEnough) {
    return '手機拿低一點，仰拍顯腿長！';
  }

  if (headY < PoseAestheticAnalyzer.headMinY) {
    return '頭頂再留多一點背景，九頭身更好看';
  }

  if (headY > PoseAestheticAnalyzer.headMaxY) {
    return '手機抬高或後退半步，頭部落在畫面上方 20%–40%';
  }

  return 'OK';
}

String _combineGuidance({
  required bool isLevel,
  required String tiltGuidance,
  required String proportionStatus,
  required int poseScore,
  required bool poseMatched,
  required bool hasTemplate,
}) {
  if (!isLevel) {
    return tiltGuidance;
  }
  if (proportionStatus != 'OK') {
    return proportionStatus;
  }
  if (hasTemplate && !poseMatched) {
    return '動作再靠近範本一點（目前 $poseScore 分，85 分過關）';
  }
  if (hasTemplate && poseMatched) {
    return '完美！比例與動作都到位，可以拍了';
  }
  return '構圖比例 OK，可以拍了';
}

double? _maxNormalizedY(List<PosePoint3D?> points) {
  double? maxY;
  for (final point in points) {
    if (point == null) {
      continue;
    }
    maxY = maxY == null ? point.y : (point.y > maxY ? point.y : maxY);
  }
  return maxY;
}

double? _minNormalizedY(List<PosePoint3D?> points) {
  double? minY;
  for (final point in points) {
    if (point == null) {
      continue;
    }
    minY = minY == null ? point.y : (point.y < minY ? point.y : minY);
  }
  return minY;
}
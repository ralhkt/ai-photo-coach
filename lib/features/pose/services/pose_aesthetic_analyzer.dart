import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/pose_coaching_result.dart';
import '../models/pose_point3d.dart';
import 'pose_aligner.dart';
import 'pose_landmark_utils.dart';

/// MVP aesthetic coaching: nine-head proportion, template pose match, tilt guide.
abstract final class PoseAestheticAnalyzer {
  static const ankleBottomThreshold = 0.9;
  static const headMinY = 0.2;
  static const headMaxY = 0.4;
  static const tiltToleranceDegrees = 2.0;
  static const posePassScore = 85;

  /// Nine-head proportion check using normalized ankle + ear/head Y positions.
  ///
  /// ML Kit returns pixel coordinates — pass [imageWidth]/[imageHeight] to
  /// normalize into 0.0–1.0 image space (Y grows downward).
  static String analyzeProportion(
    Pose pose, {
    required int imageWidth,
    required int imageHeight,
  }) {
    final leftAnkle = PoseLandmarkUtils.landmarkAsPoint3D(
      pose,
      PoseLandmarkType.leftAnkle,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
    final rightAnkle = PoseLandmarkUtils.landmarkAsPoint3D(
      pose,
      PoseLandmarkType.rightAnkle,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );

    final leftEar = PoseLandmarkUtils.landmarkAsPoint3D(
      pose,
      PoseLandmarkType.leftEar,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
    final rightEar = PoseLandmarkUtils.landmarkAsPoint3D(
      pose,
      PoseLandmarkType.rightEar,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
    final nose = PoseLandmarkUtils.landmarkAsPoint3D(
      pose,
      PoseLandmarkType.nose,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );

    if (leftAnkle == null && rightAnkle == null) {
      return '請全身入鏡，確保雙腳可見';
    }

    final ankleY = _maxY([leftAnkle, rightAnkle]);
    final headY = _minY([leftEar, rightEar, nose]);

    if (headY == null) {
      return '請面向鏡頭，確保頭部在畫面內';
    }

    final anklesLowEnough = ankleY != null && ankleY > ankleBottomThreshold;
    final headInRange = headY >= headMinY && headY <= headMaxY;

    if (!anklesLowEnough && !headInRange) {
      if (headY < headMinY) {
        return '手機拿低一點，仰拍顯腿長！頭頂也留多一點背景';
      }
      return '手機拿低一點，仰拍顯腿長！同時讓頭部落在畫面上方 20%–40%';
    }

    if (!anklesLowEnough) {
      return '手機拿低一點，仰拍顯腿長！';
    }

    if (headY < headMinY) {
      return '頭頂再留多一點背景，九頭身更好看';
    }

    if (headY > headMaxY) {
      return '手機抬高或後退半步，頭部落在畫面上方 20%–40%';
    }

    return 'OK';
  }

  /// Cosine similarity between live pose and a stored template skeleton.
  ///
  /// Returns 0–100; scores above [posePassScore] mean the pose is close enough.
  static int calculatePoseSimilarity(
    Pose userPose,
    List<Point3D> templatePose, {
    required int imageWidth,
    required int imageHeight,
  }) {
    final userMap = PoseLandmarkUtils.imputeMissingLandmarks(
      PoseLandmarkUtils.poseToNormalizedMap(
        userPose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      ),
    );
    final templateMap = PoseLandmarkUtils.templateToMap(templatePose);

    return PoseAligner.similarityScore(userMap, templateMap);
  }

  /// Coaching from pre-smoothed normalized landmarks (post temporal filter).
  static PoseCoachingResult evaluateFromLandmarks({
    required Map<PoseLandmarkType, PosePoint3D> landmarks,
    required double rollAngle,
    List<PosePoint3D> templatePose = const [],
  }) {
    final tiltGuidance = analyzeTiltAngle(rollAngle);
    final isLevel = tiltGuidance == 'OK';

    if (landmarks.isEmpty) {
      return PoseCoachingResult(
        isLevel: isLevel,
        poseScore: 0,
        proportionStatus: '尚未偵測到身體',
        tiltGuidance: tiltGuidance,
        combinedGuidance: isLevel ? '請站入畫面中央' : tiltGuidance,
      );
    }

    final imputed = PoseLandmarkUtils.imputeMissingLandmarks(landmarks);
    final proportionStatus = _analyzeProportionFromMap(imputed);
    final templateMap = PoseLandmarkUtils.templateToMap(templatePose);
    final poseScore = templateMap.isEmpty
        ? 0
        : PoseAligner.similarityScore(imputed, templateMap);
    final poseMatched = poseScore >= posePassScore;

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
        hasTemplate: templatePose.isNotEmpty,
      ),
      poseMatched: poseMatched,
    );
  }

  static String _analyzeProportionFromMap(Map<PoseLandmarkType, PosePoint3D> points) {
    final leftAnkle = points[PoseLandmarkType.leftAnkle];
    final rightAnkle = points[PoseLandmarkType.rightAnkle];
    final leftEar = points[PoseLandmarkType.leftEar];
    final rightEar = points[PoseLandmarkType.rightEar];
    final nose = points[PoseLandmarkType.nose];

    final hasUpperBody = points.containsKey(PoseLandmarkType.leftShoulder) ||
        points.containsKey(PoseLandmarkType.rightShoulder);

    if (leftAnkle == null && rightAnkle == null) {
      if (hasUpperBody) {
        return '半身構圖可接受，若要九頭身請全身入鏡';
      }
      return '請全身入鏡，確保雙腳可見';
    }

    final ankleY = _maxY([leftAnkle, rightAnkle]);
    final headY = _minY([leftEar, rightEar, nose]);

    if (headY == null) {
      return '請面向鏡頭，確保頭部在畫面內';
    }

    final anklesLowEnough = ankleY != null && ankleY > ankleBottomThreshold;
    final headInRange = headY >= headMinY && headY <= headMaxY;

    if (!anklesLowEnough && !headInRange) {
      if (headY < headMinY) {
        return '手機拿低一點，仰拍顯腿長！頭頂也留多一點背景';
      }
      return '手機拿低一點，仰拍顯腿長！同時讓頭部落在畫面上方 20%–40%';
    }

    if (!anklesLowEnough) {
      return '手機拿低一點，仰拍顯腿長！';
    }

    if (headY < headMinY) {
      return '頭頂再留多一點背景，九頭身更好看';
    }

    if (headY > headMaxY) {
      return '手機抬高或後退半步，頭部落在畫面上方 20%–40%';
    }

    return 'OK';
  }

  /// Level guidance from gyroscope roll angle (degrees).
  static String analyzeTiltAngle(double rollAngle) {
    final absRoll = rollAngle.abs();
    if (absRoll <= tiltToleranceDegrees) {
      return 'OK';
    }

    final correction = (absRoll - tiltToleranceDegrees).round().clamp(1, 45);
    if (rollAngle > 0) {
      return '手機請向右旋轉 $correction 度';
    }
    return '手機請向左旋轉 $correction 度';
  }

  /// Unified coaching payload for UI / logging.
  static PoseCoachingResult evaluate({
    required Pose? pose,
    required int imageWidth,
    required int imageHeight,
    required double rollAngle,
    List<Point3D> templatePose = const [],
  }) {
    final tiltGuidance = analyzeTiltAngle(rollAngle);
    final isLevel = tiltGuidance == 'OK';

    if (pose == null) {
      return PoseCoachingResult(
        isLevel: isLevel,
        poseScore: 0,
        proportionStatus: '尚未偵測到身體',
        tiltGuidance: tiltGuidance,
        combinedGuidance: isLevel ? '請站入畫面中央' : tiltGuidance,
      );
    }

    final proportionStatus = analyzeProportion(
      pose,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
    final poseScore = templatePose.isEmpty
        ? 0
        : calculatePoseSimilarity(
            pose,
            templatePose,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
          );
    final poseMatched = poseScore >= posePassScore;

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
        hasTemplate: templatePose.isNotEmpty,
      ),
      poseMatched: poseMatched,
    );
  }

  static String _combineGuidance({
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

  static double? _maxY(List<PosePoint3D?> points) {
    double? maxY;
    for (final point in points) {
      if (point == null) {
        continue;
      }
      maxY = maxY == null ? point.y : (point.y > maxY ? point.y : maxY);
    }
    return maxY;
  }

  static double? _minY(List<PosePoint3D?> points) {
    double? minY;
    for (final point in points) {
      if (point == null) {
        continue;
      }
      minY = minY == null ? point.y : (point.y < minY ? point.y : minY);
    }
    return minY;
  }
}
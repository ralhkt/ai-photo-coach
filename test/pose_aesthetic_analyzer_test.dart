import 'package:ai_photo_coach/features/pose/data/seated_phone_template_pose.dart';
import 'package:ai_photo_coach/features/pose/models/pose_point3d.dart';
import 'package:ai_photo_coach/features/pose/services/pose_aesthetic_analyzer.dart';
import 'package:ai_photo_coach/features/pose/services/pose_coaching_coordinator.dart';
import 'package:ai_photo_coach/features/pose/services/pose_landmark_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

void main() {
  const imageWidth = 1080;
  const imageHeight = 1920;

  group('analyzeProportion', () {
    test('returns OK for ideal nine-head framing', () {
      final pose = _buildPose({
        PoseLandmarkType.leftAnkle: const _Lm(0.38, 0.92),
        PoseLandmarkType.rightAnkle: const _Lm(0.50, 0.91),
        PoseLandmarkType.leftEar: const _Lm(0.52, 0.30),
        PoseLandmarkType.rightEar: const _Lm(0.60, 0.30),
        PoseLandmarkType.nose: const _Lm(0.56, 0.32),
      });

      expect(
        PoseAestheticAnalyzer.analyzeProportion(
          pose,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
        ),
        'OK',
      );
    });

    test('asks to lower phone when ankles are too high', () {
      final pose = _buildPose({
        PoseLandmarkType.leftAnkle: const _Lm(0.40, 0.70),
        PoseLandmarkType.rightAnkle: const _Lm(0.52, 0.72),
        PoseLandmarkType.leftEar: const _Lm(0.52, 0.30),
        PoseLandmarkType.rightEar: const _Lm(0.60, 0.30),
        PoseLandmarkType.nose: const _Lm(0.56, 0.32),
      });

      final status = PoseAestheticAnalyzer.analyzeProportion(
        pose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );

      expect(status, contains('手機拿低一點'));
    });

    test('asks to raise phone when head is too low in frame', () {
      final pose = _buildPose({
        PoseLandmarkType.leftAnkle: const _Lm(0.38, 0.92),
        PoseLandmarkType.rightAnkle: const _Lm(0.50, 0.91),
        PoseLandmarkType.leftEar: const _Lm(0.52, 0.55),
        PoseLandmarkType.rightEar: const _Lm(0.60, 0.55),
        PoseLandmarkType.nose: const _Lm(0.56, 0.58),
      });

      final status = PoseAestheticAnalyzer.analyzeProportion(
        pose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );

      expect(status, contains('手機抬高'));
    });
  });

  group('calculatePoseSimilarity', () {
    test('scores high when user pose matches template', () {
      final pose = _buildPose({
        for (final point in seatedPhoneTemplatePose)
          point.type!: _Lm(point.x, point.y, likelihood: 0.95),
      });

      final score = PoseAestheticAnalyzer.calculatePoseSimilarity(
        pose,
        seatedPhoneTemplatePose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );

      expect(score, greaterThanOrEqualTo(95));
    });

    test('scores low for mismatched limb layout', () {
      final pose = _buildPose({
        PoseLandmarkType.nose: const _Lm(0.56, 0.22),
        PoseLandmarkType.leftEar: const _Lm(0.52, 0.20),
        PoseLandmarkType.rightEar: const _Lm(0.60, 0.20),
        PoseLandmarkType.leftShoulder: const _Lm(0.20, 0.30),
        PoseLandmarkType.rightShoulder: const _Lm(0.80, 0.30),
        PoseLandmarkType.leftElbow: const _Lm(0.10, 0.55),
        PoseLandmarkType.rightElbow: const _Lm(0.90, 0.55),
        PoseLandmarkType.leftWrist: const _Lm(0.05, 0.75),
        PoseLandmarkType.rightWrist: const _Lm(0.95, 0.75),
        PoseLandmarkType.leftHip: const _Lm(0.46, 0.56),
        PoseLandmarkType.rightHip: const _Lm(0.54, 0.56),
        PoseLandmarkType.leftKnee: const _Lm(0.40, 0.72),
        PoseLandmarkType.rightKnee: const _Lm(0.52, 0.70),
        PoseLandmarkType.leftAnkle: const _Lm(0.38, 0.92),
        PoseLandmarkType.rightAnkle: const _Lm(0.50, 0.90),
      });

      final score = PoseAestheticAnalyzer.calculatePoseSimilarity(
        pose,
        seatedPhoneTemplatePose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );

      expect(score, lessThan(85));
    });
  });

  group('analyzeTiltAngle', () {
    test('returns OK within tolerance', () {
      expect(PoseAestheticAnalyzer.analyzeTiltAngle(1.5), 'OK');
      expect(PoseAestheticAnalyzer.analyzeTiltAngle(-1.8), 'OK');
    });

    test('guides right rotation for positive roll', () {
      expect(
        PoseAestheticAnalyzer.analyzeTiltAngle(5.2),
        '手機請向右旋轉 3 度',
      );
    });

    test('guides left rotation for negative roll', () {
      expect(
        PoseAestheticAnalyzer.analyzeTiltAngle(-6.0),
        '手機請向左旋轉 4 度',
      );
    });
  });

  group('evaluate unified model', () {
    test('prioritizes tilt guidance over proportion', () {
      final pose = _buildPose({
        PoseLandmarkType.leftAnkle: const _Lm(0.38, 0.92),
        PoseLandmarkType.rightAnkle: const _Lm(0.50, 0.91),
        PoseLandmarkType.leftEar: const _Lm(0.52, 0.30),
        PoseLandmarkType.rightEar: const _Lm(0.60, 0.30),
        PoseLandmarkType.nose: const _Lm(0.56, 0.32),
      });

      final result = PoseAestheticAnalyzer.evaluate(
        pose: pose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        rollAngle: 8,
        templatePose: seatedPhoneTemplatePose,
      );

      expect(result.isLevel, isFalse);
      expect(result.combinedGuidance, contains('向右旋轉'));
      expect(result.toMap()['pose_score'], isA<int>());
      expect(result.toMap()['proportion_status'], 'OK');
    });

    test('marks pose matched when score >= 85', () {
      final pose = _buildPose({
        for (final point in seatedPhoneTemplatePose)
          point.type!: _Lm(point.x, point.y, likelihood: 0.95),
      });

      final result = PoseAestheticAnalyzer.evaluate(
        pose: pose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        rollAngle: 0,
        templatePose: seatedPhoneTemplatePose,
      );

      expect(result.poseMatched, isTrue);
      expect(result.poseScore, greaterThanOrEqualTo(85));
      expect(result.combinedGuidance, contains('完美'));
    });
  });

  group('PoseCoachingCoordinator', () {
    test('throttles evaluations to minInterval', () async {
      final coordinator = PoseCoachingCoordinator(
        minInterval: const Duration(milliseconds: 200),
      );
      final pose = _buildPose({
        PoseLandmarkType.nose: const _Lm(0.5, 0.3),
      });
      final t0 = DateTime(2026, 1, 1, 12, 0, 0);

      final first = await coordinator.evaluateFromPose(
        pose: pose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        rollAngle: 0,
        now: t0,
      );
      final second = await coordinator.evaluateFromPose(
        pose: pose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        rollAngle: 0,
        now: t0.add(const Duration(milliseconds: 50)),
      );

      expect(first, isNotNull);
      expect(second, isNull);
    });

    test('buildMatchedFeatureVectors keeps user/template dimensions aligned', () {
      final user = PoseLandmarkUtils.poseToNormalizedMap(
        _buildPose({
          PoseLandmarkType.nose: const _Lm(0.56, 0.22),
          PoseLandmarkType.leftHip: const _Lm(0.46, 0.56),
          PoseLandmarkType.rightHip: const _Lm(0.54, 0.56),
        }),
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );
      final template = PoseLandmarkUtils.templateToMap(seatedPhoneTemplatePose);

      final matched = PoseLandmarkUtils.buildMatchedFeatureVectors(user, template);

      expect(matched.user.length, matched.template.length);
      expect(matched.user, isNotEmpty);
    });
  });
}

class _Lm {
  const _Lm(this.x, this.y, {this.likelihood = 0.9});

  final double x;
  final double y;
  final double likelihood;
}

Pose _buildPose(Map<PoseLandmarkType, _Lm> specs) {
  return Pose(
    landmarks: {
      for (final entry in specs.entries)
        entry.key: PoseLandmark(
          type: entry.key,
          x: entry.value.x * 1080,
          y: entry.value.y * 1920,
          z: 0,
          likelihood: entry.value.likelihood,
        ),
    },
  );
}
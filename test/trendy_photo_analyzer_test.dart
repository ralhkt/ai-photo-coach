import 'package:ai_photo_coach/features/pose/data/seated_phone_template_pose.dart';
import 'package:ai_photo_coach/features/pose/data/trendy_template_catalog.dart';
import 'package:ai_photo_coach/features/pose/models/pose_point3d.dart';
import 'package:ai_photo_coach/features/pose/services/trendy_photo_analyzer.dart';
import 'package:ai_photo_coach/features/reference/services/trendy_photo_template_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

void main() {
  const imageWidth = 1080;
  const imageHeight = 1920;

  final template = trendyTemplateCatalog['checkin_cafe']!;
  final analyzer = TrendyPhotoAnalyzer(template: template);

  group('normalizeAndAlign + similarity', () {
    test('perfect match scores >= 95', () {
      final pose = _buildPose({
        for (final point in seatedPhoneTemplatePose)
          point.type!: _Lm(point.x, point.y),
      });

      expect(
        analyzer.calculatePoseSimilarity(
          pose,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
        ),
        greaterThanOrEqualTo(95),
      );
    });
  });

  group('generateBodyPartGuidance', () {
    test('flags misaligned arm with specific hint', () {
      final pose = _buildPose({
        for (final point in seatedPhoneTemplatePose)
          point.type!: _Lm(point.x, point.y),
        PoseLandmarkType.leftWrist: const _Lm(0.05, 0.80),
      });

      final hint = analyzer.generateBodyPartGuidance(
        userPose: pose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );

      expect(hint, isNot('OK'));
      expect(hint, contains('手'));
    });
  });

  group('evaluate', () {
    test('prioritizes body part hint when proportion and level are OK', () {
      final pose = _buildPose({
        for (final point in seatedPhoneTemplatePose)
          point.type!: _Lm(point.x, point.y),
        PoseLandmarkType.rightWrist: const _Lm(0.95, 0.75),
        PoseLandmarkType.leftWrist: const _Lm(0.05, 0.75),
        PoseLandmarkType.rightElbow: const _Lm(0.88, 0.55),
      });

      final result = analyzer.evaluate(
        pose: pose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        rollAngle: 0,
      );

      expect(result.proportionStatus, 'OK');
      expect(result.isLevel, isTrue);
      expect(result.poseMatched, isFalse);
      expect(result.bodyPartGuidance, isNot('OK'));
      expect(result.combinedGuidance, result.bodyPartGuidance);
    });

    test('includes shooting tips when pose matched', () {
      final pose = _buildPose({
        for (final point in seatedPhoneTemplatePose)
          point.type!: _Lm(point.x, point.y, likelihood: 0.95),
      });

      final result = analyzer.evaluate(
        pose: pose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        rollAngle: 0,
      );

      expect(result.poseMatched, isTrue);
      expect(result.combinedGuidance, contains(template.shootingTips));
    });
  });

  group('parseTrendyPhotoTemplateJson', () {
    test('parses crawler JSON payload', () {
      const raw = '''
{"scene_type":"海灘夕陽","composition":"低角度仰拍","tags":["顯腿長"],
"shooting_tips":"手機貼近沙灘仰拍","template_poses_3d":[
{"type":"nose","x":0.5,"y":0.3,"z":0,"likelihood":0.9}],
"confidence":0.88,"pose_summary":"側身迎夕陽"}
''';

      final parsed = parseTrendyPhotoTemplateJson(raw, id: 'beach_01');

      expect(parsed.sceneType, '海灘夕陽');
      expect(parsed.tags, contains('顯腿長'));
      expect(parsed.templatePoses3d, hasLength(1));
      expect(parsed.templatePoses3d.first.type, PoseLandmarkType.nose);
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
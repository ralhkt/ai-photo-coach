import 'dart:typed_data';

import 'package:ai_photo_coach/features/ml/services/heuristic_vision_analyzer.dart';
import 'package:ai_photo_coach/features/ml/services/ml_aesthetic_scorer.dart';
import 'package:ai_photo_coach/features/ml/services/pose_body_guide_mapper.dart';
import 'package:ai_photo_coach/features/reference/services/image_analyzer_service.dart';
import 'package:ai_photo_coach/models/ml_detection_result.dart';
import 'package:ai_photo_coach/models/scene_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image/image.dart' as img;

void main() {
  test('aesthetic scorer returns higher score for positive labels', () {
    final scorer = MlAestheticScorer();
    final score = scorer.scoreFromLabels(const [
      MlSceneLabel(text: 'Portrait', confidence: 0.9),
      MlSceneLabel(text: 'Smile', confidence: 0.8),
    ]);

    expect(score, isNotNull);
    expect(score!, greaterThan(0.6));
  });

  test('pose mapper returns null when required landmarks are missing', () {
    final mapper = PoseBodyGuideMapper();
    final pose = Pose(landmarks: {
      PoseLandmarkType.nose: PoseLandmark(
        type: PoseLandmarkType.nose,
        x: 100,
        y: 100,
        z: 0,
        likelihood: 0.9,
      ),
    });

    expect(
      mapper.fromPose(pose, imageWidth: 400, imageHeight: 600),
      isNull,
    );
  });

  test('image analyzer attaches heuristic ml fallback on desktop tests', () async {
    final image = img.Image(width: 800, height: 1000);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final inSubject = x > 300 && x < 500 && y > 120 && y < 900;
        image.setPixel(
          x,
          y,
          inSubject
              ? img.ColorRgb8(210, 170, 150)
              : img.ColorRgb8(30, 35, 45),
        );
      }
    }

    final service = ImageAnalyzerService(
      visionAnalyzer: HeuristicVisionAnalyzer(),
    );
    final result = await service.analyze(
      Uint8List.fromList(img.encodeJpg(image)),
      userSceneType: SceneType.portrait,
    );

    expect(result.mlDetection, isNotNull);
    expect(result.mlDetection!.source, 'heuristic_fallback');
  });
}
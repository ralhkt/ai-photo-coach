import 'dart:typed_data';
import 'dart:ui';

import 'package:ai_photo_coach/features/reference/services/gemini_vision_response.dart';
import 'package:ai_photo_coach/models/camera_guidance.dart';
import 'package:ai_photo_coach/models/composition_overlay_type.dart';
import 'package:ai_photo_coach/models/photo_analysis_result.dart';
import 'package:ai_photo_coach/models/photo_frame_template.dart';
import 'package:ai_photo_coach/models/subject_shape_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseGeminiVisionJson extracts coaching payload', () {
    const raw = '''
Here is the analysis:
{
  "scene_summary": "咖啡廳窗邊自然光人像。",
  "pose_description": "側坐，單手舉手機至臉側。",
  "framing_hint_key": "hintFramingCenter",
  "exposure_hint_key": "hintExposureBrighten",
  "distance_hint_key": "hintDistanceGood",
  "angle_hint_key": "hintAngleLevel",
  "mood_key": "insightMoodSoft",
  "confidence": 0.82,
  "tips": ["保留頭頂留白", "將手機略抬高"]
}
''';

    final payload = parseGeminiVisionJson(raw);

    expect(payload.sceneSummary, contains('咖啡廳'));
    expect(payload.framingHintKey, 'hintFramingCenter');
    expect(payload.tips, hasLength(2));
    expect(payload.confidence, closeTo(0.82, 0.01));
  });

  test('applyGeminiVisionPayload updates guidance and insights', () {
    final base = PhotoAnalysisResult(
      sourceAspectRatio: 0.75,
      brightness: 0.5,
      subjectFillRatio: 0.2,
      recommendedFrame: PhotoFrameTemplate.portraitPost,
      guidance: CameraGuidance(
        frameTemplate: PhotoFrameTemplate.portraitPost,
        overlayType: CompositionOverlayType.ruleOfThirds,
        subjectTargetRect: Rect.fromLTWH(0.2, 0.2, 0.4, 0.6),
        suggestedZoom: 1,
        angleDegrees: 0,
        exposureEv: 0,
        framingHintKey: 'hintFramingCenter',
        exposureHintKey: 'hintExposureBalanced',
        distanceHintKey: 'hintDistanceGood',
        angleHintKey: 'hintAngleLevel',
        subjectShape: SubjectShapeKind.humanSilhouette,
      ),
      sceneTypeKey: 'scenePortrait',
      imageBytes: Uint8List.fromList([1, 2, 3]),
    );

    final enriched = applyGeminiVisionPayload(
      base,
      GeminiVisionPayload.fromJson({
        'scene_summary': '霓虹夜景人像。',
        'pose_description': '身體微側，面向光源。',
        'framing_hint_key': 'hintFramingLeft',
        'exposure_hint_key': 'hintExposureDarken',
        'distance_hint_key': 'hintDistanceCloser',
        'angle_hint_key': 'hintAngleLower',
        'mood_key': 'insightMoodDramatic',
        'confidence': 0.9,
        'tips': ['降低曝光保護高光'],
      }),
    );

    expect(enriched.guidance.framingHintKey, 'hintFramingLeft');
    expect(enriched.deepInsights?.analysisSource, 'gemini_vision');
    expect(enriched.deepInsights?.detailedTips.first, contains('霓虹'));
  });
}
import 'dart:convert';

import '../../../models/camera_guidance.dart';
import '../../../models/deep_photo_insights.dart';
import '../../../models/photo_analysis_result.dart';

/// Parsed JSON payload from Gemini vision coaching.
class GeminiVisionPayload {
  const GeminiVisionPayload({
    required this.sceneSummary,
    required this.poseDescription,
    required this.framingHintKey,
    required this.exposureHintKey,
    required this.distanceHintKey,
    required this.angleHintKey,
    required this.tips,
    required this.confidence,
    required this.moodKey,
  });

  final String sceneSummary;
  final String poseDescription;
  final String framingHintKey;
  final String exposureHintKey;
  final String distanceHintKey;
  final String angleHintKey;
  final List<String> tips;
  final double confidence;
  final String moodKey;

  factory GeminiVisionPayload.fromJson(Map<String, dynamic> json) {
    final tipsRaw = json['tips'];
    final tips = tipsRaw is List
        ? tipsRaw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
        : <String>[];

    return GeminiVisionPayload(
      sceneSummary: json['scene_summary']?.toString() ?? '',
      poseDescription: json['pose_description']?.toString() ?? '',
      framingHintKey: _hintKey(
        json['framing_hint_key'],
        fallback: 'hintFramingCenter',
      ),
      exposureHintKey: _hintKey(
        json['exposure_hint_key'],
        fallback: 'hintExposureBalanced',
      ),
      distanceHintKey: _hintKey(
        json['distance_hint_key'],
        fallback: 'hintDistanceGood',
      ),
      angleHintKey: _hintKey(
        json['angle_hint_key'],
        fallback: 'hintAngleLevel',
      ),
      tips: tips,
      confidence: _clamp01(json['confidence']),
      moodKey: json['mood_key']?.toString() ?? 'insightMoodNatural',
    );
  }

  static String _hintKey(Object? value, {required String fallback}) {
    const allowed = {
      'hintFramingLeft',
      'hintFramingRight',
      'hintFramingHigh',
      'hintFramingLow',
      'hintFramingCenter',
      'hintExposureBrighten',
      'hintExposureDarken',
      'hintExposureBalanced',
      'hintDistanceCloser',
      'hintDistanceFurther',
      'hintDistanceGood',
      'hintAngleLower',
      'hintAngleHigher',
      'hintAngleLevel',
    };
    final key = value?.toString() ?? '';
    return allowed.contains(key) ? key : fallback;
  }

  static double _clamp01(Object? value) {
    if (value is num) {
      return value.toDouble().clamp(0.0, 1.0);
    }
    return 0.75;
  }
}

GeminiVisionPayload parseGeminiVisionJson(String raw) {
  final trimmed = raw.trim();
  final jsonStart = trimmed.indexOf('{');
  final jsonEnd = trimmed.lastIndexOf('}');
  if (jsonStart < 0 || jsonEnd <= jsonStart) {
    throw const FormatException('Gemini response missing JSON object');
  }
  final decoded = jsonDecode(trimmed.substring(jsonStart, jsonEnd + 1));
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Gemini response JSON must be an object');
  }
  return GeminiVisionPayload.fromJson(decoded);
}

PhotoAnalysisResult applyGeminiVisionPayload(
  PhotoAnalysisResult base,
  GeminiVisionPayload payload, {
  String analysisSource = 'gemini_vision',
}) {
  final guidance = base.guidance;
  final mergedTips = <String>[
    if (payload.sceneSummary.isNotEmpty) payload.sceneSummary,
    if (payload.poseDescription.isNotEmpty) payload.poseDescription,
    ...payload.tips,
  ];

  final prior = base.deepInsights;
  final insights = DeepPhotoInsights(
    contrastScore: prior?.contrastScore ?? 0.5,
    colorTemperatureKey: prior?.colorTemperatureKey ?? 'insightColorNeutral',
    lightingDirectionKey: prior?.lightingDirectionKey ?? 'insightLightingEven',
    compositionBalanceKey:
        prior?.compositionBalanceKey ?? 'insightBalanceCentered',
    moodKey: payload.moodKey,
    depthHintKey: prior?.depthHintKey ?? 'insightDepthModerate',
    confidence: payload.confidence,
    detailedTips: mergedTips.isEmpty
        ? (prior?.detailedTips ?? const [])
        : mergedTips,
    analysisSource: analysisSource,
  );

  return PhotoAnalysisResult(
    sourceAspectRatio: base.sourceAspectRatio,
    brightness: base.brightness,
    subjectFillRatio: base.subjectFillRatio,
    recommendedFrame: base.recommendedFrame,
    guidance: CameraGuidance(
      frameTemplate: guidance.frameTemplate,
      overlayType: guidance.overlayType,
      subjectTargetRect: guidance.subjectTargetRect,
      suggestedZoom: guidance.suggestedZoom,
      angleDegrees: guidance.angleDegrees,
      exposureEv: guidance.exposureEv,
      framingHintKey: payload.framingHintKey,
      exposureHintKey: payload.exposureHintKey,
      distanceHintKey: payload.distanceHintKey,
      angleHintKey: payload.angleHintKey,
      subjectShape: guidance.subjectShape,
      subjectSilhouettePoints: guidance.subjectSilhouettePoints,
      bodyPartGuides: guidance.bodyPartGuides,
    ),
    sceneTypeKey: base.sceneTypeKey,
    imageBytes: base.imageBytes,
    userSceneType: base.userSceneType,
    deepInsights: insights,
    mlDetection: base.mlDetection,
    matchedReferenceSampleId: base.matchedReferenceSampleId,
    matchedReferenceTitleKey: base.matchedReferenceTitleKey,
    matchedReferenceImageBytes: base.matchedReferenceImageBytes,
    exif: base.exif,
    subjectDetectionReliable: base.subjectDetectionReliable,
  );
}
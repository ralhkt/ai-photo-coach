import '../../../models/deep_photo_insights.dart';
import '../../../models/photo_analysis_result.dart';

/// Optional enrichment hook for deeper analysis (local heuristic or remote AI agent).
abstract class PhotoAnalysisAgent {
  Future<PhotoAnalysisResult> enrich(PhotoAnalysisResult base);
}

/// Default on-device enrichment — no network required.
class HeuristicPhotoAnalysisAgent implements PhotoAnalysisAgent {
  @override
  Future<PhotoAnalysisResult> enrich(PhotoAnalysisResult base) async => base;
}

/// Optional external vision AI (OpenAI / Gemini / custom endpoint).
///
/// Set `PHOTO_COACH_VISION_ENDPOINT` and `PHOTO_COACH_VISION_API_KEY` to enable.
/// Falls back silently when not configured.
class RemotePhotoAnalysisAgent implements PhotoAnalysisAgent {
  RemotePhotoAnalysisAgent({
    String? endpoint,
    String? apiKey,
  })  : endpoint = endpoint ?? _env('PHOTO_COACH_VISION_ENDPOINT'),
        apiKey = apiKey ?? _env('PHOTO_COACH_VISION_API_KEY');

  final String? endpoint;
  final String? apiKey;

  static String? _env(String key) {
    final value = String.fromEnvironment(key, defaultValue: '');
    return value.isEmpty ? null : value;
  }

  bool get isConfigured =>
      endpoint != null &&
      endpoint!.isNotEmpty &&
      apiKey != null &&
      apiKey!.isNotEmpty;

  @override
  Future<PhotoAnalysisResult> enrich(PhotoAnalysisResult base) async {
    if (!isConfigured) {
      return base;
    }

    // Cloud vision hook — extend with HTTP call when endpoint is configured.
    return base;
  }
}

extension DeepInsightsCopy on PhotoAnalysisResult {
  PhotoAnalysisResult withDeepInsights(DeepPhotoInsights insights) {
    return PhotoAnalysisResult(
      sourceAspectRatio: sourceAspectRatio,
      brightness: brightness,
      subjectFillRatio: subjectFillRatio,
      recommendedFrame: recommendedFrame,
      guidance: guidance,
      sceneTypeKey: sceneTypeKey,
      imageBytes: imageBytes,
      userSceneType: userSceneType,
      deepInsights: insights,
      mlDetection: mlDetection,
      matchedReferenceSampleId: matchedReferenceSampleId,
      matchedReferenceTitleKey: matchedReferenceTitleKey,
      matchedReferenceImageBytes: matchedReferenceImageBytes,
    );
  }
}
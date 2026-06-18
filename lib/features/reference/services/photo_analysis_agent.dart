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

/// Placeholder for external AI agent integration (GPT-4V, Gemini Vision, etc.).
///
/// Enable by providing an API endpoint and wiring this agent in
/// [ImageAnalyzerService] when cloud analysis is desired.
class RemotePhotoAnalysisAgent implements PhotoAnalysisAgent {
  RemotePhotoAnalysisAgent({required this.endpoint, this.apiKey});

  final String endpoint;
  final String? apiKey;

  @override
  Future<PhotoAnalysisResult> enrich(PhotoAnalysisResult base) async {
    // Cloud agent not configured in MVP — return base result unchanged.
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
    );
  }
}
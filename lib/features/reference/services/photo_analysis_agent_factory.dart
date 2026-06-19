import '../../../core/config/vision_api_config.dart';
import 'gemini_vision_analysis_agent.dart';
import 'openrouter_vision_analysis_agent.dart';
import 'photo_analysis_agent.dart';

PhotoAnalysisAgent createPhotoAnalysisAgent() {
  switch (VisionApiConfig.provider) {
    case VisionProvider.openrouter:
      final key = VisionApiConfig.openRouterApiKey;
      if (key != null) {
        return ResilientPhotoAnalysisAgent(
          primary: OpenRouterVisionAnalysisAgent(apiKey: key),
        );
      }
      break;
    case VisionProvider.proxy:
      if (VisionApiConfig.isProxyConfigured) {
        return ResilientPhotoAnalysisAgent(
          primary: GeminiVisionAnalysisAgent(
            apiKey: VisionApiConfig.geminiApiKey,
          ),
        );
      }
      break;
    case VisionProvider.gemini:
      final geminiKey = VisionApiConfig.geminiApiKey;
      if (geminiKey != null || VisionApiConfig.geminiBaseUrl.isNotEmpty) {
        return ResilientPhotoAnalysisAgent(
          primary: GeminiVisionAnalysisAgent(apiKey: geminiKey),
        );
      }
      break;
  }
  return HeuristicPhotoAnalysisAgent();
}
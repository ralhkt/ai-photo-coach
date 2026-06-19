import 'package:ai_photo_coach/features/reference/services/gemini_vision_analysis_agent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeminiVisionAnalysisAgent.buildRequestUri', () {
    test('uses default Google host with API key query', () {
      final agent = GeminiVisionAnalysisAgent(
        apiKey: 'test-key',
        model: 'gemini-2.0-flash',
      );

      final uri = agent.buildRequestUri();

      expect(uri.host, 'generativelanguage.googleapis.com');
      expect(uri.path, '/v1beta/models/gemini-2.0-flash:generateContent');
      expect(uri.queryParameters['key'], 'test-key');
    });

    test('uses custom base URL for regional proxy', () {
      final agent = GeminiVisionAnalysisAgent(
        apiKey: 'test-key',
        model: 'gemini-2.0-flash',
        baseUrl: 'https://proxy.example.workers.dev',
      );

      final uri = agent.buildRequestUri();

      expect(uri.toString(),
          'https://proxy.example.workers.dev/v1beta/models/gemini-2.0-flash:generateContent?key=test-key');
    });

    test('uses full proxy endpoint without client API key', () {
      final agent = GeminiVisionAnalysisAgent(
        endpointUrl: 'https://proxy.example.workers.dev/gemini',
      );

      final uri = agent.buildRequestUri();

      expect(uri.toString(), 'https://proxy.example.workers.dev/gemini');
    });
  });
}
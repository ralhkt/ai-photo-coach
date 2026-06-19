import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/vision_api_config.dart';
import '../../../models/photo_analysis_result.dart';
import 'gemini_vision_response.dart';
import 'photo_analysis_agent.dart';
import 'vision_coaching_prompt.dart';
import 'vision_request_image.dart';

/// Routes vision coaching through OpenRouter (works when direct Gemini is geo-blocked).
class OpenRouterVisionAnalysisAgent implements PhotoAnalysisAgent {
  OpenRouterVisionAnalysisAgent({
    required this.apiKey,
    this.model = VisionApiConfig.openRouterModel,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String apiKey;
  final String model;
  final http.Client _client;

  static final _endpoint = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

  @override
  Future<PhotoAnalysisResult> enrich(PhotoAnalysisResult base) async {
    final visionBytes = bytesForVisionRequest(base.imageBytes);
    final imageDataUrl =
        'data:image/jpeg;base64,${base64Encode(visionBytes)}';

    final body = jsonEncode({
      'model': model,
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': visionCoachingPrompt},
            {
              'type': 'image_url',
              'image_url': {'url': imageDataUrl},
            },
          ],
        },
      ],
      'temperature': 0.35,
      'response_format': {'type': 'json_object'},
    });

    final response = await _client
        .post(
          _endpoint,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
            'HTTP-Referer': 'https://github.com/ralhkt/ai-photo-coach',
            'X-Title': 'AI Photo Coach',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      debugPrint(
        'OpenRouterVisionAnalysisAgent: HTTP ${response.statusCode} ${response.body}',
      );
      throw StateError('OpenRouter vision request failed (${response.statusCode})');
    }

    final text = _extractText(response.body);
    final payload = parseGeminiVisionJson(text);
    return applyGeminiVisionPayload(
      base,
      payload,
      analysisSource: 'openrouter_vision',
    );
  }

  String _extractText(String responseBody) {
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid OpenRouter envelope');
    }

    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const FormatException('OpenRouter returned no choices');
    }

    final first = choices.first;
    if (first is! Map<String, dynamic>) {
      throw const FormatException('Invalid OpenRouter choice');
    }

    final message = first['message'];
    if (message is! Map<String, dynamic>) {
      throw const FormatException('Invalid OpenRouter message');
    }

    final content = message['content']?.toString().trim() ?? '';
    if (content.isEmpty) {
      throw const FormatException('OpenRouter returned empty content');
    }
    return content;
  }
}
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/vision_api_config.dart';
import '../../../models/photo_analysis_result.dart';
import 'gemini_vision_response.dart';
import 'photo_analysis_agent.dart';
import 'vision_coaching_prompt.dart';
import 'vision_request_image.dart';

/// Calls Google Gemini vision (or a regional proxy) to enrich photo analysis.
class GeminiVisionAnalysisAgent implements PhotoAnalysisAgent {
  GeminiVisionAnalysisAgent({
    this.apiKey,
    this.model = VisionApiConfig.geminiModel,
    String? baseUrl,
    String? endpointUrl,
    String? proxyAuthToken,
    http.Client? client,
  })  : baseUrl = baseUrl ?? VisionApiConfig.geminiBaseUrl,
        endpointUrl = endpointUrl ?? VisionApiConfig.geminiProxyUrl,
        proxyAuthToken = proxyAuthToken ?? VisionApiConfig.proxyAuthToken,
        _client = client ?? http.Client();

  final String? apiKey;
  final String model;
  final String baseUrl;
  final String endpointUrl;
  final String? proxyAuthToken;
  final http.Client _client;

  @visibleForTesting
  Uri buildRequestUri() {
    if (endpointUrl.isNotEmpty) {
      return Uri.parse(endpointUrl);
    }

    final path = '/v1beta/models/$model:generateContent';
    final query = apiKey != null && apiKey!.isNotEmpty ? {'key': apiKey!} : null;

    if (baseUrl.isNotEmpty) {
      final parsed = Uri.parse(baseUrl);
      if (!parsed.hasScheme) {
        return Uri.https(baseUrl, path, query);
      }
      return parsed.replace(
        path: _joinPath(parsed.path, path),
        queryParameters: query ?? parsed.queryParameters,
      );
    }

    return Uri.https('generativelanguage.googleapis.com', path, query);
  }

  static String _joinPath(String basePath, String suffix) {
    final normalizedBase =
        basePath.endsWith('/') ? basePath.substring(0, basePath.length - 1) : basePath;
    final normalizedSuffix = suffix.startsWith('/') ? suffix : '/$suffix';
    if (normalizedBase.isEmpty) {
      return normalizedSuffix;
    }
    return '$normalizedBase$normalizedSuffix';
  }

  @override
  Future<PhotoAnalysisResult> enrich(PhotoAnalysisResult base) async {
    final uri = buildRequestUri();
    final visionBytes = bytesForVisionRequest(base.imageBytes);

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': visionCoachingPrompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Encode(visionBytes),
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.35,
        'responseMimeType': 'application/json',
      },
    });

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (proxyAuthToken != null && proxyAuthToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $proxyAuthToken';
    }

    final response = await _client
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      debugPrint(
        'GeminiVisionAnalysisAgent: HTTP ${response.statusCode} ${response.body}',
      );
      throw StateError('Gemini vision request failed (${response.statusCode})');
    }

    final text = _extractText(response.body);
    final payload = parseGeminiVisionJson(text);
    return applyGeminiVisionPayload(
      base,
      payload,
      analysisSource: endpointUrl.isNotEmpty ? 'gemini_proxy' : 'gemini_vision',
    );
  }

  String _extractText(String responseBody) {
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid Gemini envelope');
    }

    final candidates = decoded['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const FormatException('Gemini returned no candidates');
    }

    final first = candidates.first;
    if (first is! Map<String, dynamic>) {
      throw const FormatException('Invalid Gemini candidate');
    }

    final content = first['content'];
    if (content is! Map<String, dynamic>) {
      throw const FormatException('Invalid Gemini content');
    }

    final parts = content['parts'];
    if (parts is! List || parts.isEmpty) {
      throw const FormatException('Invalid Gemini parts');
    }

    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is Map<String, dynamic> && part['text'] != null) {
        buffer.write(part['text']);
      }
    }

    final text = buffer.toString().trim();
    if (text.isEmpty) {
      throw const FormatException('Gemini returned empty text');
    }
    return text;
  }
}

/// Tries cloud enrichment; silently keeps on-device result when unavailable.
class ResilientPhotoAnalysisAgent implements PhotoAnalysisAgent {
  ResilientPhotoAnalysisAgent({
    required PhotoAnalysisAgent primary,
    PhotoAnalysisAgent? fallback,
  })  : _primary = primary,
        _fallback = fallback ?? HeuristicPhotoAnalysisAgent();

  final PhotoAnalysisAgent _primary;
  final PhotoAnalysisAgent _fallback;

  @override
  Future<PhotoAnalysisResult> enrich(PhotoAnalysisResult base) async {
    try {
      return await _primary.enrich(base);
    } catch (error, stackTrace) {
      debugPrint('ResilientPhotoAnalysisAgent: $error');
      debugPrint('$stackTrace');
      return _fallback.enrich(base);
    }
  }
}
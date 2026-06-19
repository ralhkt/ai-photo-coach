import 'dart:convert';

import '../../pose/models/trendy_photo_template.dart';

/// Parses Gemini / OpenRouter JSON for trendy template ingestion.
TrendyPhotoTemplate parseTrendyPhotoTemplateJson(
  String raw, {
  String id = 'crawler',
}) {
  final trimmed = raw.trim();
  final jsonStart = trimmed.indexOf('{');
  final jsonEnd = trimmed.lastIndexOf('}');
  if (jsonStart < 0 || jsonEnd <= jsonStart) {
    throw const FormatException('Trendy template response missing JSON object');
  }

  final decoded = jsonDecode(trimmed.substring(jsonStart, jsonEnd + 1));
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Trendy template JSON must be an object');
  }

  decoded.putIfAbsent('id', () => id);
  return TrendyPhotoTemplate.fromJson(decoded);
}
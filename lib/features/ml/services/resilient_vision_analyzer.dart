import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../../../models/ml_detection_result.dart';
import 'heuristic_vision_analyzer.dart';
import 'ml_kit_vision_analyzer.dart';
import 'vision_analyzer.dart';

/// Runs ML Kit when available; falls back to heuristics on any failure.
class ResilientVisionAnalyzer implements VisionAnalyzer {
  ResilientVisionAnalyzer({
    VisionAnalyzer? primary,
    VisionAnalyzer? fallback,
  })  : _primary = primary ?? MlKitVisionAnalyzer(),
        _fallback = fallback ?? HeuristicVisionAnalyzer();

  final VisionAnalyzer _primary;
  final VisionAnalyzer _fallback;

  @override
  Future<MlDetectionResult> analyze({
    required Uint8List bytes,
    required int width,
    required int height,
  }) async {
    try {
      return await _primary.analyze(
        bytes: bytes,
        width: width,
        height: height,
      );
    } catch (error, stackTrace) {
      debugPrint('ResilientVisionAnalyzer: primary failed: $error');
      debugPrint('$stackTrace');
      return _fallback.analyze(bytes: bytes, width: width, height: height);
    }
  }

  @override
  Future<void> dispose() async {
    await _primary.dispose();
    await _fallback.dispose();
  }
}
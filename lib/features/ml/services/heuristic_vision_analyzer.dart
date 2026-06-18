import 'dart:typed_data';

import '../../../models/ml_detection_result.dart';
import 'vision_analyzer.dart';

/// Fallback when ML Kit is unavailable (desktop tests, web, CI).
class HeuristicVisionAnalyzer implements VisionAnalyzer {
  @override
  Future<MlDetectionResult> analyze({
    required Uint8List bytes,
    required int width,
    required int height,
  }) async {
    return const MlDetectionResult(
      source: 'heuristic_fallback',
      inferenceMs: 0,
    );
  }

  @override
  Future<void> dispose() async {}
}
import 'dart:typed_data';

import 'package:ai_photo_coach/features/ml/services/heuristic_vision_analyzer.dart';
import 'package:ai_photo_coach/features/ml/services/resilient_vision_analyzer.dart';
import 'package:ai_photo_coach/features/ml/services/vision_analyzer.dart';
import 'package:ai_photo_coach/models/ml_detection_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resilient analyzer falls back when primary throws', () async {
    final analyzer = ResilientVisionAnalyzer(
      primary: _ThrowingVisionAnalyzer(),
      fallback: HeuristicVisionAnalyzer(),
    );

    final result = await analyzer.analyze(
      bytes: Uint8List.fromList(const [1, 2, 3]),
      width: 10,
      height: 10,
    );

    expect(result.source, 'heuristic_fallback');
    await analyzer.dispose();
  });
}

class _ThrowingVisionAnalyzer implements VisionAnalyzer {
  @override
  Future<MlDetectionResult> analyze({
    required Uint8List bytes,
    required int width,
    required int height,
  }) async {
    throw StateError('ml unavailable');
  }

  @override
  Future<void> dispose() async {}
}
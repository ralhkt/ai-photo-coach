import 'dart:typed_data';
import 'dart:ui';

import 'package:ai_photo_coach/features/ml/services/vision_analyzer.dart';
import 'package:ai_photo_coach/models/ml_detection_result.dart';

/// Simulates on-device ML Kit finding a centered portrait subject in tests.
class FakeMlVisionAnalyzer implements VisionAnalyzer {
  const FakeMlVisionAnalyzer({
    this.primarySubjectRect = const Rect.fromLTWH(0.35, 0.15, 0.3, 0.75),
  });

  final Rect primarySubjectRect;

  @override
  Future<MlDetectionResult> analyze({
    required Uint8List bytes,
    required int width,
    required int height,
  }) async {
    return MlDetectionResult(
      source: 'ml_kit',
      inferenceMs: 5,
      faceBounds: [
        Rect.fromLTWH(
          primarySubjectRect.left,
          primarySubjectRect.top,
          primarySubjectRect.width,
          primarySubjectRect.height * 0.25,
        ),
      ],
      primarySubjectRect: primarySubjectRect,
      faceCount: 1,
    );
  }

  @override
  Future<void> dispose() async {}
}
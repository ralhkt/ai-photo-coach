import 'dart:typed_data';

import '../../../models/ml_detection_result.dart';

/// On-device vision analysis (ML Kit on mobile, heuristic fallback elsewhere).
abstract class VisionAnalyzer {
  Future<MlDetectionResult> analyze({
    required Uint8List bytes,
    required int width,
    required int height,
  });

  Future<void> dispose();
}
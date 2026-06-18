import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/vision_analyzer.dart';
import '../services/vision_analyzer_factory.dart';

final visionAnalyzerProvider = Provider<VisionAnalyzer>((ref) {
  final analyzer = createVisionAnalyzer();
  ref.onDispose(() {
    analyzer.dispose();
  });
  return analyzer;
});
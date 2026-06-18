import 'dart:io';

import 'package:flutter/foundation.dart';

import 'heuristic_vision_analyzer.dart';
import 'ml_kit_vision_analyzer.dart';
import 'vision_analyzer.dart';

VisionAnalyzer createVisionAnalyzer() {
  if (kIsWeb) {
    return HeuristicVisionAnalyzer();
  }

  if (Platform.isAndroid || Platform.isIOS) {
    return MlKitVisionAnalyzer();
  }

  return HeuristicVisionAnalyzer();
}
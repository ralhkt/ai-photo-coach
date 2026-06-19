import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import '../data/reference_sample_catalog.dart';
import '../../ml/services/heuristic_vision_analyzer.dart';
import 'image_analyzer_service.dart';
import '../../../models/photo_analysis_result.dart';

/// Lazily analyzes bundled reference samples once for pose / framing reuse.
class ReferenceGuidanceCache {
  ReferenceGuidanceCache({ImageAnalyzerService? analyzer})
      : _analyzer = analyzer ??
            ImageAnalyzerService(visionAnalyzer: HeuristicVisionAnalyzer());

  final ImageAnalyzerService _analyzer;
  final Map<String, PhotoAnalysisResult> _cache = {};

  Future<PhotoAnalysisResult> get(String sampleId) async {
    final cached = _cache[sampleId];
    if (cached != null) {
      return cached;
    }

    final sample = referenceSampleCatalog.firstWhere(
      (entry) => entry.id == sampleId,
    );
    final data = await rootBundle.load(sample.assetPath);
    final bytes = data.buffer.asUint8List();

    final result = await _analyzer.analyze(
      bytes,
      userSceneType: sample.sceneType,
    );

    _cache[sampleId] = result;
    return result;
  }

  void clear() => _cache.clear();
}
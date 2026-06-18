import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

import '../../../core/performance/performance_budget.dart';
import '../../../core/performance/performance_tracker.dart';
import '../../../core/utils/image_downscaler.dart';
import '../../ml/providers/ml_providers.dart';
import '../../ml/services/nima_like_scorer.dart';
import '../../ml/services/vision_analyzer.dart';

final quickPhotoScorerProvider = Provider<QuickPhotoScorer>((ref) {
  return QuickPhotoScorer(
    visionAnalyzer: ref.watch(visionAnalyzerProvider),
    tracker: ref.watch(performanceTrackerProvider),
    nimaScorer: NimaLikeScorer(),
  );
});

class QuickPhotoScore {
  const QuickPhotoScore({
    required this.brightness,
    required this.aestheticScore,
    required this.analysisMs,
    required this.thumbnailBytes,
  });

  final double brightness;
  final double aestheticScore;
  final int analysisMs;
  final Uint8List thumbnailBytes;
}

class QuickPhotoScorer {
  QuickPhotoScorer({
    required this.visionAnalyzer,
    required this.tracker,
    required this.nimaScorer,
    this.downscaleMaxSide = 480,
    this.skipMlWhenPowerSave = true,
  });

  final VisionAnalyzer visionAnalyzer;
  final PerformanceTracker tracker;
  final NimaLikeScorer nimaScorer;
  final int downscaleMaxSide;
  final bool skipMlWhenPowerSave;

  Future<QuickPhotoScore> score(
    Uint8List bytes, {
    bool powerSave = false,
  }) async {
    final stopwatch = Stopwatch()..start();
    final downscaled = ImageDownscaler.downscale(
      bytes,
      maxSide: downscaleMaxSide,
    );

    final decoded = img.decodeImage(downscaled);
    if (decoded == null) {
      return QuickPhotoScore(
        brightness: 0.5,
        aestheticScore: 0.5,
        analysisMs: stopwatch.elapsedMilliseconds,
        thumbnailBytes: downscaled,
      );
    }

    final brightness = _averageBrightness(decoded);
    final lumaSamples = <int>[];
    const step = 6;
    for (var y = 0; y < decoded.height; y += step) {
      for (var x = 0; x < decoded.width; x += step) {
        final pixel = decoded.getPixel(x, y);
        lumaSamples.add(img.getLuminance(pixel).round());
      }
    }
    final contrast = nimaScorer.contrastFromLumaSamples(lumaSamples);

    double? mlScore;
    if (!powerSave || !skipMlWhenPowerSave) {
      final ml = await visionAnalyzer.analyze(
        bytes: downscaled,
        width: decoded.width,
        height: decoded.height,
      );
      mlScore = ml.aestheticScore;
      tracker.record(
        'ml_inference_quick',
        stopwatch.elapsedMilliseconds,
        budgetMs: PerformanceBudget.mlInferenceMs,
      );
    }

    final aesthetic = nimaScorer.score(
      brightness: brightness,
      contrast: contrast,
      mlAestheticScore: mlScore,
    );

    final elapsed = stopwatch.elapsedMilliseconds;
    tracker.record(
      'session_photo_quick',
      elapsed,
      budgetMs: PerformanceBudget.sessionPhotoAnalysisMs,
    );

    return QuickPhotoScore(
      brightness: brightness,
      aestheticScore: aesthetic,
      analysisMs: elapsed,
      thumbnailBytes: downscaled,
    );
  }

  double _averageBrightness(img.Image image) {
    var total = 0.0;
    var count = 0;
    final step = 4;
    for (var y = 0; y < image.height; y += step) {
      for (var x = 0; x < image.width; x += step) {
        final pixel = image.getPixel(x, y);
        total += (img.getLuminance(pixel) / 255);
        count++;
      }
    }
    return count == 0 ? 0.5 : total / count;
  }
}
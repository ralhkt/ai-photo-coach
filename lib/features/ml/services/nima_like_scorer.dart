import 'dart:math' as math;

/// Lightweight NIMA-inspired aesthetic score without a TFLite asset.
/// Combines exposure, contrast, and optional ML label score.
class NimaLikeScorer {
  double score({
    required double brightness,
    required double contrast,
    double? mlAestheticScore,
  }) {
    final exposureFit = 1 - (brightness - 0.52).abs().clamp(0.0, 0.5) * 2;
    final contrastFit = contrast.clamp(0.0, 1.0);
    var total = 0.35 + exposureFit * 0.25 + contrastFit * 0.2;

    if (mlAestheticScore != null) {
      total = total * 0.35 + mlAestheticScore * 0.65;
    }

    return total.clamp(0.2, 0.95);
  }

  double contrastFromLumaSamples(Iterable<int> lumaValues) {
    if (lumaValues.isEmpty) {
      return 0.4;
    }

    final values = lumaValues.toList();
    final mean = values.reduce((a, b) => a + b) / values.length;
    var variance = 0.0;
    for (final value in values) {
      final delta = value - mean;
      variance += delta * delta;
    }
    variance /= values.length;
    final stdDev = math.sqrt(variance);
    return (stdDev / 64).clamp(0.0, 1.0);
  }
}
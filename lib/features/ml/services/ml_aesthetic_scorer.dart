import '../../../models/ml_detection_result.dart';

/// Maps ML scene labels into a lightweight aesthetic score (0–1).
class MlAestheticScorer {
  double? scoreFromLabels(List<MlSceneLabel> labels) {
    if (labels.isEmpty) {
      return null;
    }

    const positive = {
      'portrait': 0.18,
      'smile': 0.12,
      'fashion': 0.10,
      'sunset': 0.14,
      'sky': 0.08,
      'flower': 0.10,
      'architecture': 0.08,
      'food': 0.06,
      'pet': 0.08,
      'beach': 0.10,
      'mountain': 0.10,
      'city': 0.06,
    };

    const negative = {
      'blur': -0.20,
      'darkness': -0.12,
      'noise': -0.15,
      'screenshot': -0.10,
    };

    var total = 0.55;
    var weight = 0.0;

    for (final label in labels) {
      final text = label.text.toLowerCase();
      for (final entry in positive.entries) {
        if (text.contains(entry.key)) {
          total += entry.value * label.confidence;
          weight += label.confidence;
        }
      }
      for (final entry in negative.entries) {
        if (text.contains(entry.key)) {
          total += entry.value * label.confidence;
          weight += label.confidence;
        }
      }
    }

    if (weight > 0) {
      total += (weight * 0.04);
    }

    return total.clamp(0.2, 0.95);
  }
}
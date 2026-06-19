import '../data/reference_sample_catalog.dart';
import '../../../models/photo_analysis_result.dart';
import '../../../models/scene_type.dart';

/// Picks the closest bundled lifestyle reference for a live scene analysis.
class SceneReferenceMatcherService {
  const SceneReferenceMatcherService();

  ReferenceSample match(PhotoAnalysisResult analysis) {
    final scores = <ReferenceSample, double>{};
    for (final sample in referenceSampleCatalog) {
      scores[sample] = _score(sample, analysis);
    }

    return scores.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  double _score(ReferenceSample sample, PhotoAnalysisResult analysis) {
    var score = 0.0;
    final sceneKey = analysis.sceneTypeKey;
    final brightness = analysis.brightness;
    final aspect = analysis.sourceAspectRatio;

    score += _sceneAffinity(sample.id, sceneKey);
    score += _brightnessAffinity(sample.id, brightness);
    score += _aspectAffinity(sample.id, aspect);

    if (brightness < 0.36) {
      score += sample.id == 'checkin_neon_city' ? 0.65 : -0.15;
    } else if (brightness > 0.68) {
      score += sample.id == 'checkin_beach_sunset' ? 0.35 : 0.0;
    }

    if (analysis.guidance.framingHintKey == 'hintFramingCenter') {
      if (sample.id == 'checkin_cafe' || sample.id == 'checkin_brunch') {
        score += 0.08;
      }
    }

    return score;
  }

  double _sceneAffinity(String sampleId, String sceneKey) {
    return switch (sampleId) {
      'checkin_travel_alps' =>
        sceneKey == 'sceneLandscape' ? 1.0 : 0.15,
      'checkin_neon_city' =>
        sceneKey == 'scenePortrait' ? 0.55 : 0.25,
      'checkin_beach_sunset' =>
        sceneKey == 'sceneLandscape' || sceneKey == 'sceneLifestyle'
            ? 0.65
            : 0.35,
      'checkin_street_portrait' =>
        sceneKey == 'scenePortrait' || sceneKey == 'sceneLifestyle'
            ? 0.7
            : 0.4,
      'checkin_cafe' || 'checkin_brunch' =>
        sceneKey == 'scenePortrait' || sceneKey == 'sceneLifestyle'
            ? 0.75
            : 0.3,
      _ => 0.2,
    };
  }

  double _brightnessAffinity(String sampleId, double brightness) {
    return switch (sampleId) {
      'checkin_neon_city' => brightness < 0.42 ? 0.9 : 0.1,
      'checkin_beach_sunset' =>
        brightness > 0.52 && brightness < 0.78 ? 0.85 : 0.2,
      'checkin_cafe' || 'checkin_brunch' =>
        brightness > 0.38 && brightness < 0.72 ? 0.8 : 0.25,
      'checkin_travel_alps' =>
        brightness > 0.45 && brightness < 0.85 ? 0.7 : 0.2,
      'checkin_street_portrait' => 0.55,
      _ => 0.2,
    };
  }

  double _aspectAffinity(String sampleId, double aspect) {
    final portrait = aspect < 0.92;
    final tallPortrait = aspect < 0.78;

    return switch (sampleId) {
      'checkin_street_portrait' || 'checkin_cafe' => portrait ? 0.7 : 0.2,
      'checkin_brunch' || 'checkin_beach_sunset' => tallPortrait ? 0.75 : 0.35,
      'checkin_travel_alps' => aspect > 0.7 && aspect < 1.1 ? 0.6 : 0.3,
      _ => 0.4,
    };
  }

  SceneType sceneTypeForSample(String sampleId) {
    return referenceSampleCatalog
        .firstWhere((sample) => sample.id == sampleId)
        .sceneType;
  }
}
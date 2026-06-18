import 'dart:math' as math;
import 'dart:ui';

import 'package:image/image.dart' as img;

import '../../../models/deep_photo_insights.dart';
import '../../../models/scene_type.dart';

class DeepAnalysisService {
  DeepPhotoInsights analyze({
    required img.Image image,
    required Rect subjectRect,
    required double brightness,
    required SceneType sceneType,
  }) {
    final sample = img.copyResize(image, width: 96);
    final contrast = _contrastScore(sample);
    final colorTempKey = _colorTemperatureKey(sample);
    final lightingKey = _lightingDirectionKey(sample, brightness);
    final balanceKey = _compositionBalanceKey(sample, subjectRect);
    final moodKey = _moodKey(brightness, contrast, colorTempKey);
    final depthKey = _depthHintKey(sample, subjectRect);
    final confidence = _confidence(sceneType, subjectRect);
    final tips = _buildTips(
      sceneType: sceneType,
      brightness: brightness,
      contrast: contrast,
      colorTempKey: colorTempKey,
      lightingKey: lightingKey,
      balanceKey: balanceKey,
      subjectRect: subjectRect,
    );

    return DeepPhotoInsights(
      contrastScore: contrast,
      colorTemperatureKey: colorTempKey,
      lightingDirectionKey: lightingKey,
      compositionBalanceKey: balanceKey,
      moodKey: moodKey,
      depthHintKey: depthKey,
      confidence: confidence,
      detailedTips: tips,
      analysisSource: 'on_device_heuristic',
    );
  }

  double _contrastScore(img.Image image) {
    final luminance = <double>[];
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        luminance.add((0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255);
      }
    }
    final mean = luminance.reduce((a, b) => a + b) / luminance.length;
    final variance = luminance
            .map((v) => math.pow(v - mean, 2).toDouble())
            .reduce((a, b) => a + b) /
        luminance.length;
    return math.sqrt(variance).clamp(0.0, 1.0);
  }

  String _colorTemperatureKey(img.Image image) {
    var warm = 0.0;
    var cool = 0.0;
    final count = image.width * image.height;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        warm += p.r - p.b;
        cool += p.b - p.r;
      }
    }
    if (warm / count > 12) {
      return 'insightColorWarm';
    }
    if (cool / count > 12) {
      return 'insightColorCool';
    }
    return 'insightColorNeutral';
  }

  String _lightingDirectionKey(img.Image image, double brightness) {
    final top = _regionBrightness(image, 0, 0, image.width, image.height ~/ 3);
    final bottom = _regionBrightness(
      image,
      0,
      image.height * 2 ~/ 3,
      image.width,
      image.height ~/ 3,
    );
    if (top - bottom > 0.08) {
      return 'insightLightingTop';
    }
    if (bottom - top > 0.08) {
      return 'insightLightingBottom';
    }
    if (brightness < 0.32) {
      return 'insightLightingBacklit';
    }
    return 'insightLightingEven';
  }

  double _regionBrightness(img.Image image, int x, int y, int w, int h) {
    var total = 0.0;
    var count = 0;
    for (var row = y; row < y + h && row < image.height; row++) {
      for (var col = x; col < x + w && col < image.width; col++) {
        final p = image.getPixel(col, row);
        total += (0.299 * p.r + 0.587 * p.g + 0.114 * p.b) / 255;
        count++;
      }
    }
    return count == 0 ? 0 : total / count;
  }

  String _compositionBalanceKey(img.Image image, Rect subjectRect) {
    final center = subjectRect.center;
    if ((center.dx - 0.5).abs() < 0.08) {
      return 'insightBalanceCentered';
    }
    if (center.dx < 0.42) {
      return 'insightBalanceLeft';
    }
    if (center.dx > 0.58) {
      return 'insightBalanceRight';
    }
    return 'insightBalanceDynamic';
  }

  String _moodKey(double brightness, double contrast, String colorTempKey) {
    if (brightness < 0.35 && contrast > 0.18) {
      return 'insightMoodDramatic';
    }
    if (brightness > 0.62 && colorTempKey == 'insightColorWarm') {
      return 'insightMoodBrightWarm';
    }
    if (contrast < 0.12) {
      return 'insightMoodSoft';
    }
    return 'insightMoodNatural';
  }

  String _depthHintKey(img.Image image, Rect subjectRect) {
    final subjectVariance = _regionVariance(image, subjectRect);
    final bgRect = Rect.fromLTWH(0, 0, 0.25, 1);
    final bgVariance = _regionVariance(image, bgRect);
    if (subjectVariance < bgVariance * 0.65) {
      return 'insightDepthShallow';
    }
    if (subjectVariance > bgVariance * 1.2) {
      return 'insightDepthDeep';
    }
    return 'insightDepthModerate';
  }

  double _regionVariance(img.Image image, Rect normalizedRect) {
    final left = (normalizedRect.left * image.width).floor();
    final top = (normalizedRect.top * image.height).floor();
    final right = (normalizedRect.right * image.width).ceil();
    final bottom = (normalizedRect.bottom * image.height).ceil();
    final values = <double>[];
    for (var y = top; y < bottom && y < image.height; y++) {
      for (var x = left; x < right && x < image.width; x++) {
        final p = image.getPixel(x, y);
        values.add((0.299 * p.r + 0.587 * p.g + 0.114 * p.b) / 255);
      }
    }
    if (values.isEmpty) {
      return 0;
    }
    final mean = values.reduce((a, b) => a + b) / values.length;
    return values.map((v) => math.pow(v - mean, 2).toDouble()).reduce((a, b) => a + b) /
        values.length;
  }

  double _confidence(SceneType sceneType, Rect subjectRect) {
    var confidence = 0.55;
    if (sceneType != SceneType.auto) {
      confidence += 0.2;
    }
    final fill = subjectRect.width * subjectRect.height;
    if (fill > 0.12 && fill < 0.55) {
      confidence += 0.15;
    }
    return confidence.clamp(0.0, 0.95);
  }

  List<String> _buildTips({
    required SceneType sceneType,
    required double brightness,
    required double contrast,
    required String colorTempKey,
    required String lightingKey,
    required String balanceKey,
    required Rect subjectRect,
  }) {
    final tips = <String>[];

    if (sceneType == SceneType.portrait || sceneType == SceneType.group) {
      tips.add('insightTipPortraitHeadroom');
      if (subjectRect.top < 0.12) {
        tips.add('insightTipPortraitCropTight');
      }
    } else if (sceneType == SceneType.landscape) {
      tips.add('insightTipLandscapeHorizon');
      tips.add('insightTipLandscapeForeground');
    } else if (sceneType == SceneType.product) {
      tips.add('insightTipProductCleanBg');
    }

    if (brightness < 0.35) {
      tips.add('insightTipRaiseExposure');
    } else if (brightness > 0.7) {
      tips.add('insightTipLowerExposure');
    }

    if (contrast < 0.1) {
      tips.add('insightTipIncreaseContrast');
    }

    if (lightingKey == 'insightLightingBacklit') {
      tips.add('insightTipBacklitFill');
    }

    if (balanceKey == 'insightBalanceLeft' || balanceKey == 'insightBalanceRight') {
      tips.add('insightTipKeepNegativeSpace');
    }

    if (colorTempKey == 'insightColorCool') {
      tips.add('insightTipWarmSkinTones');
    }

    return tips.take(6).toList();
  }
}